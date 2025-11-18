import 'dart:async';
import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:publishify/models/notifikasi_models.dart';


/// Service untuk mengelola WebSocket connection notifikasi real-time
/// Backend: /notifikasi namespace dengan Socket.io
/// 
/// Events yang diterima:
/// - notifikasi_baru: Notifikasi baru masuk
/// - notifikasi_count: Update jumlah notifikasi belum dibaca
/// - notifikasi_broadcast: Broadcast notification ke semua user
/// 
/// Events yang dikirim:
/// - join_room: Join room user-specific untuk menerima notifikasi
class NotifikasiSocketService {
  static NotifikasiSocketService? _instance;
  IO.Socket? _socket;
  bool _isConnected = false;

  // Stream controllers untuk emit events ke UI
  final _notifikasiBaruController = StreamController<NotifikasiData>.broadcast();
  final _notifikasiCountController = StreamController<int>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  // Getters untuk streams
  Stream<NotifikasiData> get notifikasiBaru => _notifikasiBaruController.stream;
  Stream<int> get notifikasiCount => _notifikasiCountController.stream;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  bool get isConnected => _isConnected;

  // Singleton pattern
  factory NotifikasiSocketService() {
    _instance ??= NotifikasiSocketService._internal();
    return _instance!;
  }

  NotifikasiSocketService._internal();

  /// Connect ke WebSocket server
  /// baseUrl dari .env: BASE_URL
  /// namespace: /notifikasi
  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      printToConsole('[NotifikasiSocket] Already connected');
      return;
    }

    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:4000';
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        printToConsole('[NotifikasiSocket] ⚠️ No token found - cannot connect');
        _connectionStatusController.add(false);
        return;
      }

      printToConsole('[NotifikasiSocket] Token found - length: ${token.length}');
      printToConsole('[NotifikasiSocket] Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      printToConsole('[NotifikasiSocket] Connecting to: $baseUrl/notifikasi');

      // Create socket with namespace /notifikasi
      _socket = IO.io(
        '$baseUrl/notifikasi',
        IO.OptionBuilder()
            .setTransports(['websocket']) // Use websocket only
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(2000)
            .setReconnectionDelayMax(10000)
            .setReconnectionAttempts(5)
            .setAuth({
              'token': 'Bearer $token',
            })
            .build(),
      );

      // Setup event listeners
      _setupEventListeners();
    } catch (e) {
      printToConsole('[NotifikasiSocket] Error connecting: $e');
      _isConnected = false;
      _connectionStatusController.add(false);
    }
  }

  /// Setup event listeners untuk WebSocket
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection established
    _socket!.onConnect((_) async {
      printToConsole('[NotifikasiSocket] Connected successfully');
      _isConnected = true;
      _connectionStatusController.add(true);

      // Join room setelah connected
      await _joinUserRoom();
    });

    // Connection error
    _socket!.onConnectError((error) {
      printToConsole('[NotifikasiSocket] Connection error: $error');
      _isConnected = false;
      _connectionStatusController.add(false);
    });

    // Disconnected
    _socket!.onDisconnect((_) {
      printToConsole('[NotifikasiSocket] Disconnected');
      _isConnected = false;
      _connectionStatusController.add(false);
    });

    // Reconnect attempt
    _socket!.on('reconnect_attempt', (attempt) {
      printToConsole('[NotifikasiSocket] Reconnection attempt: $attempt');
    });

    // Reconnect success
    _socket!.on('reconnect', (attempt) async {
      printToConsole('[NotifikasiSocket] Reconnected after $attempt attempts');
      _isConnected = true;
      _connectionStatusController.add(true);
      
      // Rejoin room setelah reconnect
      await _joinUserRoom();
    });

    // Listen to notifikasi_baru event
    _socket!.on('notifikasi_baru', (data) {
      printToConsole('[NotifikasiSocket] New notification received: $data');
      
      try {
        if (data is Map<String, dynamic> && data['sukses'] == true) {
          final notifikasiData = NotifikasiData.fromJson(data['data']);
          _notifikasiBaruController.add(notifikasiData);
        }
      } catch (e) {
        printToConsole('[NotifikasiSocket] Error parsing notifikasi_baru: $e');
      }
    });

    // Listen to notifikasi_count event
    _socket!.on('notifikasi_count', (data) {
      printToConsole('[NotifikasiSocket] Count update received: $data');
      
      try {
        if (data is Map<String, dynamic> && data['sukses'] == true) {
          final count = data['data']['totalBelumDibaca'] as int;
          _notifikasiCountController.add(count);
        }
      } catch (e) {
        printToConsole('[NotifikasiSocket] Error parsing notifikasi_count: $e');
      }
    });

    // Listen to broadcast notifications
    _socket!.on('notifikasi_broadcast', (data) {
      printToConsole('[NotifikasiSocket] Broadcast notification received: $data');
      
      try {
        if (data is Map<String, dynamic> && data['sukses'] == true) {
          // Treat broadcast as new notification
          final notifikasiData = NotifikasiData(
            id: 'broadcast_${DateTime.now().millisecondsSinceEpoch}',
            idPengguna: '',
            judul: data['data']['judul'] ?? 'Pengumuman',
            pesan: data['data']['pesan'] ?? '',
            tipe: data['data']['tipe'] ?? 'info',
            dibaca: false,
            dibuatPada: data['data']['dibuatPada'] ?? DateTime.now().toIso8601String(),
          );
          _notifikasiBaruController.add(notifikasiData);
        }
      } catch (e) {
        printToConsole('[NotifikasiSocket] Error parsing notifikasi_broadcast: $e');
      }
    });
  }

  /// Join room user-specific untuk menerima notifikasi
  /// Room format: user_<idPengguna>
  Future<void> _joinUserRoom() async {
    if (_socket == null || !_isConnected) {
      printToConsole('[NotifikasiSocket] Cannot join room: not connected');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        printToConsole('[NotifikasiSocket] Cannot join room: no user ID');
        return;
      }

      printToConsole('[NotifikasiSocket] Joining room for user: $userId');

      // Emit join_room event
      _socket!.emit('join_room', {
        'idPengguna': userId,
      });

      // Listen for join_room response
      _socket!.on('join_room_response', (data) {
        printToConsole('[NotifikasiSocket] Join room response: $data');
      });
    } catch (e) {
      printToConsole('[NotifikasiSocket] Error joining room: $e');
    }
  }

  /// Disconnect dari WebSocket server
  void disconnect() {
    if (_socket != null) {
      printToConsole('[NotifikasiSocket] Disconnecting...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _connectionStatusController.add(false);
    }
  }

  /// Helper untuk mendapatkan token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token'); // Fixed: use correct key with underscore
  }

  /// Dispose all stream controllers
  void dispose() {
    _notifikasiBaruController.close();
    _notifikasiCountController.close();
    _connectionStatusController.close();
    disconnect();
    _instance = null;
  }
}
