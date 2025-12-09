/// Editor Service - Main Service Layer untuk Editor Module
/// Menggabungkan semua fungsi review untuk kebutuhan Editor Dashboard
/// Best Practice: High-level abstraction dengan caching dan error handling

import 'package:publishify/models/editor/review_models.dart';
import 'package:publishify/models/editor/editor_models.dart';
import 'package:publishify/services/editor/editor_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(methodCount: 0, printTime: true),
);

/// Editor Service - Business Logic Layer
class EditorService {
  // Singleton pattern
  static final EditorService _instance = EditorService._internal();
  factory EditorService() => _instance;
  EditorService._internal();

  // Cache keys
  static const String _cacheKeyStats = 'editor_stats_cache';
  static const String _cacheKeyReviews = 'editor_reviews_cache';
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // =====================================================
  // REVIEW ASSIGNMENTS
  // =====================================================

  /// Get review assignments untuk editor yang login
  /// Dengan optional status filter dan limit
  static Future<List<ReviewAssignment>> getReviewAssignments({
    StatusReview? status,
    int? limit,
  }) async {
    try {
      final filter = FilterReview(
        status: status,
        limit: limit ?? 20,
        urutkan: 'ditugaskanPada',
        arah: 'desc',
      );

      final response = await EditorApiService.ambilReviewSaya(filter: filter);

      if (response.sukses && response.data != null) {
        // Convert ReviewNaskah ke ReviewAssignment untuk UI compatibility
        return response.data!.map((review) => ReviewAssignment(
          id: review.id,
          judulNaskah: review.naskah.judul,
          penulisNaskah: review.naskah.penulis.profilPengguna?.namaLengkap ?? 
                        review.naskah.penulis.email,
          tanggalDitugaskan: review.ditugaskanPada,
          batasWaktu: review.ditugaskanPada.add(const Duration(days: 14)), // Default 14 hari
          status: _convertStatus(review.status),
          progress: _calculateProgress(review).toDouble(),
          kategori: review.naskah.kategori.nama,
          jumlahHalaman: review.naskah.jumlahHalaman ?? 0,
        )).toList();
      }

      return [];
    } catch (e) {
      _logger.e('Error getting review assignments: $e');
      return [];
    }
  }

  /// Get semua review dengan pagination
  static Future<ApiResponse<List<ReviewNaskah>>> getAllReviews({
    FilterReview? filter,
  }) async {
    return EditorApiService.ambilSemuaReview(filter: filter);
  }

  /// Get review by ID untuk detail page
  static Future<ApiResponse<ReviewNaskah>> getReviewById(String id) async {
    return EditorApiService.ambilReviewById(id);
  }

  /// Get review untuk naskah tertentu
  static Future<ApiResponse<List<ReviewNaskah>>> getReviewsForNaskah(
    String idNaskah,
  ) async {
    return EditorApiService.ambilReviewNaskah(idNaskah);
  }

  // =====================================================
  // REVIEW ACTIONS
  // =====================================================

  /// Tugaskan review ke editor
  static Future<ApiResponse<ReviewNaskah>> tugaskanReview({
    required String idNaskah,
    required String idEditor,
    String? catatan,
  }) async {
    final request = TugaskanReviewRequest(
      idNaskah: idNaskah,
      idEditor: idEditor,
      catatan: catatan,
    );
    return EditorApiService.tugaskanReview(request);
  }

  /// Mulai proses review (ubah status ke dalam_proses)
  static Future<ApiResponse<ReviewNaskah>> mulaiReview(String reviewId) async {
    final request = PerbaruiReviewRequest(
      status: StatusReview.dalam_proses,
    );
    return EditorApiService.perbaruiReview(reviewId, request);
  }

  /// Update catatan review
  static Future<ApiResponse<ReviewNaskah>> updateCatatanReview(
    String reviewId,
    String catatan,
  ) async {
    final request = PerbaruiReviewRequest(catatan: catatan);
    return EditorApiService.perbaruiReview(reviewId, request);
  }

  /// Tambah feedback ke review
  static Future<ApiResponse<FeedbackReview>> tambahFeedback({
    required String reviewId,
    required String komentar,
    String? bab,
    int? halaman,
  }) async {
    final request = TambahFeedbackRequest(
      komentar: komentar,
      bab: bab,
      halaman: halaman,
    );
    return EditorApiService.tambahFeedback(reviewId, request);
  }

  /// Submit review dengan rekomendasi
  static Future<ApiResponse<ReviewNaskah>> submitReview({
    required String reviewId,
    required Rekomendasi rekomendasi,
    required String catatan,
  }) async {
    final request = SubmitReviewRequest(
      rekomendasi: rekomendasi,
      catatan: catatan,
    );
    return EditorApiService.submitReview(reviewId, request);
  }

  /// Batalkan review
  static Future<ApiResponse<ReviewNaskah>> batalkanReview({
    required String reviewId,
    required String alasan,
  }) async {
    return EditorApiService.batalkanReview(reviewId, alasan);
  }

  // =====================================================
  // STATISTICS
  // =====================================================

  /// Get statistik review editor
  static Future<EditorStats?> getEditorStats({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedStats();
        if (cached != null) return cached;
      }

      final response = await EditorApiService.ambilStatistikReview();

      if (response.sukses && response.data != null) {
        final stats = _convertToEditorStats(response.data!);
        
        // Save to cache
        await _cacheStats(stats);
        
        return stats;
      }

      return null;
    } catch (e) {
      _logger.e('Error getting editor stats: $e');
      return null;
    }
  }

  /// Get statistik review dengan response lengkap
  static Future<ApiResponse<StatistikReview>> getStatistikReview() async {
    return EditorApiService.ambilStatistikReview();
  }

  // =====================================================
  // MENU & NAVIGATION
  // =====================================================

  /// Get menu items untuk editor dashboard
  static List<Map<String, dynamic>> getEditorMenuItems() {
    return [
      {
        'icon': 'assignment_turned_in',
        'title': 'Review Naskah',
        'subtitle': 'Kelola review yang ditugaskan',
        'route': '/editor/reviews',
        'color': 0xFF4CAF50,
      },
      {
        'icon': 'rate_review',
        'title': 'Beri Feedback',
        'subtitle': 'Berikan feedback untuk penulis',
        'route': '/editor/feedback',
        'color': 0xFF2196F3,
      },
      {
        'icon': 'assignment',
        'title': 'Naskah Masuk',
        'subtitle': 'Daftar naskah untuk direview',
        'route': '/editor/naskah',
        'color': 0xFFFF9800,
      },
      {
        'icon': 'analytics',
        'title': 'Statistik Review',
        'subtitle': 'Lihat performa review Anda',
        'route': '/editor/statistics',
        'color': 0xFF9C27B0,
      },
      {
        'icon': 'notifications',
        'title': 'Notifikasi',
        'subtitle': 'Lihat update dan pengingat',
        'route': '/editor/notifications',
        'color': 0xFFE91E63,
      },
    ];
  }

  /// Get quick actions untuk dashboard
  static Future<List<Map<String, dynamic>>> getQuickActions() async {
    try {
      final stats = await getEditorStats();
      
      if (stats != null) {
        return [
          {
            'icon': 'assignment',
            'label': 'Review Baru',
            'count': stats.reviewMenunggu,
            'action': 'new_reviews',
            'color': 0xFF2196F3,
          },
          {
            'icon': 'schedule',
            'label': 'Dalam Proses',
            'count': stats.reviewDalamProses,
            'action': 'in_progress',
            'color': 0xFFFF9800,
          },
          {
            'icon': 'done_all',
            'label': 'Selesai',
            'count': stats.reviewSelesai,
            'action': 'completed',
            'color': 0xFF4CAF50,
          },
          {
            'icon': 'star',
            'label': 'Rating',
            'count': stats.ratingRataRata.toInt(),
            'action': 'rating',
            'color': 0xFFFFD700,
          },
        ];
      }

      return [];
    } catch (e) {
      _logger.e('Error getting quick actions: $e');
      return [];
    }
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================

  /// Convert StatusReview to string untuk UI
  static String _convertStatus(StatusReview status) {
    switch (status) {
      case StatusReview.ditugaskan:
        return 'Menunggu';
      case StatusReview.dalam_proses:
        return 'Dalam Proses';
      case StatusReview.selesai:
        return 'Selesai';
      case StatusReview.dibatalkan:
        return 'Dibatalkan';
    }
  }

  /// Calculate progress percentage dari review
  static int _calculateProgress(ReviewNaskah review) {
    switch (review.status) {
      case StatusReview.ditugaskan:
        return 0;
      case StatusReview.dalam_proses:
        // Calculate based on feedback count
        final feedbackCount = review.feedback.length;
        if (feedbackCount == 0) return 10;
        if (feedbackCount < 3) return 30;
        if (feedbackCount < 5) return 60;
        return 80;
      case StatusReview.selesai:
        return 100;
      case StatusReview.dibatalkan:
        return 0;
    }
  }

  /// Convert StatistikReview to EditorStats untuk UI compatibility
  static EditorStats _convertToEditorStats(StatistikReview stats) {
    return EditorStats.fromStatistikReview(stats);
  }

  // =====================================================
  // CACHE MANAGEMENT
  // =====================================================

  /// Get cached stats
  static Future<EditorStats?> _getCachedStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKeyStats);
      final timestamp = prefs.getInt('${_cacheKeyStats}_timestamp');

      if (cached != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) < _cacheExpiry) {
          return EditorStats.fromJson(json.decode(cached));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save stats to cache
  static Future<void> _cacheStats(EditorStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeyStats, json.encode(stats.toJson()));
      await prefs.setInt('${_cacheKeyStats}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _logger.e('Error caching stats: $e');
    }
  }

  /// Clear all editor cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyStats);
      await prefs.remove('${_cacheKeyStats}_timestamp');
      await prefs.remove(_cacheKeyReviews);
      await prefs.remove('${_cacheKeyReviews}_timestamp');
    } catch (e) {
      _logger.e('Error clearing cache: $e');
    }
  }
}
