/// Editor Statistik Service - Service untuk Statistik Review
/// Dedicated service untuk statistik dan analytics editor
/// Best Practice: Data transformation dan caching

import 'package:publishify/models/editor/review_models.dart';
import 'package:publishify/services/editor/editor_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(methodCount: 0, printTime: true),
);

/// Model untuk statistik review yang sudah di-transform untuk UI
class StatistikReviewData {
  final int totalReview;
  final int reviewDitugaskan;
  final int reviewDalamProses;
  final int reviewSelesai;
  final int reviewDibatalkan;
  final int rekomendasiSetujui;
  final int rekomendasiRevisi;
  final int rekomendasiTolak;
  final int rataRataHariReview;
  final double tingkatPenyelesaian;
  final double tingkatPersetujuan;
  final List<ReviewTerbaru> reviewTerbaru;

  StatistikReviewData({
    required this.totalReview,
    required this.reviewDitugaskan,
    required this.reviewDalamProses,
    required this.reviewSelesai,
    required this.reviewDibatalkan,
    required this.rekomendasiSetujui,
    required this.rekomendasiRevisi,
    required this.rekomendasiTolak,
    required this.rataRataHariReview,
    required this.tingkatPenyelesaian,
    required this.tingkatPersetujuan,
    required this.reviewTerbaru,
  });

  factory StatistikReviewData.fromStatistikReview(StatistikReview stats) {
    final totalSelesai = stats.perStatus['selesai'] ?? 0;
    final totalDenganRekomendasi = (stats.perRekomendasi['setujui'] ?? 0) +
        (stats.perRekomendasi['revisi'] ?? 0) +
        (stats.perRekomendasi['tolak'] ?? 0);

    return StatistikReviewData(
      totalReview: stats.totalReview,
      reviewDitugaskan: stats.perStatus['ditugaskan'] ?? 0,
      reviewDalamProses: stats.perStatus['dalam_proses'] ?? 0,
      reviewSelesai: totalSelesai,
      reviewDibatalkan: stats.perStatus['dibatalkan'] ?? 0,
      rekomendasiSetujui: stats.perRekomendasi['setujui'] ?? 0,
      rekomendasiRevisi: stats.perRekomendasi['revisi'] ?? 0,
      rekomendasiTolak: stats.perRekomendasi['tolak'] ?? 0,
      rataRataHariReview: stats.rataRataHariReview,
      tingkatPenyelesaian: stats.totalReview > 0
          ? (totalSelesai / stats.totalReview * 100)
          : 0.0,
      tingkatPersetujuan: totalDenganRekomendasi > 0
          ? ((stats.perRekomendasi['setujui'] ?? 0) / totalDenganRekomendasi * 100)
          : 0.0,
      reviewTerbaru: stats.reviewTerbaru,
    );
  }

  factory StatistikReviewData.fromJson(Map<String, dynamic> json) {
    return StatistikReviewData(
      totalReview: json['totalReview'] ?? 0,
      reviewDitugaskan: json['reviewDitugaskan'] ?? 0,
      reviewDalamProses: json['reviewDalamProses'] ?? 0,
      reviewSelesai: json['reviewSelesai'] ?? 0,
      reviewDibatalkan: json['reviewDibatalkan'] ?? 0,
      rekomendasiSetujui: json['rekomendasiSetujui'] ?? 0,
      rekomendasiRevisi: json['rekomendasiRevisi'] ?? 0,
      rekomendasiTolak: json['rekomendasiTolak'] ?? 0,
      rataRataHariReview: json['rataRataHariReview'] ?? 0,
      tingkatPenyelesaian: (json['tingkatPenyelesaian'] ?? 0.0).toDouble(),
      tingkatPersetujuan: (json['tingkatPersetujuan'] ?? 0.0).toDouble(),
      reviewTerbaru: (json['reviewTerbaru'] as List<dynamic>?)
              ?.map((e) => ReviewTerbaru.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReview': totalReview,
      'reviewDitugaskan': reviewDitugaskan,
      'reviewDalamProses': reviewDalamProses,
      'reviewSelesai': reviewSelesai,
      'reviewDibatalkan': reviewDibatalkan,
      'rekomendasiSetujui': rekomendasiSetujui,
      'rekomendasiRevisi': rekomendasiRevisi,
      'rekomendasiTolak': rekomendasiTolak,
      'rataRataHariReview': rataRataHariReview,
      'tingkatPenyelesaian': tingkatPenyelesaian,
      'tingkatPersetujuan': tingkatPersetujuan,
      'reviewTerbaru': reviewTerbaru.map((e) => e.toJson()).toList(),
    };
  }

  /// Get review aktif (ditugaskan + dalam proses)
  int get reviewAktif => reviewDitugaskan + reviewDalamProses;

  /// Get total dengan rekomendasi
  int get totalDenganRekomendasi =>
      rekomendasiSetujui + rekomendasiRevisi + rekomendasiTolak;

  /// Getter untuk kompatibilitas dengan halaman UI yang menggunakan perStatus
  _PerStatusData get perStatus => _PerStatusData(
    ditugaskan: reviewDitugaskan,
    dalamProses: reviewDalamProses,
    selesai: reviewSelesai,
    dibatalkan: reviewDibatalkan,
    total: totalReview,
  );

  /// Getter untuk kompatibilitas dengan halaman UI yang menggunakan perRekomendasi
  _PerRekomendasiData get perRekomendasi => _PerRekomendasiData(
    setujui: rekomendasiSetujui,
    revisi: rekomendasiRevisi,
    tolak: rekomendasiTolak,
    total: totalDenganRekomendasi,
  );
}

/// Helper class untuk data status
class _PerStatusData {
  final int ditugaskan;
  final int dalamProses;
  final int selesai;
  final int dibatalkan;
  final int total;

  _PerStatusData({
    required this.ditugaskan,
    required this.dalamProses,
    required this.selesai,
    required this.dibatalkan,
    required this.total,
  });
}

/// Helper class untuk data rekomendasi
class _PerRekomendasiData {
  final int setujui;
  final int revisi;
  final int tolak;
  final int total;

  _PerRekomendasiData({
    required this.setujui,
    required this.revisi,
    required this.tolak,
    required this.total,
  });
}

/// Response untuk statistik
class StatistikResponse {
  final bool sukses;
  final String? pesan;
  final StatistikReviewData? data;

  StatistikResponse({
    required this.sukses,
    this.pesan,
    this.data,
  });

  factory StatistikResponse.success(StatistikReviewData data) {
    return StatistikResponse(sukses: true, data: data);
  }

  factory StatistikResponse.error(String pesan) {
    return StatistikResponse(sukses: false, pesan: pesan);
  }
}

/// Editor Statistik Service
class EditorStatistikService {
  // Singleton
  static final EditorStatistikService _instance = EditorStatistikService._internal();
  factory EditorStatistikService() => _instance;
  EditorStatistikService._internal();

  // Cache configuration
  static const String _cacheKey = 'editor_statistik_cache';
  static const Duration _cacheExpiry = Duration(minutes: 10);

  // =====================================================
  // MAIN STATISTICS METHODS
  // =====================================================

  /// Ambil statistik review - dengan caching
  static Future<StatistikResponse> ambilStatistikReview({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache jika tidak force refresh
      if (!forceRefresh) {
        final cached = await _getCachedStatistik();
        if (cached != null) {
          return StatistikResponse.success(cached);
        }
      }

      // Fetch from API
      final response = await EditorApiService.ambilStatistikReview();

      if (response.sukses && response.data != null) {
        // Transform ke StatistikReviewData
        final statsData = StatistikReviewData.fromStatistikReview(response.data!);
        
        // Cache hasil
        await _cacheStatistik(statsData);
        
        return StatistikResponse.success(statsData);
      } else {
        return StatistikResponse.error(response.pesan);
      }
    } catch (e) {
      _logger.e('Error ambilStatistikReview: $e');
      return StatistikResponse.error('Gagal mengambil statistik review');
    }
  }

  /// Ambil statistik raw dari API
  static Future<ApiResponse<StatistikReview>> ambilStatistikRaw() async {
    return EditorApiService.ambilStatistikReview();
  }

  // =====================================================
  // DASHBOARD STATS
  // =====================================================

  /// Get ringkasan statistik untuk dashboard cards
  static Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await ambilStatistikReview();

      if (response.sukses && response.data != null) {
        final stats = response.data!;
        
        return {
          'totalReview': stats.totalReview,
          'reviewAktif': stats.reviewAktif,
          'reviewSelesai': stats.reviewSelesai,
          'tingkatPenyelesaian': stats.tingkatPenyelesaian,
          'rataRataHari': stats.rataRataHariReview,
        };
      }

      return null;
    } catch (e) {
      _logger.e('Error getDashboardStats: $e');
      return null;
    }
  }

  /// Get data untuk chart distribusi status
  static Future<List<Map<String, dynamic>>?> getStatusDistribution() async {
    try {
      final response = await ambilStatistikReview();

      if (response.sukses && response.data != null) {
        final stats = response.data!;
        
        return [
          {
            'label': 'Ditugaskan',
            'value': stats.reviewDitugaskan,
            'color': 0xFF2196F3,
          },
          {
            'label': 'Dalam Proses',
            'value': stats.reviewDalamProses,
            'color': 0xFFFF9800,
          },
          {
            'label': 'Selesai',
            'value': stats.reviewSelesai,
            'color': 0xFF4CAF50,
          },
          {
            'label': 'Dibatalkan',
            'value': stats.reviewDibatalkan,
            'color': 0xFFF44336,
          },
        ];
      }

      return null;
    } catch (e) {
      _logger.e('Error getStatusDistribution: $e');
      return null;
    }
  }

  /// Get data untuk chart distribusi rekomendasi
  static Future<List<Map<String, dynamic>>?> getRekomendasiDistribution() async {
    try {
      final response = await ambilStatistikReview();

      if (response.sukses && response.data != null) {
        final stats = response.data!;
        
        return [
          {
            'label': 'Disetujui',
            'value': stats.rekomendasiSetujui,
            'color': 0xFF4CAF50,
          },
          {
            'label': 'Revisi',
            'value': stats.rekomendasiRevisi,
            'color': 0xFFFF9800,
          },
          {
            'label': 'Ditolak',
            'value': stats.rekomendasiTolak,
            'color': 0xFFF44336,
          },
        ];
      }

      return null;
    } catch (e) {
      _logger.e('Error getRekomendasiDistribution: $e');
      return null;
    }
  }

  /// Get review terbaru untuk display
  static Future<List<ReviewTerbaru>?> getReviewTerbaru({int limit = 5}) async {
    try {
      final response = await ambilStatistikReview();

      if (response.sukses && response.data != null) {
        final reviews = response.data!.reviewTerbaru;
        return reviews.take(limit).toList();
      }

      return null;
    } catch (e) {
      _logger.e('Error getReviewTerbaru: $e');
      return null;
    }
  }

  // =====================================================
  // PERFORMANCE METRICS
  // =====================================================

  /// Get performance summary
  static Future<Map<String, dynamic>?> getPerformanceSummary() async {
    try {
      final response = await ambilStatistikReview();

      if (response.sukses && response.data != null) {
        final stats = response.data!;
        
        return {
          'tingkatPenyelesaian': {
            'value': stats.tingkatPenyelesaian,
            'label': '${stats.tingkatPenyelesaian.toStringAsFixed(1)}%',
            'status': _getPerformanceStatus(stats.tingkatPenyelesaian),
          },
          'tingkatPersetujuan': {
            'value': stats.tingkatPersetujuan,
            'label': '${stats.tingkatPersetujuan.toStringAsFixed(1)}%',
            'status': _getPerformanceStatus(stats.tingkatPersetujuan),
          },
          'rataRataWaktu': {
            'value': stats.rataRataHariReview,
            'label': '${stats.rataRataHariReview} hari',
            'status': stats.rataRataHariReview <= 7 ? 'baik' : 
                     stats.rataRataHariReview <= 14 ? 'sedang' : 'perlu_perbaikan',
          },
          'reviewAktif': {
            'value': stats.reviewAktif,
            'label': '${stats.reviewAktif} review',
            'status': 'info',
          },
        };
      }

      return null;
    } catch (e) {
      _logger.e('Error getPerformanceSummary: $e');
      return null;
    }
  }

  /// Helper: Get performance status
  static String _getPerformanceStatus(double percentage) {
    if (percentage >= 80) return 'baik';
    if (percentage >= 60) return 'sedang';
    return 'perlu_perbaikan';
  }

  // =====================================================
  // CACHE MANAGEMENT
  // =====================================================

  /// Get cached statistik
  static Future<StatistikReviewData?> _getCachedStatistik() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt('${_cacheKey}_timestamp');

      if (cached != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) < _cacheExpiry) {
          return StatistikReviewData.fromJson(json.decode(cached));
        }
      }
      return null;
    } catch (e) {
      _logger.e('Error getting cached statistik: $e');
      return null;
    }
  }

  /// Cache statistik
  static Future<void> _cacheStatistik(StatistikReviewData stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(stats.toJson()));
      await prefs.setInt('${_cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _logger.e('Error caching statistik: $e');
    }
  }

  /// Clear cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove('${_cacheKey}_timestamp');
    } catch (e) {
      _logger.e('Error clearing cache: $e');
    }
  }
}
