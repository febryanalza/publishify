import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/models/percetakan/percetakan_models.dart';
import 'package:publishify/services/general/auth_service.dart';

class PercetakanService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';

  /// Ambil daftar pesanan untuk percetakan
  /// Endpoint khusus untuk role percetakan: GET /api/percetakan/pesanan/percetakan
  /// Parameter status: 'baru' | 'produksi' | 'pengiriman' | 'selesai'
  static Future<PesananListResponse> ambilDaftarPesanan({
    String? status,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      // Build URI dengan query parameter status (opsional)
      final Map<String, String> queryParams = {};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/api/percetakan/pesanan/percetakan')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PesananListResponse.fromJson(responseData);
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Ambil detail pesanan berdasarkan ID
  static Future<PesananDetailResponse> ambilDetailPesanan(String idPesanan) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$baseUrl/api/percetakan/$idPesanan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PesananDetailResponse.fromJson(responseData);
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Perbarui status pesanan
  static Future<PesananDetailResponse> perbaruiStatusPesanan(
    String idPesanan,
    String statusBaru, {
    String? catatan,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final Map<String, dynamic> requestData = {
        'statusBaru': statusBaru,
      };

      if (catatan != null && catatan.isNotEmpty) {
        requestData['catatan'] = catatan;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/percetakan/$idPesanan/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PesananDetailResponse.fromJson(responseData);
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Konfirmasi pesanan (terima atau tolak)
  static Future<PesananDetailResponse> konfirmasiPesanan(
    String idPesanan, {
    required bool diterima,
    double? hargaTotal,
    DateTime? estimasiSelesai,
    String? catatan,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final Map<String, dynamic> requestData = {
        'diterima': diterima,
      };

      if (hargaTotal != null) {
        requestData['hargaTotal'] = hargaTotal;
      }

      if (estimasiSelesai != null) {
        requestData['estimasiSelesai'] = estimasiSelesai.toIso8601String();
      }

      if (catatan != null && catatan.isNotEmpty) {
        requestData['catatan'] = catatan;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/percetakan/$idPesanan/konfirmasi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PesananDetailResponse.fromJson(responseData);
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Buat data pengiriman untuk pesanan
  /// POST /api/percetakan/:id/pengiriman
  static Future<PesananDetailResponse> buatPengiriman(
    String idPesanan, {
    required String alamatTujuan,
    required String namaPenerima,
    required String teleponPenerima,
    String? namaEkspedisi,
    String? nomorResi,
    String? catatan,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final Map<String, dynamic> requestData = {
        'alamatTujuan': alamatTujuan,
        'namaPenerima': namaPenerima,
        'teleponPenerima': teleponPenerima,
      };

      if (namaEkspedisi != null && namaEkspedisi.isNotEmpty) {
        requestData['namaEkspedisi'] = namaEkspedisi;
      }

      if (nomorResi != null && nomorResi.isNotEmpty) {
        requestData['nomorResi'] = nomorResi;
      }

      if (catatan != null && catatan.isNotEmpty) {
        requestData['catatan'] = catatan;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/percetakan/$idPesanan/pengiriman'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PesananDetailResponse.fromJson(responseData);
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Ambil statistik percetakan
  static Future<StatsResponse> ambilStatistik() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$baseUrl/api/percetakan/statistik'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return StatsResponse.fromJson(responseData);
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get menu items untuk dashboard
  static List<Map<String, dynamic>> ambilMenuItems() {
    return [
      {
        'judul': 'Pesanan Baru',
        'subjudul': 'Pesanan yang belum diproses',
        'icon': 'inbox',
        'warna': 'blue',
        'route': '/percetakan/pesanan/tertunda',
        'badge': 0,
      },
      {
        'judul': 'Dalam Produksi',
        'subjudul': 'Pesanan sedang dikerjakan',
        'icon': 'print',
        'warna': 'orange',
        'route': '/percetakan/pesanan/produksi',
        'badge': 0,
      },
      {
        'judul': 'Kontrol Kualitas',
        'subjudul': 'Periksa hasil cetak',
        'icon': 'check_circle',
        'warna': 'purple',
        'route': '/percetakan/pesanan/qc',
        'badge': 0,
      },
      {
        'judul': 'Siap Kirim',
        'subjudul': 'Pesanan siap dikirim',
        'icon': 'local_shipping',
        'warna': 'green',
        'route': '/percetakan/pesanan/siap',
        'badge': 0,
      },
      {
        'judul': 'Statistik',
        'subjudul': 'Laporan dan analisis',
        'icon': 'analytics',
        'warna': 'indigo',
        'route': '/percetakan/statistik',
        'badge': 0,
      },
    ];
  }

  /// Get label status
  static Map<String, String> ambilLabelStatus() {
    return {
      'tertunda': 'Tertunda',
      'diterima': 'Diterima',
      'dalam_produksi': 'Dalam Produksi',
      'kontrol_kualitas': 'Kontrol Kualitas',
      'siap': 'Siap',
      'dikirim': 'Dikirim',
      'terkirim': 'Terkirim',
      'dibatalkan': 'Dibatalkan',
    };
  }

  /// Get warna status
  static Map<String, String> ambilWarnaStatus() {
    return {
      'tertunda': 'grey',
      'diterima': 'blue',
      'dalam_produksi': 'orange',
      'kontrol_kualitas': 'purple',
      'siap': 'green',
      'dikirim': 'teal',
      'terkirim': 'green',
      'dibatalkan': 'red',
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
      1: 'Januari', 2: 'Februari', 3: 'Maret', 4: 'April',
      5: 'Mei', 6: 'Juni', 7: 'Juli', 8: 'Agustus',
      9: 'September', 10: 'Oktober', 11: 'November', 12: 'Desember',
    };
    
    return '${tanggal.day} ${bulan[tanggal.month]} ${tanggal.year}';
  }

  /// Format tanggal dengan waktu
  static String formatTanggalWaktu(DateTime tanggal) {
    final String tgl = formatTanggal(tanggal);
    final String jam = '${tanggal.hour.toString().padLeft(2, '0')}:${tanggal.minute.toString().padLeft(2, '0')}';
    return '$tgl pukul $jam';
  }
}
