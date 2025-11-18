import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/services/writer/auth_service.dart';

class PercetakanService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:4000';

  /// POST /api/percetakan - Buat pesanan cetak
  static Future<BuatPesananResponse> buatPesananCetak({
    required String idNaskah,
    required int jumlah,
    required String formatKertas,
    required String jenisKertas,
    required String jenisCover,
    List<String> finishingTambahan = const [],
    String? catatan,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return BuatPesananResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final url = Uri.parse('$baseUrl/api/percetakan');
      
      final body = {
        'idNaskah': idNaskah,
        'jumlah': jumlah,
        'formatKertas': formatKertas,
        'jenisKertas': jenisKertas,
        'jenisCover': jenisCover,
        'finishingTambahan': finishingTambahan,
      };

      if (catatan != null && catatan.isNotEmpty) {
        body['catatan'] = catatan;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      return BuatPesananResponse.fromJson(responseData);
    } catch (e) {
      return BuatPesananResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}

// Response model untuk buat pesanan
class BuatPesananResponse {
  final bool sukses;
  final String pesan;
  final PesananData? data;

  BuatPesananResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory BuatPesananResponse.fromJson(Map<String, dynamic> json) {
    return BuatPesananResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? PesananData.fromJson(json['data']) : null,
    );
  }
}

class PesananData {
  final String id;
  final String idNaskah;
  final String idPenulis;
  final int jumlah;
  final String formatKertas;
  final String jenisKertas;
  final String jenisCover;
  final List<String> finishingTambahan;
  final String? catatan;
  final String status;
  final String dibuatPada;
  final String diperbaruiPada;

  PesananData({
    required this.id,
    required this.idNaskah,
    required this.idPenulis,
    required this.jumlah,
    required this.formatKertas,
    required this.jenisKertas,
    required this.jenisCover,
    required this.finishingTambahan,
    this.catatan,
    required this.status,
    required this.dibuatPada,
    required this.diperbaruiPada,
  });

  factory PesananData.fromJson(Map<String, dynamic> json) {
    return PesananData(
      id: json['id'] ?? '',
      idNaskah: json['idNaskah'] ?? '',
      idPenulis: json['idPenulis'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      formatKertas: json['formatKertas'] ?? '',
      jenisKertas: json['jenisKertas'] ?? '',
      jenisCover: json['jenisCover'] ?? '',
      finishingTambahan: List<String>.from(json['finishingTambahan'] ?? []),
      catatan: json['catatan'],
      status: json['status'] ?? '',
      dibuatPada: json['dibuatPada'] ?? '',
      diperbaruiPada: json['diperbaruiPada'] ?? '',
    );
  }
}