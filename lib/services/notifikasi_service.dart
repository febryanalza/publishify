import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:publishify/models/notifikasi_models.dart';

class NotifikasiService {
  static final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';

  // Helper untuk mendapatkan token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // Helper untuk membuat headers dengan auth
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/notifikasi
  /// Ambil daftar notifikasi dengan filter dan pagination
  static Future<NotifikasiListResponse> getNotifikasi({
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

      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return NotifikasiListResponse.fromJson(jsonResponse);
      } else {
        return NotifikasiListResponse(
          sukses: false,
          pesan: jsonResponse['pesan'] ?? 'Gagal mengambil notifikasi',
        );
      }
    } catch (e) {
      return NotifikasiListResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// GET /api/notifikasi/:id
  /// Ambil detail notifikasi berdasarkan ID
  static Future<NotifikasiResponse> getNotifikasiById(String id) async {
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

  // Helper untuk mendapatkan icon berdasarkan tipe
  static String getTipeIcon(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'sukses':
        return '✅';
      case 'peringatan':
        return '⚠️';
      case 'error':
        return '❌';
      case 'info':
      default:
        return 'ℹ️';
    }
  }

  // Helper untuk mendapatkan label tipe
  static String getTipeLabel(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'sukses':
        return 'Sukses';
      case 'peringatan':
        return 'Peringatan';
      case 'error':
        return 'Error';
      case 'info':
      default:
        return 'Info';
    }
  }
}
