import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/editor/review_models.dart';
import '../general/auth_service.dart';

/// Service untuk Review Editor
/// Menangani operasi review naskah oleh editor
class EditorReviewService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';

  /// Get detail review by ID
  /// GET /api/review/:id
  static Future<ReviewDetailResponse> getReviewById(String idReview) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return ReviewDetailResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/review/$idReview');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ReviewDetailResponse.fromJson(responseData);
      } else {
        final responseData = jsonDecode(response.body);
        return ReviewDetailResponse(
          sukses: false,
          pesan: responseData['pesan'] ?? 'Gagal mengambil detail review',
        );
      }
    } catch (e) {
      return ReviewDetailResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Update status review (Menerima naskah untuk direview)
  /// PUT /api/review/:id
  /// 
  /// Untuk mengubah status dari 'ditugaskan' menjadi 'dalam_proses'
  static Future<ReviewDetailResponse> updateReviewStatus({
    required String idReview,
    required StatusReview status,
    String? catatan,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return ReviewDetailResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/review/$idReview');

      final body = {
        'status': status.name, // Convert enum to string
      };

      if (catatan != null && catatan.isNotEmpty) {
        body['catatan'] = catatan;
      }

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ReviewDetailResponse.fromJson(responseData);
      } else {
        final responseData = jsonDecode(response.body);
        return ReviewDetailResponse(
          sukses: false,
          pesan: responseData['pesan'] ?? 'Gagal mengupdate status review',
        );
      }
    } catch (e) {
      return ReviewDetailResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Mulai review (shorthand untuk update status ke dalam_proses)
  static Future<ReviewDetailResponse> mulaiReview({
    required String idReview,
    String? catatan,
  }) async {
    return updateReviewStatus(
      idReview: idReview,
      status: StatusReview.dalam_proses,
      catatan: catatan,
    );
  }

  /// Selesaikan review dengan rekomendasi
  /// PUT /api/review/:id
  static Future<ReviewDetailResponse> selesaikanReview({
    required String idReview,
    required Rekomendasi rekomendasi,
    String? catatan,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return ReviewDetailResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/review/$idReview');

      final body = {
        'status': StatusReview.selesai.name,
        'rekomendasi': rekomendasi.name,
      };

      if (catatan != null && catatan.isNotEmpty) {
        body['catatan'] = catatan;
      }

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ReviewDetailResponse.fromJson(responseData);
      } else {
        final responseData = jsonDecode(response.body);
        return ReviewDetailResponse(
          sukses: false,
          pesan: responseData['pesan'] ?? 'Gagal menyelesaikan review',
        );
      }
    } catch (e) {
      return ReviewDetailResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}

/// Response model untuk detail review
class ReviewDetailResponse {
  final bool sukses;
  final String pesan;
  final ReviewNaskah? data;

  ReviewDetailResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory ReviewDetailResponse.fromJson(Map<String, dynamic> json) {
    return ReviewDetailResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? ReviewNaskah.fromJson(json['data']) : null,
    );
  }
}
