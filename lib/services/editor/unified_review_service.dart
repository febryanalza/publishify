/// Unified Review Service - Consolidated Service untuk Review Operations
/// Best Practice: Single source of truth dengan caching dan batch loading
/// 
/// Menggabungkan fungsi dari:
/// - ReviewNaskahService
/// - ReviewCollectionService  
/// - EditorReviewService
/// 
/// Keunggulan:
/// - Caching dengan TTL
/// - Batch loading (data + stats dalam 1 call)
/// - Debouncing untuk multiple requests
/// - Memory efficient

import 'dart:async';
import 'package:publishify/models/editor/review_models.dart';
import 'package:publishify/models/editor/review_naskah_models.dart';
import 'package:publishify/services/editor/editor_api_service.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

/// Cache Entry dengan timestamp
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry(this.data, {this.ttl = const Duration(minutes: 5)})
      : timestamp = DateTime.now();

  bool get isValid => DateTime.now().difference(timestamp) < ttl;
}

/// Response gabungan untuk halaman review
class ReviewPageData {
  final List<NaskahSubmission> naskahList;
  final Map<String, int> statusCount;
  final bool fromCache;
  final String? error;

  ReviewPageData({
    required this.naskahList,
    required this.statusCount,
    this.fromCache = false,
    this.error,
  });

  factory ReviewPageData.empty() => ReviewPageData(
        naskahList: [],
        statusCount: {},
      );

  factory ReviewPageData.error(String message) => ReviewPageData(
        naskahList: [],
        statusCount: {},
        error: message,
      );

  bool get hasError => error != null;
  bool get isEmpty => naskahList.isEmpty;
}

/// Unified Review Service dengan Caching
class UnifiedReviewService {
  // Singleton
  static final UnifiedReviewService _instance = UnifiedReviewService._internal();
  factory UnifiedReviewService() => _instance;
  UnifiedReviewService._internal();

  // Cache storage
  static CacheEntry<List<ReviewNaskah>>? _reviewsCache;
  static CacheEntry<Map<String, int>>? _statsCache;
  static CacheEntry<List<Map<String, dynamic>>>? _editorsCache;

  // Debounce timer untuk mencegah multiple calls
  static Timer? _debounceTimer;
  static Completer<ReviewPageData>? _pendingRequest;

  // Cache TTL configuration
  static const Duration cacheTTL = Duration(minutes: 5);

  // =====================================================
  // MAIN DATA LOADING - BATCH FETCH
  // =====================================================

  /// Load semua data yang dibutuhkan halaman review dalam 1 batch
  /// Best Practice: Mengurangi jumlah API calls
  static Future<ReviewPageData> loadReviewPageData({
    String? status,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    // Gunakan debounce untuk mencegah multiple calls
    if (_pendingRequest != null && !forceRefresh) {
      return _pendingRequest!.future;
    }

    _pendingRequest = Completer<ReviewPageData>();

    try {
      // Check cache first jika tidak force refresh
      if (!forceRefresh) {
        final cachedData = _getCachedPageData(status);
        if (cachedData != null) {
          _pendingRequest!.complete(cachedData);
          _pendingRequest = null;
          return cachedData;
        }
      }

      // Fetch data secara parallel
      final results = await Future.wait([
        _fetchReviews(status: status, limit: limit),
        _fetchStats(),
      ]);

      final reviews = results[0] as List<ReviewNaskah>;
      final stats = results[1] as Map<String, int>;

      // Convert ke NaskahSubmission
      final naskahList = reviews
          .map((review) => NaskahSubmission.fromReviewNaskah(review))
          .toList();

      // Update cache
      _reviewsCache = CacheEntry(reviews);
      _statsCache = CacheEntry(stats);

      final pageData = ReviewPageData(
        naskahList: naskahList,
        statusCount: stats,
      );

      _pendingRequest!.complete(pageData);
      _pendingRequest = null;
      return pageData;
    } catch (e) {
      _logger.e('Error loadReviewPageData: $e');
      final errorData = ReviewPageData.error('Terjadi kesalahan: $e');
      _pendingRequest!.complete(errorData);
      _pendingRequest = null;
      return errorData;
    }
  }

  /// Get cached page data jika masih valid
  static ReviewPageData? _getCachedPageData(String? status) {
    if (_reviewsCache != null &&
        _reviewsCache!.isValid &&
        _statsCache != null &&
        _statsCache!.isValid) {
      
      var reviews = _reviewsCache!.data;
      
      // Filter by status if needed
      if (status != null && status != 'semua') {
        final statusEnum = _parseStatus(status);
        if (statusEnum != null) {
          reviews = reviews.where((r) => r.status == statusEnum).toList();
        }
      }

      final naskahList = reviews
          .map((review) => NaskahSubmission.fromReviewNaskah(review))
          .toList();

      return ReviewPageData(
        naskahList: naskahList,
        statusCount: _statsCache!.data,
        fromCache: true,
      );
    }
    return null;
  }

  // =====================================================
  // INDIVIDUAL FETCH METHODS (Private)
  // =====================================================

  /// Fetch reviews dari API
  static Future<List<ReviewNaskah>> _fetchReviews({
    String? status,
    int limit = 20,
  }) async {
    final filter = FilterReview(
      status: _parseStatus(status),
      limit: limit,
      urutkan: 'ditugaskanPada',
      arah: 'desc',
    );

    final response = await EditorApiService.ambilReviewSaya(filter: filter);
    return response.data ?? [];
  }

  /// Fetch statistik dari API
  static Future<Map<String, int>> _fetchStats() async {
    final response = await EditorApiService.ambilStatistikReview();

    if (response.sukses && response.data != null) {
      final stats = response.data!;
      return {
        'semua': stats.totalReview,
        'ditugaskan': stats.perStatus['ditugaskan'] ?? 0,
        'dalam_proses': stats.perStatus['dalam_proses'] ?? 0,
        'selesai': stats.perStatus['selesai'] ?? 0,
        'dibatalkan': stats.perStatus['dibatalkan'] ?? 0,
      };
    }
    return {};
  }

  // =====================================================
  // STATUS COUNT (dengan cache)
  // =====================================================

  /// Get status count - gunakan cache jika tersedia
  static Future<Map<String, int>> getStatusCount({
    bool forceRefresh = false,
  }) async {
    // Return from cache if valid
    if (!forceRefresh && _statsCache != null && _statsCache!.isValid) {
      return _statsCache!.data;
    }

    final stats = await _fetchStats();
    _statsCache = CacheEntry(stats);
    return stats;
  }

  // =====================================================
  // NASKAH LIST (dengan cache)
  // =====================================================

  /// Get naskah submissions - gunakan cache jika tersedia
  static Future<NaskahSubmissionResponse> getNaskahSubmissions({
    String? status,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache
      if (!forceRefresh && _reviewsCache != null && _reviewsCache!.isValid) {
        var reviews = _reviewsCache!.data;
        
        // Filter by status if needed
        if (status != null && status != 'semua') {
          final statusEnum = _parseStatus(status);
          if (statusEnum != null) {
            reviews = reviews.where((r) => r.status == statusEnum).toList();
          }
        }

        final submissions = reviews
            .map((review) => NaskahSubmission.fromReviewNaskah(review))
            .toList();

        return NaskahSubmissionResponse.success(
          submissions,
          pesan: 'Data dari cache',
        );
      }

      // Fetch fresh data
      final reviews = await _fetchReviews(status: status, limit: limit);
      
      // Update cache (only for full fetch without status filter)
      if (status == null || status == 'semua') {
        _reviewsCache = CacheEntry(reviews);
      }

      final submissions = reviews
          .map((review) => NaskahSubmission.fromReviewNaskah(review))
          .toList();

      return NaskahSubmissionResponse.success(
        submissions,
        pesan: 'Data berhasil dimuat',
      );
    } catch (e) {
      _logger.e('Error getNaskahSubmissions: $e');
      return NaskahSubmissionResponse.error('Terjadi kesalahan: $e');
    }
  }

  // =====================================================
  // DETAIL NASKAH (tanpa cache - selalu fresh)
  // =====================================================

  /// Get detail naskah by ID
  static Future<DetailNaskahResponse> getDetailNaskah(String id) async {
    try {
      final response = await EditorApiService.ambilReviewNaskah(id);

      if (response.sukses && response.data != null && response.data!.isNotEmpty) {
        final detail = DetailNaskahSubmission.fromReviewNaskah(response.data!.first);
        return DetailNaskahResponse.success(detail);
      }

      return DetailNaskahResponse.error('Naskah tidak ditemukan');
    } catch (e) {
      _logger.e('Error getDetailNaskah: $e');
      return DetailNaskahResponse.error('Terjadi kesalahan: $e');
    }
  }

  // =====================================================
  // REVIEW ACTIONS
  // =====================================================

  /// Terima review - mulai proses review
  static Future<ActionResponse> terimaReview(String idNaskah, String idEditor) async {
    try {
      // Get review ID from naskah
      final reviewResponse = await EditorApiService.ambilReviewNaskah(idNaskah);

      if (!reviewResponse.sukses ||
          reviewResponse.data == null ||
          reviewResponse.data!.isEmpty) {
        return ActionResponse.error('Review tidak ditemukan untuk naskah ini');
      }

      final review = reviewResponse.data!.first;
      final request = PerbaruiReviewRequest(
        status: StatusReview.dalam_proses,
      );

      final updateResponse = await EditorApiService.perbaruiReview(review.id, request);

      if (updateResponse.sukses) {
        // Invalidate cache setelah action
        _invalidateCache();
        return ActionResponse.success('Review berhasil diterima');
      }

      return ActionResponse.error(updateResponse.pesan);
    } catch (e) {
      _logger.e('Error terimaReview: $e');
      return ActionResponse.error('Terjadi kesalahan: $e');
    }
  }

  /// Tugaskan ke editor lain
  static Future<ActionResponse> tugaskanEditor(
    String idNaskah,
    String idEditor,
    String alasan,
  ) async {
    try {
      final request = TugaskanReviewRequest(
        idNaskah: idNaskah,
        idEditor: idEditor,
        catatan: alasan,
      );

      final response = await EditorApiService.tugaskanReview(request);

      if (response.sukses) {
        _invalidateCache();
        return ActionResponse.success('Naskah berhasil ditugaskan');
      }

      return ActionResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error tugaskanEditor: $e');
      return ActionResponse.error('Terjadi kesalahan: $e');
    }
  }

  /// Submit review dengan rekomendasi
  static Future<ActionResponse> submitReview({
    required String reviewId,
    required Rekomendasi rekomendasi,
    required String catatan,
  }) async {
    try {
      final request = SubmitReviewRequest(
        rekomendasi: rekomendasi,
        catatan: catatan,
      );

      final response = await EditorApiService.submitReview(reviewId, request);

      if (response.sukses) {
        _invalidateCache();
        return ActionResponse.success(_getSubmitMessage(rekomendasi));
      }

      return ActionResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error submitReview: $e');
      return ActionResponse.error('Terjadi kesalahan: $e');
    }
  }

  static String _getSubmitMessage(Rekomendasi rekomendasi) {
    switch (rekomendasi) {
      case Rekomendasi.setujui:
        return 'Naskah berhasil disetujui';
      case Rekomendasi.revisi:
        return 'Permintaan revisi berhasil dikirim';
      case Rekomendasi.tolak:
        return 'Naskah berhasil ditolak';
    }
  }

  // =====================================================
  // EDITOR LIST (dengan cache)
  // =====================================================

  /// Get daftar editor yang tersedia
  static Future<EditorTersediaResponse> getEditorTersedia({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache
      if (!forceRefresh && _editorsCache != null && _editorsCache!.isValid) {
        final editors = _editorsCache!.data
            .map((e) => EditorTersedia.fromJson(e))
            .toList();
        return EditorTersediaResponse.success(editors);
      }

      final response = await EditorApiService.ambilDaftarEditor();

      if (response.sukses && response.data != null) {
        _editorsCache = CacheEntry(response.data!, ttl: const Duration(minutes: 10));
        
        final editors = response.data!
            .map((e) => EditorTersedia.fromJson(e))
            .toList();
        return EditorTersediaResponse.success(editors);
      }

      return EditorTersediaResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error getEditorTersedia: $e');
      return EditorTersediaResponse.error('Gagal mengambil daftar editor');
    }
  }

  // =====================================================
  // SEARCH (Client-side filtering dari cache)
  // =====================================================

  /// Search naskah by keyword
  static Future<NaskahSubmissionResponse> searchNaskah(String keyword) async {
    try {
      // Pastikan cache terisi
      if (_reviewsCache == null || !_reviewsCache!.isValid) {
        await _fetchReviews(limit: 100);
      }

      final keywordLower = keyword.toLowerCase();
      final reviews = _reviewsCache?.data ?? [];

      final filtered = reviews
          .map((review) => NaskahSubmission.fromReviewNaskah(review))
          .where((naskah) =>
              naskah.judul.toLowerCase().contains(keywordLower) ||
              naskah.penulis.toLowerCase().contains(keywordLower) ||
              naskah.kategori.toLowerCase().contains(keywordLower) ||
              naskah.genre.toLowerCase().contains(keywordLower))
          .toList();

      return NaskahSubmissionResponse.success(
        filtered,
        pesan: '${filtered.length} naskah ditemukan',
      );
    } catch (e) {
      _logger.e('Error searchNaskah: $e');
      return NaskahSubmissionResponse.error('Terjadi kesalahan: $e');
    }
  }

  // =====================================================
  // CACHE MANAGEMENT
  // =====================================================

  /// Invalidate semua cache
  static void _invalidateCache() {
    _reviewsCache = null;
    _statsCache = null;
    _logger.d('Cache invalidated');
  }

  /// Clear all cache (public method)
  static void clearCache() {
    _reviewsCache = null;
    _statsCache = null;
    _editorsCache = null;
    _debounceTimer?.cancel();
    _pendingRequest = null;
    _logger.d('All cache cleared');
  }

  /// Preload cache untuk performance
  static Future<void> preloadCache() async {
    await loadReviewPageData(forceRefresh: true);
  }

  // =====================================================
  // HELPERS
  // =====================================================

  /// Parse status string ke enum
  static StatusReview? _parseStatus(String? status) {
    if (status == null || status == 'semua') return null;

    switch (status.toLowerCase()) {
      case 'ditugaskan':
        return StatusReview.ditugaskan;
      case 'dalam_proses':
        return StatusReview.dalam_proses;
      case 'selesai':
        return StatusReview.selesai;
      case 'dibatalkan':
        return StatusReview.dibatalkan;
      default:
        return null;
    }
  }
}
