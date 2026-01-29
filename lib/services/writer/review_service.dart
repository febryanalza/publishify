import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  /// 
  /// Strategi: 
  /// 1. Ambil daftar naskah milik penulis yang bukan draft
  /// 2. Untuk setiap naskah, ambil review menggunakan GET /api/review/naskah/:idNaskah
  /// 
  /// Backend endpoint yang digunakan:
  /// - GET /api/naskah/penulis/saya (untuk ambil daftar naskah)
  /// - GET /api/review/naskah/:idNaskah (untuk ambil review per naskah)
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

      // Step 1: Ambil daftar naskah penulis (yang sudah diajukan atau lebih)
      // Naskah dengan status: diajukan, dalam_review, dalam_editing, siap_terbit, diterbitkan
      final naskahUri = Uri.parse('$baseUrl/api/naskah/penulis/saya')
          .replace(queryParameters: {
            'halaman': '1',
            'limit': '100', // Ambil semua naskah
          });

      final naskahResponse = await http.get(
        naskahUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (naskahResponse.statusCode != 200) {
        debugPrint('ReviewService: Gagal mengambil naskah - Status: ${naskahResponse.statusCode}');
        return ReviewListResponse(
          sukses: false,
          pesan: 'Gagal mengambil data naskah: ${naskahResponse.statusCode}',
        );
      }

      final naskahData = jsonDecode(naskahResponse.body);
      final List<dynamic> naskahList = naskahData['data'] ?? [];
      
      debugPrint('ReviewService: Ditemukan ${naskahList.length} naskah');

      if (naskahList.isEmpty) {
        return ReviewListResponse(
          sukses: true,
          pesan: 'Belum ada naskah',
          data: [],
        );
      }

      // Step 2: Untuk setiap naskah, ambil review-nya
      List<ReviewData> allReviews = [];

      for (var naskah in naskahList) {
        final idNaskah = naskah['id'];
        if (idNaskah == null) continue;

        // Skip naskah dengan status draft (belum ada review)
        final naskahStatus = naskah['status']?.toString().toLowerCase() ?? '';
        if (naskahStatus == 'draft') continue;

        try {
          // Build query params untuk filter status jika ada
          final queryParams = <String, String>{
            'halaman': '1',
            'limit': '50',
          };
          if (status != null && status.isNotEmpty && status != 'semua') {
            queryParams['status'] = status;
          }

          final reviewUri = Uri.parse('$baseUrl/api/review/naskah/$idNaskah')
              .replace(queryParameters: queryParams);

          final reviewResponse = await http.get(
            reviewUri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          );

          if (reviewResponse.statusCode == 200) {
            final reviewData = jsonDecode(reviewResponse.body);
            if (reviewData['sukses'] == true && reviewData['data'] != null) {
              final List<dynamic> reviews = reviewData['data'];
              for (var review in reviews) {
                allReviews.add(ReviewData.fromJson(review));
              }
            }
          }
        } catch (e) {
          // Continue to next naskah if error
          continue;
        }
      }

      // Sort by ditugaskanPada descending (newest first)
      allReviews.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.ditugaskanPada);
          final dateB = DateTime.parse(b.ditugaskanPada);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      final result = ReviewListResponse(
        sukses: true,
        pesan: 'Berhasil mengambil data review',
        data: allReviews,
        metadata: MetaData(
          total: allReviews.length,
          halaman: halaman,
          limit: limit,
          totalHalaman: 1,
        ),
      );
      
      // Cache data (if halaman 1 and successful)
      if (halaman == 1 && result.sukses && result.data != null) {
        await _cacheReviews(result);
      }
      
      return result;
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
