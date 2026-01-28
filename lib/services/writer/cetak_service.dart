import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/models/writer/cetak_models.dart';

/// Service untuk mengelola pesanan cetak dari sisi penulis
class CetakService {
  static final logger = Logger();
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';

  /// Ambil daftar percetakan yang tersedia
  /// GET /api/percetakan/daftar
  static Future<PercetakanListResponse> ambilDaftarPercetakan() async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return PercetakanListResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/percetakan/daftar');
      
      logger.d('Fetching percetakan list: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        logger.e('JSON decode error: $e');
        return PercetakanListResponse(
          sukses: false,
          pesan: 'Format response tidak valid',
        );
      }
      
      if (response.statusCode == 200) {
        try {
          return PercetakanListResponse.fromJson(responseData);
        } catch (e, stackTrace) {
          logger.e('Error parsing response: $e');
          logger.e('StackTrace: $stackTrace');
          return PercetakanListResponse(
            sukses: false,
            pesan: 'Gagal memproses data: ${e.toString()}',
          );
        }
      } else {
        return PercetakanListResponse(
          sukses: false,
          pesan: responseData['pesan']?.toString() ?? 'Gagal mengambil daftar percetakan',
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching percetakan list: $e');
      logger.e('StackTrace: $stackTrace');
      return PercetakanListResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Buat pesanan cetak baru (endpoint simplified)
  /// POST /api/percetakan/pesanan/baru
  static Future<PesananDetailResponse> buatPesananBaru(BuatPesananBaruRequest request) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return PesananDetailResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/percetakan/pesanan/baru');
      
      logger.d('Creating print order (new endpoint): ${jsonEncode(request.toJson())}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        logger.e('JSON decode error: $e');
        return PesananDetailResponse(
          sukses: false,
          pesan: 'Format response tidak valid',
        );
      }
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          return PesananDetailResponse.fromJson(responseData);
        } catch (e, stackTrace) {
          logger.e('Error parsing response: $e');
          logger.e('StackTrace: $stackTrace');
          return PesananDetailResponse(
            sukses: false,
            pesan: 'Gagal memproses data: ${e.toString()}',
          );
        }
      } else {
        return PesananDetailResponse(
          sukses: false,
          pesan: responseData['pesan']?.toString() ?? 'Gagal membuat pesanan cetak',
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error creating print order: $e');
      logger.e('StackTrace: $stackTrace');
      return PesananDetailResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Buat pesanan cetak baru (OLD - deprecated)
  /// POST /api/percetakan
  @deprecated
  static Future<PesananDetailResponse> buatPesanan(BuatPesananRequest request) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return PesananDetailResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/percetakan');
      
      logger.d('Creating print order: ${jsonEncode(request.toJson())}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      // Parse JSON dengan error handling
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        logger.e('JSON decode error: $e');
        return PesananDetailResponse(
          sukses: false,
          pesan: 'Format response tidak valid',
        );
      }
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          return PesananDetailResponse.fromJson(responseData);
        } catch (e, stackTrace) {
          logger.e('Error parsing response: $e');
          logger.e('StackTrace: $stackTrace');
          logger.e('Response data: $responseData');
          return PesananDetailResponse(
            sukses: false,
            pesan: 'Gagal memproses data: ${e.toString()}',
          );
        }
      } else {
        return PesananDetailResponse(
          sukses: false,
          pesan: responseData['pesan']?.toString() ?? 'Gagal membuat pesanan cetak',
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error creating print order: $e');
      logger.e('StackTrace: $stackTrace');
      return PesananDetailResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Ambil daftar pesanan cetak penulis
  /// GET /api/percetakan/penulis/saya
  static Future<PesananListResponse> ambilPesananSaya({
    String? status,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return PesananListResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      // Build query params - HANYA status yang dikirim
      final queryParams = <String, String>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final url = queryParams.isEmpty
          ? Uri.parse('$baseUrl/api/percetakan/penulis/saya')
          : Uri.parse('$baseUrl/api/percetakan/penulis/saya')
              .replace(queryParameters: queryParams);
      
      logger.d('Fetching print orders: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      // Parse JSON dengan error handling
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        logger.e('JSON decode error: $e');
        return PesananListResponse(
          sukses: false,
          pesan: 'Format response tidak valid',
        );
      }
      
      if (response.statusCode == 200) {
        try {
          return PesananListResponse.fromJson(responseData);
        } catch (e, stackTrace) {
          logger.e('Error parsing response: $e');
          logger.e('StackTrace: $stackTrace');
          logger.e('Response data: $responseData');
          return PesananListResponse(
            sukses: false,
            pesan: 'Gagal memproses data: ${e.toString()}',
          );
        }
      } else {
        return PesananListResponse(
          sukses: false,
          pesan: responseData['pesan']?.toString() ?? 'Gagal mengambil daftar pesanan',
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching print orders: $e');
      logger.e('StackTrace: $stackTrace');
      return PesananListResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Ambil detail pesanan cetak
  /// GET /api/percetakan/:id
  static Future<PesananDetailResponse> ambilDetailPesanan(String id) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return PesananDetailResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/percetakan/$id');
      
      logger.d('Fetching order detail: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      // Parse JSON dengan error handling
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        logger.e('JSON decode error: $e');
        return PesananDetailResponse(
          sukses: false,
          pesan: 'Format response tidak valid',
        );
      }
      
      if (response.statusCode == 200) {
        try {
          return PesananDetailResponse.fromJson(responseData);
        } catch (e, stackTrace) {
          logger.e('Error parsing response: $e');
          logger.e('StackTrace: $stackTrace');
          logger.e('Response data: $responseData');
          return PesananDetailResponse(
            sukses: false,
            pesan: 'Gagal memproses data: ${e.toString()}',
          );
        }
      } else {
        return PesananDetailResponse(
          sukses: false,
          pesan: responseData['pesan']?.toString() ?? 'Gagal mengambil detail pesanan',
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching order detail: $e');
      logger.e('StackTrace: $stackTrace');
      return PesananDetailResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Batalkan pesanan cetak
  /// PUT /api/percetakan/:id/batal
  static Future<PesananDetailResponse> batalkanPesanan(String id, {String? alasan}) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return PesananDetailResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/percetakan/$id/batal');
      
      logger.d('Canceling order: $id');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          if (alasan != null) 'alasan': alasan,
        }),
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      // Parse JSON dengan error handling
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        logger.e('JSON decode error: $e');
        return PesananDetailResponse(
          sukses: false,
          pesan: 'Format response tidak valid',
        );
      }
      
      if (response.statusCode == 200) {
        try {
          return PesananDetailResponse.fromJson(responseData);
        } catch (e, stackTrace) {
          logger.e('Error parsing response: $e');
          logger.e('StackTrace: $stackTrace');
          logger.e('Response data: $responseData');
          return PesananDetailResponse(
            sukses: false,
            pesan: 'Gagal memproses data: ${e.toString()}',
          );
        }
      } else {
        return PesananDetailResponse(
          sukses: false,
          pesan: responseData['pesan']?.toString() ?? 'Gagal membatalkan pesanan',
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error canceling order: $e');
      logger.e('StackTrace: $stackTrace');
      return PesananDetailResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Helper: Get status color
  static int getStatusColor(String status) {
    const statusColors = {
      'tertunda': 0xFFFFA726, // Orange
      'diterima': 0xFF42A5F5, // Blue
      'dalam_produksi': 0xFF7E57C2, // Purple
      'kontrol_kualitas': 0xFF26A69A, // Teal
      'siap': 0xFF66BB6A, // Green Light
      'dikirim': 0xFF29B6F6, // Light Blue
      'terkirim': 0xFF4CAF50, // Green
      'dibatalkan': 0xFFEF5350, // Red
    };
    return statusColors[status] ?? 0xFF9E9E9E;
  }

  /// Helper: Get status label
  static String getStatusLabel(String status) {
    const statusLabels = {
      'tertunda': 'Menunggu Konfirmasi',
      'diterima': 'Diterima',
      'dalam_produksi': 'Dalam Produksi',
      'kontrol_kualitas': 'Kontrol Kualitas',
      'siap': 'Siap Kirim',
      'dikirim': 'Dalam Pengiriman',
      'terkirim': 'Selesai',
      'dibatalkan': 'Dibatalkan',
    };
    return statusLabels[status] ?? status;
  }

  /// Format tanggal ke format Indonesia
  static String formatTanggal(DateTime tanggal) {
    final Map<int, String> bulan = {
      1: 'Januari',
      2: 'Februari',
      3: 'Maret',
      4: 'April',
      5: 'Mei',
      6: 'Juni',
      7: 'Juli',
      8: 'Agustus',
      9: 'September',
      10: 'Oktober',
      11: 'November',
      12: 'Desember',
    };

    return '${tanggal.day} ${bulan[tanggal.month]} ${tanggal.year}';
  }

  /// Format tanggal dengan waktu
  static String formatTanggalWaktu(DateTime tanggal) {
    final String tgl = formatTanggal(tanggal);
    final String jam =
        '${tanggal.hour.toString().padLeft(2, '0')}:${tanggal.minute.toString().padLeft(2, '0')}';
    return '$tgl pukul $jam';
  }
}
