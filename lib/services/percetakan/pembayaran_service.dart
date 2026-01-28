import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/models/percetakan/pembayaran_models.dart';
import 'package:publishify/services/general/auth_service.dart';

/// Service untuk mengelola pembayaran pesanan cetak
/// Endpoint: /api/pembayaran
class PembayaranService {
  static String get baseUrl =>
      '${dotenv.env['BASE_URL'] ?? 'http://localhost:4000'}/api/pembayaran';

  /// Ambil daftar pembayaran untuk percetakan user
  /// Simplified version untuk menghindari backend validation issues
  static Future<PembayaranListResponse> ambilDaftarPembayaran({
    String? status,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      // Minimal query params untuk menghindari backend validation error
      final Map<String, String> queryParams = {};

      // Only add status filter if provided
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      // Build URI with minimal params
      final uri = queryParams.isEmpty 
        ? Uri.parse(baseUrl)
        : Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PembayaranListResponse.fromJson(responseData);
      } else if (response.statusCode == 500) {
        // Handle internal server error gracefully
        throw Exception('Server sedang bermasalah. Silakan coba lagi nanti.');
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['pesan'] ?? errorData['message'] ?? 'Terjadi kesalahan';
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on FormatException {
      throw Exception('Format data tidak valid');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow; // Re-throw our custom exceptions
      }
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Ambil detail pembayaran berdasarkan ID
  static Future<PembayaranDetailResponse> ambilDetailPembayaran(
      String idPembayaran) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$baseUrl/$idPembayaran'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PembayaranDetailResponse.fromJson(responseData);
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Konfirmasi pembayaran (admin/percetakan)
  static Future<PembayaranDetailResponse> konfirmasiPembayaran(
    String idPembayaran, {
    required bool diterima,
    String? catatan,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final Map<String, dynamic> requestData = {
        'diterima': diterima,
      };

      if (catatan != null && catatan.isNotEmpty) {
        requestData['catatan'] = catatan;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$idPembayaran/konfirmasi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PembayaranDetailResponse.fromJson(responseData);
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Ambil statistik pembayaran
  static Future<StatistikPembayaranResponse> ambilStatistikPembayaran() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$baseUrl/statistik/ringkasan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return StatistikPembayaranResponse.fromJson(responseData);
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get label status pembayaran
  static Map<String, String> ambilLabelStatus() {
    return {
      'tertunda': 'Tertunda',
      'diproses': 'Diproses',
      'berhasil': 'Berhasil',
      'gagal': 'Gagal',
      'dikembalikan': 'Dikembalikan',
    };
  }

  /// Get warna status pembayaran
  static Map<String, String> ambilWarnaStatus() {
    return {
      'tertunda': 'orange',
      'diproses': 'blue',
      'berhasil': 'green',
      'gagal': 'red',
      'dikembalikan': 'purple',
    };
  }

  /// Get label metode pembayaran
  static Map<String, String> ambilLabelMetode() {
    return {
      'transfer_bank': 'Transfer Bank',
      'kartu_kredit': 'Kartu Kredit',
      'e_wallet': 'E-Wallet',
      'virtual_account': 'Virtual Account',
      'cod': 'COD',
    };
  }

  /// Format harga ke Rupiah
  static String formatHarga(String harga) {
    try {
      final double nilai = double.parse(harga);
      return 'Rp ${nilai.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';
    } catch (e) {
      return 'Rp 0';
    }
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
