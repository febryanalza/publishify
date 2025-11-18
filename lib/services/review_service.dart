import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/models/review_models.dart';
import 'package:publishify/services/auth_service.dart';

/// Review Service
/// Handles all review related API calls
/// Khusus untuk user PENULIS - untuk melihat review/feedback dari naskah mereka
class ReviewService {
  // Get base URL from .env
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:4000';

  /// Get detail review by ID (including all feedback)
  /// GET /api/review/:id
  /// 
  /// Endpoint ini bisa diakses oleh:
  /// - Editor yang ditugaskan
  /// - Penulis naskah
  /// - Admin
  static Future<ReviewDetailResponse> getReviewById(String idReview) async {
    try {
      // Get access token from cache
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return ReviewDetailResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/review/$idReview');

      // Make API request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final responseData = jsonDecode(response.body);
      return ReviewDetailResponse.fromJson(responseData);
    } catch (e) {
      // Return error response
      return ReviewDetailResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Update review status or notes
  /// PUT /api/review/:id
  /// 
  /// Untuk penulis: biasanya tidak bisa update review
  /// Tapi bisa digunakan untuk respond feedback (future feature)
  static Future<ReviewDetailResponse> updateReview({
    required String idReview,
    String? status,
    String? catatan,
  }) async {
    try {
      // Get access token from cache
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return ReviewDetailResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final uri = Uri.parse('$baseUrl/api/review/$idReview');

      // Build request body
      final Map<String, dynamic> body = {};
      if (status != null) body['status'] = status;
      if (catatan != null) body['catatan'] = catatan;

      // Make API request
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      return ReviewDetailResponse.fromJson(responseData);
    } catch (e) {
      // Return error response
      return ReviewDetailResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Get all reviews for current user's manuscripts
  /// Untuk penulis: ambil semua naskah mereka, lalu ambil review untuk setiap naskah
  /// 
  /// Note: Backend tidak memiliki endpoint khusus untuk ini,
  /// jadi kita perlu kombinasi dari:
  /// 1. GET /api/naskah/penulis/saya (ambil semua naskah penulis)
  /// 2. GET /api/review/naskah/:idNaskah (untuk setiap naskah)
  static Future<ReviewListResponse> getAllReviewsForMyManuscripts({
    int halaman = 1,
    int limit = 20,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return ReviewListResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      // Get all user's manuscripts that are in review or need revision
      final naskahUri = Uri.parse('$baseUrl/api/naskah/penulis/saya')
          .replace(queryParameters: {
            'limit': '100', // Get all
            'status': 'dalam_review,perlu_revisi', // Filter by status
          });

      final naskahResponse = await http.get(
        naskahUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (naskahResponse.statusCode != 200) {
        return ReviewListResponse(
          sukses: false,
          pesan: 'Gagal mengambil data naskah',
        );
      }

      final naskahData = jsonDecode(naskahResponse.body);
      final List<dynamic>? naskahList = naskahData['data'];

      if (naskahList == null || naskahList.isEmpty) {
        return ReviewListResponse(
          sukses: true,
          pesan: 'Tidak ada naskah dalam review',
          data: [],
        );
      }

      // Collect all reviews from all manuscripts
      List<ReviewData> allReviews = [];

      for (var naskah in naskahList) {
        final idNaskah = naskah['id'];
        
        // Get reviews for this manuscript
        final reviewUri = Uri.parse('$baseUrl/api/review/naskah/$idNaskah')
            .replace(queryParameters: {
              'limit': '100', // Get all reviews for this manuscript
            });

        final reviewResponse = await http.get(
          reviewUri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (reviewResponse.statusCode == 200) {
          final reviewData = jsonDecode(reviewResponse.body);
          if (reviewData['data'] != null) {
            final List<dynamic> reviews = reviewData['data'];
            allReviews.addAll(
              reviews.map((r) => ReviewData.fromJson(r)).toList(),
            );
          }
        }
      }

      // Sort by most recent
      allReviews.sort((a, b) => 
        b.diperbaruiPada.compareTo(a.diperbaruiPada)
      );

      // Apply pagination
      final startIndex = (halaman - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedReviews = allReviews.sublist(
        startIndex,
        endIndex > allReviews.length ? allReviews.length : endIndex,
      );

      return ReviewListResponse(
        sukses: true,
        pesan: 'Data review berhasil diambil',
        data: paginatedReviews,
        metadata: MetaData(
          total: allReviews.length,
          halaman: halaman,
          limit: limit,
          totalHalaman: (allReviews.length / limit).ceil(),
        ),
      );
    } catch (e) {
      return ReviewListResponse(
        sukses: false,
        pesan: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Get review count by status for current user
  static Future<Map<String, int>> getReviewCountByStatus() async {
    try {
      final response = await getAllReviewsForMyManuscripts(limit: 100);
      
      if (!response.sukses || response.data == null) {
        return {
          'ditugaskan': 0,
          'dalam_proses': 0,
          'selesai': 0,
          'dibatalkan': 0,
        };
      }

      // Count by status
      final Map<String, int> statusCount = {
        'ditugaskan': 0,
        'dalam_proses': 0,
        'selesai': 0,
        'dibatalkan': 0,
      };

      for (var review in response.data!) {
        final status = review.status.toLowerCase();
        if (statusCount.containsKey(status)) {
          statusCount[status] = statusCount[status]! + 1;
        }
      }

      return statusCount;
    } catch (e) {
      return {
        'ditugaskan': 0,
        'dalam_proses': 0,
        'selesai': 0,
        'dibatalkan': 0,
      };
    }
  }

  /// Helper: Get status label in Indonesian
  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'ditugaskan':
        return 'Ditugaskan';
      case 'dalam_proses':
        return 'Dalam Proses';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  /// Helper: Get recommendation label in Indonesian
  static String getRekomendasiLabel(String? rekomendasi) {
    if (rekomendasi == null) return '-';
    
    switch (rekomendasi.toLowerCase()) {
      case 'setujui':
        return 'Disetujui';
      case 'revisi':
        return 'Perlu Revisi';
      case 'tolak':
        return 'Ditolak';
      default:
        return rekomendasi;
    }
  }

  /// Helper: Get status color
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ditugaskan':
        return 'blue';
      case 'dalam_proses':
        return 'orange';
      case 'selesai':
        return 'green';
      case 'dibatalkan':
        return 'red';
      default:
        return 'grey';
    }
  }
}
