import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:publishify/models/writer/review_models.dart';
import 'package:publishify/services/general/auth_service.dart';

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
  /// OPTIMIZED: Menggunakan endpoint backend yang optimal dengan single query
  /// 
  /// Backend endpoint: GET /api/review/penulis/saya
  /// - Single query dengan JOIN
  /// - Server-side pagination
  /// - 50-500x lebih cepat dari metode sebelumnya
  static Future<ReviewListResponse> getAllReviewsForMyManuscripts({
    int halaman = 1,
    int limit = 20,
    String? status,
    bool forceRefresh = false,
  }) async {
    try {
      final accessToken = await AuthService.getAccessToken();
      
      if (accessToken == null) {
        return ReviewListResponse(
          sukses: false,
          pesan: 'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      // Check cache first (if halaman 1 and not force refresh)
      if (halaman == 1 && !forceRefresh) {
        final cachedData = await _getCachedReviews();
        if (cachedData != null) {
          return cachedData;
        }
      }

      // Build query parameters
      final queryParams = {
        'halaman': halaman.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null && status.isNotEmpty && status != 'semua') {
        queryParams['status'] = status;
      }

      // OPTIMIZED: Single API call dengan endpoint khusus penulis
      final uri = Uri.parse('$baseUrl/api/review/penulis/saya')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final result = ReviewListResponse.fromJson(responseData);
        
        // Cache data (if halaman 1 and successful)
        if (halaman == 1 && result.sukses && result.data != null) {
          await _cacheReviews(result);
        }
        
        return result;
      } else if (response.statusCode == 404) {
        return ReviewListResponse(
          sukses: true,
          pesan: 'Belum ada review untuk naskah Anda',
          data: [],
        );
      } else {
        return ReviewListResponse(
          sukses: false,
          pesan: 'Gagal mengambil data review: ${response.statusCode}',
        );
      }
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

  // ========== CACHING METHODS ==========
  
  // Cache configuration
  static const String _cacheKeyReviews = 'cache_reviews_penulis';
  static const String _cacheKeyTimestamp = 'cache_reviews_timestamp';
  static const int _cacheExpiryMinutes = 5; // Cache 5 menit

  /// Get cached reviews
  static Future<ReviewListResponse?> _getCachedReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check cache timestamp
      final timestamp = prefs.getInt(_cacheKeyTimestamp);
      if (timestamp == null) return null;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);
      
      // Cache expired jika > 5 menit
      if (difference.inMinutes > _cacheExpiryMinutes) {
        await clearCache(); // Clear expired cache
        return null;
      }
      
      // Get cached data
      final cachedJson = prefs.getString(_cacheKeyReviews);
      if (cachedJson == null) return null;
      
      final data = jsonDecode(cachedJson);
      return ReviewListResponse.fromJson(data);
    } catch (e) {
      // Silent fail - caching is optional
      return null;
    }
  }

  /// Cache reviews
  static Future<void> _cacheReviews(ReviewListResponse response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save data as JSON string
      // Convert ReviewData manually tanpa toJson() karena model belum memiliki method tersebut
      final jsonData = {
        'sukses': response.sukses,
        'pesan': response.pesan,
        'data': response.data?.map((r) => {
          'id': r.id,
          'idNaskah': r.idNaskah,
          'idEditor': r.idEditor,
          'status': r.status,
          'rekomendasi': r.rekomendasi,
          'catatan': r.catatan,
          'ditugaskanPada': r.ditugaskanPada,
          'dimulaiPada': r.dimulaiPada,
          'selesaiPada': r.selesaiPada,
          'dibuatPada': r.dibuatPada,
          'diperbaruiPada': r.diperbaruiPada,
          // Naskah, editor, dan feedback tidak perlu di-cache untuk menghemat space
        }).toList(),
        'metadata': response.metadata != null ? {
          'total': response.metadata!.total,
          'halaman': response.metadata!.halaman,
          'limit': response.metadata!.limit,
          'totalHalaman': response.metadata!.totalHalaman,
        } : null,
      };
      
      final jsonString = jsonEncode(jsonData);
      
      await prefs.setString(_cacheKeyReviews, jsonString);
      await prefs.setInt(_cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silent fail - caching is optional
    }
  }

  /// Clear cache
  /// Dipanggil saat pull-to-refresh atau logout
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyReviews);
      await prefs.remove(_cacheKeyTimestamp);
    } catch (e) {
      // Silent fail
    }
  }
}
