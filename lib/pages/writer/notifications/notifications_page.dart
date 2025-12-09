import 'dart:async';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/notifikasi_models.dart';
import 'package:publishify/services/writer/notifikasi_service.dart';
import 'package:publishify/services/writer/notifikasi_socket_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final logger = Logger();
  List<NotifikasiData> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;

  // Filter states
  bool? _filterDibaca;
  String? _filterTipe;

  // WebSocket
  final _socketService = NotifikasiSocketService();
  StreamSubscription? _notifikasiBaruSubscription;
  StreamSubscription? _connectionStatusSubscription;
  bool _isSocketConnected = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupWebSocket();
  }

  /// Setup WebSocket connection dan listeners
  void _setupWebSocket() {
    // Connect to WebSocket
    _socketService.connect();

    // Listen to new notifications
    _notifikasiBaruSubscription = _socketService.notifikasiBaru.listen((notifikasi) {
      logger.i('[NotificationsPage] New notification received via WebSocket');
      
      setState(() {
        // Insert notifikasi baru di awal list
        _notifications.insert(0, notifikasi);
      });

      // Show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📬 ${notifikasi.judul}'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Lihat',
              onPressed: () {
                // Auto scroll to top
                // You can add navigation to detail here
              },
            ),
          ),
        );
      }
    });

    // Listen to connection status
    _connectionStatusSubscription = _socketService.connectionStatus.listen((isConnected) {
      setState(() {
        _isSocketConnected = isConnected;
      });

      if (mounted && isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔗 Terhubung ke notifikasi real-time'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _notifikasiBaruSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    // Don't disconnect socket, keep it alive for other pages
    super.dispose();
  }

  Future<void> _loadData({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _notifications.clear();
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      logger.i('[NotificationsPage] Loading notifications - page: $_currentPage, limit: $_limit');
      
      final response = await NotifikasiService.getNotifikasi(
        halaman: _currentPage,
        limit: _limit,
        dibaca: _filterDibaca,
        tipe: _filterTipe,
      );

      logger.i('[NotificationsPage] Response received - sukses: ${response.sukses}, data count: ${response.data?.length ?? 0}');

      if (response.sukses && response.data != null) {
        setState(() {
          if (refresh) {
            _notifications = response.data!;
          } else {
            _notifications.addAll(response.data!);
          }
          _isLoading = false;
          _hasMore = response.data!.length == _limit;
        });
      } else {
        final errorMsg = response.pesan ?? 'Gagal memuat notifikasi';
        logger.e('[NotificationsPage] Error: $errorMsg');
        
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });

        // Show snackbar for Unauthorized error
        if (mounted && errorMsg.toLowerCase().contains('unauthorized')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('⚠️ Sesi login Anda telah berakhir. Silakan login kembali.'),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Login',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to login page
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      logger.e('[NotificationsPage] Exception: ${e.toString()}');
      
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _currentPage++;
    });

    await _loadData();
  }

  Future<void> _markAsRead(NotifikasiData notification) async {
    if (notification.dibaca) return;

    try {
      final response = await NotifikasiService.tandaiDibaca(notification.id);

      if (response.sukses) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = NotifikasiData(
              id: notification.id,
              idPengguna: notification.idPengguna,
              judul: notification.judul,
              pesan: notification.pesan,
              tipe: notification.tipe,
              url: notification.url,
              dibaca: true,
              dibuatPada: notification.dibuatPada,
              dibacaPada: DateTime.now().toIso8601String(),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menandai sebagai dibaca: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteNotification(NotifikasiData notification) async {
    // Optimistic update
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });

    try {
      final response = await NotifikasiService.hapusNotifikasi(notification.id);

      if (!response.sukses) {
        // Rollback on failure
        await _loadData(refresh: true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.pesan ?? 'Gagal menghapus notifikasi')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifikasi dihapus'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Rollback on error
      await _loadData(refresh: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await NotifikasiService.tandaiSemuaDibaca();

      if (response.sukses) {
        await _loadData(refresh: true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua notifikasi ditandai sudah dibaca'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.pesan ?? 'Gagal menandai semua notifikasi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        bool? tempDibaca = _filterDibaca;
        String? tempTipe = _filterTipe;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildRadioIndicator(bool isSelected) {
              return Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryGreen : AppTheme.greyMedium,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      )
                    : null,
              );
            }

            return AlertDialog(
              title: const Text('Filter Notifikasi'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filter Status Dibaca
                  const Text('Status Dibaca:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ListTile(
                    leading: buildRadioIndicator(tempDibaca == null),
                    title: const Text('Semua'),
                    onTap: () {
                      setDialogState(() {
                        tempDibaca = null;
                      });
                    },
                  ),
                  ListTile(
                    leading: buildRadioIndicator(tempDibaca == true),
                    title: const Text('Sudah Dibaca'),
                    onTap: () {
                      setDialogState(() {
                        tempDibaca = true;
                      });
                    },
                  ),
                  ListTile(
                    leading: buildRadioIndicator(tempDibaca == false),
                    title: const Text('Belum Dibaca'),
                    onTap: () {
                      setDialogState(() {
                        tempDibaca = false;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Tipe
                  const Text('Tipe:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ListTile(
                    leading: buildRadioIndicator(tempTipe == null),
                    title: const Text('Semua'),
                    onTap: () {
                      setDialogState(() {
                        tempTipe = null;
                      });
                    },
                  ),
                  ListTile(
                    leading: buildRadioIndicator(tempTipe == 'info'),
                    title: const Text('Info'),
                    onTap: () {
                      setDialogState(() {
                        tempTipe = 'info';
                      });
                    },
                  ),
                  ListTile(
                    leading: buildRadioIndicator(tempTipe == 'sukses'),
                    title: const Text('Sukses'),
                    onTap: () {
                      setDialogState(() {
                        tempTipe = 'sukses';
                      });
                    },
                  ),
                  ListTile(
                    leading: buildRadioIndicator(tempTipe == 'peringatan'),
                    title: const Text('Peringatan'),
                    onTap: () {
                      setDialogState(() {
                        tempTipe = 'peringatan';
                      });
                    },
                  ),
                  ListTile(
                    leading: buildRadioIndicator(tempTipe == 'error'),
                    title: const Text('Error'),
                    onTap: () {
                      setDialogState(() {
                        tempTipe = 'error';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filterDibaca = tempDibaca;
                      _filterTipe = tempTipe;
                    });
                    Navigator.pop(context);
                    _loadData(refresh: true);
                  },
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.dibaca).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(unreadCount),
            Expanded(
              child: _isLoading && _notifications.isEmpty
                  ? _buildLoadingState()
                  : _errorMessage != null && _notifications.isEmpty
                      ? _buildErrorState()
                      : _notifications.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: () => _loadData(refresh: true),
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (ScrollNotification scrollInfo) {
                                  if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                                    _loadMore();
                                  }
                                  return false;
                                },
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      ..._notifications.map((notification) {
                                        return _buildNotificationCard(notification);
                                      }),
                                      if (_isLoading && _notifications.isNotEmpty)
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(
                                            color: AppTheme.primaryGreen,
                                          ),
                                        ),
                                      const SizedBox(height: 80),
                                    ],
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int unreadCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection status indicator
          if (_isSocketConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                  SizedBox(width: 6),
                  Text(
                    'Real-time aktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Notifikasi',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppTheme.white,
                ),
                onSelected: (value) {
                  if (value == 'mark_all_read') {
                    _markAllAsRead();
                  } else if (value == 'filter') {
                    _showFilterDialog();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, size: 20),
                        SizedBox(width: 8),
                        Text('Tandai Semua Sudah Dibaca'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'filter',
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, size: 20),
                        SizedBox(width: 8),
                        Text('Filter'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryGreen,
          ),
          SizedBox(height: 16),
          Text(
            'Memuat notifikasi...',
            style: TextStyle(
              color: AppTheme.greyMedium,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loadData(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: AppTheme.greyMedium.withValues(alpha:0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Notifikasi',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi akan muncul di sini',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotifikasiData notification) {
    Color tipeColor;
    IconData tipeIcon;

    switch (notification.tipe.toLowerCase()) {
      case 'sukses':
        tipeColor = Colors.green;
        tipeIcon = Icons.check_circle;
        break;
      case 'peringatan':
        tipeColor = Colors.orange;
        tipeIcon = Icons.warning;
        break;
      case 'error':
        tipeColor = AppTheme.errorRed;
        tipeIcon = Icons.error;
        break;
      case 'info':
      default:
        tipeColor = Colors.blue;
        tipeIcon = Icons.info;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: AppTheme.white,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: notification.dibaca ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: notification.dibaca
              ? BorderSide.none
              : BorderSide(
                  color: AppTheme.primaryGreen.withValues(alpha:0.3),
                  width: 2,
                ),
        ),
        child: InkWell(
          onTap: () {
            _markAsRead(notification);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tipeColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    tipeIcon,
                    color: tipeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.judul,
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: notification.dibaca
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (!notification.dibaca)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.pesan,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyMedium,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.dibuatPada,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyMedium,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
