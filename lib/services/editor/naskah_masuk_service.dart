import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/models/editor/review_models.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:publishify/services/writer/notifikasi_service.dart';



final _logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

/// Naskah Masuk Service - Refactored untuk Review API
/// Handle operations untuk review yang ditugaskan ke editor
class NaskahMasukService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';

  /// Ambil semua review yang ditugaskan kepada editor yang sedang login
  /// GET /api/review/editor/saya
  static Future<ReviewResponse<List<ReviewNaskah>>> ambilNaskahMasuk({
    int halaman = 1,
    int limit = 100,
    StatusReview? status,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return ReviewResponse<List<ReviewNaskah>>(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final queryParams = {
        'halaman': halaman.toString(),
        'limit': limit.toString(),
      };

      // Tambahkan filter status jika ada
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final uri = Uri.parse('$baseUrl/api/review/editor/saya')
          .replace(queryParameters: queryParams);

      logger.i('📡 [NaskahMasukService] GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      _logger.i('📊 [NaskahMasukService] Status Code: ${response.statusCode}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _logger.i('✅ [NaskahMasukService] Success: ${responseData['pesan']}');
        
        return ReviewResponse<List<ReviewNaskah>>(
          sukses: responseData['sukses'],
          pesan: responseData['pesan'],
          data: (responseData['data'] as List<dynamic>)
              .map((item) => ReviewNaskah.fromJson(item))
              .toList(),
          metadata: responseData['metadata'],
        );
      } else {
        logger.i('❌ [NaskahMasukService] Error: ${responseData['pesan']}');
        return ReviewResponse<List<ReviewNaskah>>(
          sukses: false,
          pesan: responseData['pesan'] ?? 'Gagal mengambil review yang ditugaskan',
        );
      }
    } catch (e) {
      logger.i('💥 [NaskahMasukService] Exception: $e');
      return ReviewResponse<List<ReviewNaskah>>(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Ambil detail review by ID
  /// GET /api/review/:id
  static Future<ReviewResponse<ReviewNaskah>> ambilDetailReview(String idReview) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return ReviewResponse<ReviewNaskah>(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/review/$idReview');

      logger.i('📡 [NaskahMasukService] GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      logger.i('📊 [NaskahMasukService] Status Code: ${response.statusCode}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        logger.i('✅ [NaskahMasukService] Success: ${responseData['pesan']}');
        
        return ReviewResponse<ReviewNaskah>(
          sukses: responseData['sukses'],
          pesan: responseData['pesan'],
          data: ReviewNaskah.fromJson(responseData['data']),
        );
      } else {
        logger.i('❌ [NaskahMasukService] Error: ${responseData['pesan']}');
        return ReviewResponse<ReviewNaskah>(
          sukses: false,
          pesan: responseData['pesan'] ?? 'Gagal mengambil detail review',
        );
      }
    } catch (e) {
      logger.i('💥 [NaskahMasukService] Exception: $e');
      return ReviewResponse<ReviewNaskah>(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
