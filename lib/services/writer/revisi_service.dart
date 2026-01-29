import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/services/writer/upload_service.dart';
import 'package:publishify/services/writer/naskah_service.dart';
import 'package:publishify/models/writer/naskah_models.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

/// Service untuk mengelola revisi naskah
class RevisiService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';

  /// Submit revisi naskah dengan file baru
  /// POST /api/naskah/:idNaskah/submit-revisi
  static Future<SubmitRevisiResponse> submitRevisi({
    required String idNaskah,
    required File fileNaskahBaru,
    String? catatan,
  }) async {
    try {
      // Step 1: Upload file naskah baru
      _logger.d('Mengupload file naskah untuk revisi...');
      final uploadResponse = await UploadService.uploadNaskah(
        file: fileNaskahBaru,
        deskripsi: 'File revisi naskah',
        idReferensi: idNaskah,
      );

      if (!uploadResponse.sukses || uploadResponse.data == null) {
        return SubmitRevisiResponse(
          sukses: false,
          pesan: 'Gagal mengupload file: ${uploadResponse.pesan}',
        );
      }

      final urlFileNaskah = uploadResponse.data!.url;
      _logger.d('File berhasil diupload: $urlFileNaskah');

      // Step 2: Submit revisi ke backend menggunakan NaskahService
      final result = await NaskahService.submitRevisi(
        idNaskah: idNaskah,
        urlFileNaskah: urlFileNaskah,
        catatan: catatan,
      );
      
      return result;
    } catch (e) {
      _logger.e('Error submit revisi: $e');
      return SubmitRevisiResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Dapatkan daftar revisi naskah
  static Future<DaftarRevisiResponse> getDaftarRevisi({
    required String idNaskah,
    int halaman = 1,
    int limit = 10,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return DaftarRevisiResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
          data: [],
        );
      }

      final queryParams = {
        'halaman': halaman.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/naskah/$idNaskah/revisi')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      _logger.d('Get daftar revisi response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return DaftarRevisiResponse.fromJson(responseData);
      } else {
        return DaftarRevisiResponse(
          sukses: false,
          pesan: 'Gagal memuat daftar revisi',
          data: [],
        );
      }
    } catch (e) {
      _logger.e('Error get daftar revisi: $e');
      return DaftarRevisiResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
        data: [],
      );
    }
  }
}

// Models
class DaftarRevisiResponse {
  final bool sukses;
  final String pesan;
  final List<RevisiNaskahData> data;
  final Map<String, dynamic>? metadata;

  DaftarRevisiResponse({
    required this.sukses,
    required this.pesan,
    required this.data,
    this.metadata,
  });

  factory DaftarRevisiResponse.fromJson(Map<String, dynamic> json) {
    return DaftarRevisiResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => RevisiNaskahData.fromJson(e))
              .toList() ??
          [],
      metadata: json['metadata'],
    );
  }
}

