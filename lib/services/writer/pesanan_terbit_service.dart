import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/models/writer/pesanan_terbit_models.dart';

/// Service untuk mengelola pesanan terbit dari sisi penulis
class PesananTerbitService {
  static final logger = Logger();
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';

  /// Helper untuk mengekstrak pesan error dari response
  /// Backend bisa mengembalikan pesan sebagai String atau List<String>
  static String _extractErrorMessage(dynamic pesan, String defaultMessage) {
    if (pesan == null) return defaultMessage;
    if (pesan is String) return pesan;
    if (pesan is List) {
      return pesan.map((e) => e.toString()).join(', ');
    }
    return pesan.toString();
  }

  // ============================================
  // PENULIS ENDPOINTS
  // ============================================

  /// Buat pesanan terbit baru
  /// POST /api/pesanan-terbit
  static Future<PesananTerbitResponse<PesananTerbitDetail>> buatPesananTerbit(
      BuatPesananTerbitRequest request) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return PesananTerbitResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/pesanan-terbit');

      logger.d('Creating pesanan terbit: $url');
      logger.d('Request body: ${request.toJson()}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      logger.d('Response status: ${response.statusCode}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PesananTerbitResponse(
          sukses: true,
          pesan: _extractErrorMessage(responseData['pesan'], 'Pesanan terbit berhasil dibuat'),
          data: responseData['data'] != null
              ? PesananTerbitDetail.fromJson(responseData['data'])
              : null,
        );
      } else {
        return PesananTerbitResponse(
          sukses: false,
          pesan: _extractErrorMessage(responseData['pesan'], 'Gagal membuat pesanan terbit'),
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error creating pesanan terbit: $e');
      logger.e('StackTrace: $stackTrace');
      return PesananTerbitResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Ambil daftar pesanan terbit milik penulis (saya)
  /// GET /api/pesanan-terbit/saya
  static Future<DaftarPesananTerbitResponse> getPesananTerbitSaya({
    String? status,
    String? statusPembayaran,
    int halaman = 1,
    int limit = 10,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return DaftarPesananTerbitResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
          data: [],
        );
      }

      final queryParams = <String, String>{
        'halaman': halaman.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (statusPembayaran != null && statusPembayaran.isNotEmpty) {
        queryParams['statusPembayaran'] = statusPembayaran;
      }

      final url = Uri.parse('$baseUrl/api/pesanan-terbit/saya')
          .replace(queryParameters: queryParams);

      logger.d('Fetching pesanan terbit saya: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      logger.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return DaftarPesananTerbitResponse.fromJson(responseData);
      } else {
        return DaftarPesananTerbitResponse(
          sukses: false,
          pesan: 'Gagal mengambil daftar pesanan terbit',
          data: [],
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching pesanan terbit saya: $e');
      logger.e('StackTrace: $stackTrace');
      return DaftarPesananTerbitResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
        data: [],
      );
    }
  }

  /// Ambil detail pesanan terbit
  /// GET /api/pesanan-terbit/:id
  static Future<PesananTerbitResponse<PesananTerbitDetail>> getDetailPesananTerbit(
      String id) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return PesananTerbitResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/pesanan-terbit/$id');

      logger.d('Fetching pesanan terbit detail: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      logger.d('Response status: ${response.statusCode}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return PesananTerbitResponse(
          sukses: true,
          pesan: 'Berhasil mengambil detail pesanan terbit',
          data: responseData['data'] != null
              ? PesananTerbitDetail.fromJson(responseData['data'])
              : null,
        );
      } else {
        return PesananTerbitResponse(
          sukses: false,
          pesan: _extractErrorMessage(responseData['pesan'], 'Gagal mengambil detail pesanan terbit'),
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching pesanan terbit detail: $e');
      logger.e('StackTrace: $stackTrace');
      return PesananTerbitResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Update spesifikasi buku
  /// PUT /api/pesanan-terbit/:id/spesifikasi
  static Future<PesananTerbitResponse<SpesifikasiBuku>> updateSpesifikasi(
      String id, UpdateSpesifikasiRequest request) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return PesananTerbitResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/pesanan-terbit/$id/spesifikasi');

      logger.d('Updating spesifikasi: $url');
      logger.d('Request body: ${request.toJson()}');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      logger.d('Response status: ${response.statusCode}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return PesananTerbitResponse(
          sukses: true,
          pesan: _extractErrorMessage(responseData['pesan'], 'Spesifikasi berhasil diperbarui'),
          data: responseData['data'] != null
              ? SpesifikasiBuku.fromJson(responseData['data'])
              : null,
        );
      } else {
        return PesananTerbitResponse(
          sukses: false,
          pesan: _extractErrorMessage(responseData['pesan'], 'Gagal memperbarui spesifikasi'),
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error updating spesifikasi: $e');
      logger.e('StackTrace: $stackTrace');
      return PesananTerbitResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Update kelengkapan naskah
  /// PUT /api/pesanan-terbit/:id/kelengkapan
  static Future<PesananTerbitResponse<KelengkapanNaskah>> updateKelengkapan(
      String id, UpdateKelengkapanRequest request) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return PesananTerbitResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/pesanan-terbit/$id/kelengkapan');

      logger.d('Updating kelengkapan: $url');
      logger.d('Request body: ${request.toJson()}');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      logger.d('Response status: ${response.statusCode}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return PesananTerbitResponse(
          sukses: true,
          pesan: _extractErrorMessage(responseData['pesan'], 'Kelengkapan berhasil diperbarui'),
          data: responseData['data'] != null
              ? KelengkapanNaskah.fromJson(responseData['data'])
              : null,
        );
      } else {
        return PesananTerbitResponse(
          sukses: false,
          pesan: _extractErrorMessage(responseData['pesan'], 'Gagal memperbarui kelengkapan'),
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error updating kelengkapan: $e');
      logger.e('StackTrace: $stackTrace');
      return PesananTerbitResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Upload bukti pembayaran
  /// PUT /api/pesanan-terbit/:id/bukti-pembayaran
  static Future<PesananTerbitResponse<PesananTerbitDetail>> uploadBuktiPembayaran(
      String id, File file) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return PesananTerbitResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/pesanan-terbit/$id/bukti-pembayaran');

      logger.d('Uploading bukti pembayaran: $url');

      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.files.add(await http.MultipartFile.fromPath(
        'buktiPembayaran',
        file.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      logger.d('Response status: ${response.statusCode}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return PesananTerbitResponse(
          sukses: true,
          pesan: _extractErrorMessage(responseData['pesan'], 'Bukti pembayaran berhasil diunggah'),
          data: responseData['data'] != null
              ? PesananTerbitDetail.fromJson(responseData['data'])
              : null,
        );
      } else {
        return PesananTerbitResponse(
          sukses: false,
          pesan: _extractErrorMessage(responseData['pesan'], 'Gagal mengunggah bukti pembayaran'),
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error uploading bukti pembayaran: $e');
      logger.e('StackTrace: $stackTrace');
      return PesananTerbitResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ============================================
  // EDITOR ENDPOINTS
  // ============================================

  /// Ambil semua daftar pesanan terbit (Editor/Admin)
  /// GET /api/pesanan-terbit
  static Future<DaftarPesananTerbitResponse> getAllPesananTerbit({
    String? status,
    String? statusPembayaran,
    int halaman = 1,
    int limit = 10,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return DaftarPesananTerbitResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
          data: [],
        );
      }

      final queryParams = <String, String>{
        'halaman': halaman.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (statusPembayaran != null && statusPembayaran.isNotEmpty) {
        queryParams['statusPembayaran'] = statusPembayaran;
      }

      final url = Uri.parse('$baseUrl/api/pesanan-terbit')
          .replace(queryParameters: queryParams);

      logger.d('Fetching all pesanan terbit: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      logger.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return DaftarPesananTerbitResponse.fromJson(responseData);
      } else {
        return DaftarPesananTerbitResponse(
          sukses: false,
          pesan: 'Gagal mengambil daftar pesanan terbit',
          data: [],
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching all pesanan terbit: $e');
      logger.e('StackTrace: $stackTrace');
      return DaftarPesananTerbitResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
        data: [],
      );
    }
  }

  /// Update status pesanan terbit (Editor/Admin)
  /// PUT /api/pesanan-terbit/:id/status
  static Future<PesananTerbitResponse<PesananTerbitDetail>> updateStatus(
      String id, UpdateStatusPesananRequest request) async {
    try {
      final accessToken = await AuthService.getAccessToken();

      if (accessToken == null) {
        return PesananTerbitResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/pesanan-terbit/$id/status');

      logger.d('Updating status pesanan terbit: $url');
      logger.d('Request body: ${request.toJson()}');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      logger.d('Response status: ${response.statusCode}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return PesananTerbitResponse(
          sukses: true,
          pesan: _extractErrorMessage(responseData['pesan'], 'Status berhasil diperbarui'),
          data: responseData['data'] != null
              ? PesananTerbitDetail.fromJson(responseData['data'])
              : null,
        );
      } else {
        return PesananTerbitResponse(
          sukses: false,
          pesan: _extractErrorMessage(responseData['pesan'], 'Gagal memperbarui status'),
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error updating status pesanan terbit: $e');
      logger.e('StackTrace: $stackTrace');
      return PesananTerbitResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ============================================
  // PAKET PENERBITAN ENDPOINTS
  // ============================================

  /// Ambil daftar paket penerbitan
  /// GET /api/paket-penerbitan
  static Future<DaftarPaketResponse> getPaketPenerbitan() async {
    try {
      final url = Uri.parse('$baseUrl/api/paket-penerbitan');

      logger.d('Fetching paket penerbitan: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        logger.d('Parsed paket data: ${responseData['data']}');
        return DaftarPaketResponse.fromJson(responseData);
      } else {
        return DaftarPaketResponse(
          sukses: false,
          pesan: 'Gagal mengambil daftar paket penerbitan',
          data: [],
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching paket penerbitan: $e');
      logger.e('StackTrace: $stackTrace');
      return DaftarPaketResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
        data: [],
      );
    }
  }
}
