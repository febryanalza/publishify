import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:logger/logger.dart';

final logger = Logger();

/// Model untuk Notifikasi
class Notifikasi {
  final String id;
  final String idPengguna;
  final String judul;
  final String pesan;
  final String tipe; // 'info' | 'sukses' | 'peringatan' | 'error'
  final String? url;
  final bool dibaca;
  final DateTime dibuatPada;
  final DateTime? diperbaruiPada;

  Notifikasi({
    required this.id,
    required this.idPengguna,
    required this.judul,
    required this.pesan,
    required this.tipe,
    this.url,
    required this.dibaca,
    required this.dibuatPada,
    this.diperbaruiPada,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      id: json['id'] ?? '',
      idPengguna: json['idPengguna'] ?? '',
      judul: json['judul'] ?? 'Tanpa Judul',
      pesan: json['pesan'] ?? '',
      tipe: json['tipe'] ?? 'info',
      url: json['url'],
      dibaca: json['dibaca'] ?? false,
      dibuatPada: json['dibuatPada'] != null 
          ? DateTime.parse(json['dibuatPada']) 
          : DateTime.now(),
      diperbaruiPada: json['diperbaruiPada'] != null 
          ? DateTime.parse(json['diperbaruiPada']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPengguna': idPengguna,
      'judul': judul,
      'pesan': pesan,
      'tipe': tipe,
      'url': url,
      'dibaca': dibaca,
      'dibuatPada': dibuatPada.toIso8601String(),
      'diperbaruiPada': diperbaruiPada?.toIso8601String(),
    };
  }
}

/// Model untuk Metadata Pagination
class NotifikasiMetadata {
  final int total;
  final int halaman;
  final int limit;
  final int totalHalaman;

  NotifikasiMetadata({
    required this.total,
    required this.halaman,
    required this.limit,
    required this.totalHalaman,
  });

  factory NotifikasiMetadata.fromJson(Map<String, dynamic> json) {
    return NotifikasiMetadata(
      total: json['total'] ?? 0,
      halaman: json['halaman'] ?? 1,
      limit: json['limit'] ?? 10,
      totalHalaman: json['totalHalaman'] ?? 1,
    );
  }
}

/// Response untuk list notifikasi dengan pagination
class NotifikasiListResponse {
  final bool sukses;
  final String? pesan;
  final List<Notifikasi>? data;
  final NotifikasiMetadata? metadata;

  NotifikasiListResponse({
    required this.sukses,
    this.pesan,
    this.data,
    this.metadata,
  });

  factory NotifikasiListResponse.fromJson(Map<String, dynamic> json) {
    return NotifikasiListResponse(
      sukses: json['sukses'],
      pesan: json['pesan'],
      data: json['data'] != null
          ? (json['data'] as List).map((item) => Notifikasi.fromJson(item)).toList()
          : null,
      metadata: json['metadata'] != null
          ? NotifikasiMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

/// Response untuk single notifikasi
class NotifikasiResponse {
  final bool sukses;
  final String? pesan;
  final Notifikasi? data;

  NotifikasiResponse({
    required this.sukses,
    this.pesan,
    this.data,
  });

  factory NotifikasiResponse.fromJson(Map<String, dynamic> json) {
    return NotifikasiResponse(
      sukses: json['sukses'],
      pesan: json['pesan'],
      data: json['data'] != null ? Notifikasi.fromJson(json['data']) : null,
    );
  }
}

/// Response untuk count notifikasi belum dibaca
class NotifikasiBelumDibacaResponse {
  final bool sukses;
  final String? pesan;
  final int? totalBelumDibaca;

  NotifikasiBelumDibacaResponse({
    required this.sukses,
    this.pesan,
    this.totalBelumDibaca,
  });

  factory NotifikasiBelumDibacaResponse.fromJson(Map<String, dynamic> json) {
    return NotifikasiBelumDibacaResponse(
      sukses: json['sukses'],
      pesan: json['pesan'],
      totalBelumDibaca: json['data'] != null ? json['data']['totalBelumDibaca'] : null,
    );
  }
}

/// Service untuk mengelola notifikasi editor
class EditorNotifikasiService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  /// Helper untuk membuat headers dengan auth
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/notifikasi
  /// Ambil daftar notifikasi dengan filter dan pagination
  static Future<NotifikasiListResponse> ambilNotifikasi({
    int halaman = 1,
    int limit = 20,
    bool? dibaca,
    String? tipe,
    String? tanggalMulai,
    String? tanggalSelesai,
    String urutkan = 'dibuatPada',
    String arah = 'desc',
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'halaman': halaman.toString(),
        'limit': limit.toString(),
        'urutkan': urutkan,
        'arah': arah,
      };

      if (dibaca != null) {
        queryParams['dibaca'] = dibaca.toString();
      }

      if (tipe != null && tipe.isNotEmpty) {
        queryParams['tipe'] = tipe;
      }

      if (tanggalMulai != null && tanggalMulai.isNotEmpty) {
        queryParams['tanggalMulai'] = tanggalMulai;
      }

      if (tanggalSelesai != null && tanggalSelesai.isNotEmpty) {
        queryParams['tanggalSelesai'] = tanggalSelesai;
      }

      final uri = Uri.parse('$baseUrl/api/notifikasi')
          .replace(queryParameters: queryParams);

      logger.i('[EditorNotifikasiService] GET $uri');

      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      logger.i('[EditorNotifikasiService] Response status: ${response.statusCode}');

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return NotifikasiListResponse.fromJson(jsonResponse);
      } else {
        String errorMessage = jsonResponse['pesan'] ?? 'Gagal mengambil notifikasi';
        
        if (response.statusCode == 401) {
          errorMessage = 'Unauthorized - Token tidak valid atau sudah kedaluwarsa';
        }

        logger.e('[EditorNotifikasiService] Error: $errorMessage');

        return NotifikasiListResponse(
          sukses: false,
          pesan: errorMessage,
        );
      }
    } catch (e) {
      logger.e('[EditorNotifikasiService] Exception: ${e.toString()}');
      
      return NotifikasiListResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// GET /api/notifikasi/:id
  /// Ambil detail notifikasi berdasarkan ID
  static Future<NotifikasiResponse> ambilNotifikasiById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/notifikasi/$id');
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return NotifikasiResponse.fromJson(jsonResponse);
      } else {
        return NotifikasiResponse(
          sukses: false,
          pesan: jsonResponse['pesan'] ?? 'Gagal mengambil detail notifikasi',
        );
      }
    } catch (e) {
      return NotifikasiResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// PUT /api/notifikasi/:id/baca
  /// Tandai notifikasi sebagai sudah dibaca
  static Future<NotifikasiResponse> tandaiDibaca(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/notifikasi/$id/baca');
      final headers = await _getHeaders();
      final response = await http.put(uri, headers: headers);

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return NotifikasiResponse.fromJson(jsonResponse);
      } else {
        return NotifikasiResponse(
          sukses: false,
          pesan: jsonResponse['pesan'] ?? 'Gagal menandai notifikasi sebagai dibaca',
        );
      }
    } catch (e) {
      return NotifikasiResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// PUT /api/notifikasi/baca-semua/all
  /// Tandai semua notifikasi sebagai sudah dibaca
  static Future<NotifikasiResponse> tandaiSemuaDibaca() async {
    try {
      final uri = Uri.parse('$baseUrl/api/notifikasi/baca-semua/all');
      final headers = await _getHeaders();
      final response = await http.put(uri, headers: headers);

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return NotifikasiResponse(
          sukses: jsonResponse['sukses'] ?? false,
          pesan: jsonResponse['pesan'],
        );
      } else {
        return NotifikasiResponse(
          sukses: false,
          pesan: jsonResponse['pesan'] ?? 'Gagal menandai semua notifikasi sebagai dibaca',
        );
      }
    } catch (e) {
      return NotifikasiResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// DELETE /api/notifikasi/:id
  /// Hapus notifikasi
  static Future<NotifikasiResponse> hapusNotifikasi(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/notifikasi/$id');
      final headers = await _getHeaders();
      final response = await http.delete(uri, headers: headers);

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return NotifikasiResponse(
          sukses: jsonResponse['sukses'] ?? false,
          pesan: jsonResponse['pesan'],
        );
      } else {
        return NotifikasiResponse(
          sukses: false,
          pesan: jsonResponse['pesan'] ?? 'Gagal menghapus notifikasi',
        );
      }
    } catch (e) {
      return NotifikasiResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// GET /api/notifikasi/belum-dibaca/count
  /// Hitung jumlah notifikasi yang belum dibaca
  static Future<NotifikasiBelumDibacaResponse> hitungBelumDibaca() async {
    try {
      final uri = Uri.parse('$baseUrl/api/notifikasi/belum-dibaca/count');
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return NotifikasiBelumDibacaResponse.fromJson(jsonResponse);
      } else {
        return NotifikasiBelumDibacaResponse(
          sukses: false,
          pesan: jsonResponse['pesan'] ?? 'Gagal menghitung notifikasi belum dibaca',
        );
      }
    } catch (e) {
      return NotifikasiBelumDibacaResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
