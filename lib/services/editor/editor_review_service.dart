/// Editor Review Service - Dedicated Service untuk Review Operations
/// Service khusus untuk operasi review: feedback, submit, batal
/// Best Practice: Single responsibility untuk review workflow

import 'package:publishify/models/editor/review_models.dart';
import 'package:publishify/services/editor/editor_api_service.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(methodCount: 0, printTime: true),
);

/// Response wrapper untuk review operations
class ReviewOperationResult {
  final bool sukses;
  final String pesan;
  final ReviewNaskah? review;
  final FeedbackReview? feedback;

  ReviewOperationResult({
    required this.sukses,
    required this.pesan,
    this.review,
    this.feedback,
  });

  factory ReviewOperationResult.success(String pesan, {ReviewNaskah? review, FeedbackReview? feedback}) {
    return ReviewOperationResult(sukses: true, pesan: pesan, review: review, feedback: feedback);
  }

  factory ReviewOperationResult.error(String pesan) {
    return ReviewOperationResult(sukses: false, pesan: pesan);
  }
}

/// Editor Review Service - Review Workflow Management
class EditorReviewService {
  // Singleton pattern
  static final EditorReviewService _instance = EditorReviewService._internal();
  factory EditorReviewService() => _instance;
  EditorReviewService._internal();

  // =====================================================
  // REVIEW LIFECYCLE
  // =====================================================

  /// Ambil detail review lengkap
  static Future<ApiResponse<ReviewNaskah>> ambilDetailReview(String reviewId) async {
    try {
      return await EditorApiService.ambilReviewById(reviewId);
    } catch (e) {
      _logger.e('Error ambilDetailReview: $e');
      return ApiResponse.error('Gagal mengambil detail review');
    }
  }

  /// Mulai proses review - ubah status dari ditugaskan ke dalam_proses
  static Future<ReviewOperationResult> mulaiReview(String reviewId) async {
    try {
      final request = PerbaruiReviewRequest(
        status: StatusReview.dalam_proses,
      );

      final response = await EditorApiService.perbaruiReview(reviewId, request);

      if (response.sukses) {
        return ReviewOperationResult.success(
          'Review berhasil dimulai',
          review: response.data,
        );
      } else {
        return ReviewOperationResult.error(response.pesan);
      }
    } catch (e) {
      _logger.e('Error mulaiReview: $e');
      return ReviewOperationResult.error('Gagal memulai review');
    }
  }

  /// Update catatan/progress review
  static Future<ReviewOperationResult> updateReview({
    required String reviewId,
    String? catatan,
    StatusReview? status,
  }) async {
    try {
      final request = PerbaruiReviewRequest(
        catatan: catatan,
        status: status,
      );

      final response = await EditorApiService.perbaruiReview(reviewId, request);

      if (response.sukses) {
        return ReviewOperationResult.success(
          'Review berhasil diperbarui',
          review: response.data,
        );
      } else {
        return ReviewOperationResult.error(response.pesan);
      }
    } catch (e) {
      _logger.e('Error updateReview: $e');
      return ReviewOperationResult.error('Gagal memperbarui review');
    }
  }

  // =====================================================
  // FEEDBACK MANAGEMENT
  // =====================================================

  /// Tambah feedback ke review
  static Future<ReviewOperationResult> tambahFeedback({
    required String reviewId,
    required String komentar,
    String? bab,
    int? halaman,
  }) async {
    try {
      // Validasi minimal 10 karakter
      if (komentar.length < 10) {
        return ReviewOperationResult.error('Komentar minimal 10 karakter');
      }

      final request = TambahFeedbackRequest(
        komentar: komentar,
        bab: bab,
        halaman: halaman,
      );

      final response = await EditorApiService.tambahFeedback(reviewId, request);

      if (response.sukses) {
        return ReviewOperationResult.success(
          'Feedback berhasil ditambahkan',
          feedback: response.data,
        );
      } else {
        return ReviewOperationResult.error(response.pesan);
      }
    } catch (e) {
      _logger.e('Error tambahFeedback: $e');
      return ReviewOperationResult.error('Gagal menambah feedback');
    }
  }

  /// Tambah feedback dengan lokasi (bab dan halaman)
  /// Backend hanya mendukung: bab, halaman, komentar
  static Future<ReviewOperationResult> tambahFeedbackDenganLokasi({
    required String reviewId,
    required String komentar,
    String? bab,
    int? halaman,
  }) async {
    try {
      if (komentar.length < 10) {
        return ReviewOperationResult.error('Komentar minimal 10 karakter');
      }

      final request = TambahFeedbackRequest(
        komentar: komentar,
        bab: bab,
        halaman: halaman,
      );

      final response = await EditorApiService.tambahFeedback(reviewId, request);

      if (response.sukses) {
        return ReviewOperationResult.success(
          'Feedback berhasil ditambahkan',
          feedback: response.data,
        );
      } else {
        return ReviewOperationResult.error(response.pesan);
      }
    } catch (e) {
      _logger.e('Error tambahFeedbackDenganLokasi: $e');
      return ReviewOperationResult.error('Gagal menambah feedback');
    }
  }

  // =====================================================
  // REVIEW SUBMISSION
  // =====================================================

  /// Submit review dengan rekomendasi SETUJUI
  static Future<ReviewOperationResult> setujuiNaskah({
    required String reviewId,
    required String catatan,
  }) async {
    return _submitReviewDenganRekomendasi(
      reviewId: reviewId,
      rekomendasi: Rekomendasi.setujui,
      catatan: catatan,
    );
  }

  /// Submit review dengan rekomendasi REVISI
  static Future<ReviewOperationResult> mintaRevisi({
    required String reviewId,
    required String catatan,
  }) async {
    return _submitReviewDenganRekomendasi(
      reviewId: reviewId,
      rekomendasi: Rekomendasi.revisi,
      catatan: catatan,
    );
  }

  /// Submit review dengan rekomendasi TOLAK
  static Future<ReviewOperationResult> tolakNaskah({
    required String reviewId,
    required String catatan,
  }) async {
    return _submitReviewDenganRekomendasi(
      reviewId: reviewId,
      rekomendasi: Rekomendasi.tolak,
      catatan: catatan,
    );
  }

  /// Internal: Submit review dengan rekomendasi
  static Future<ReviewOperationResult> _submitReviewDenganRekomendasi({
    required String reviewId,
    required Rekomendasi rekomendasi,
    required String catatan,
  }) async {
    try {
      // Validasi catatan minimal 50 karakter
      if (catatan.length < 50) {
        return ReviewOperationResult.error('Catatan kesimpulan minimal 50 karakter');
      }

      final request = SubmitReviewRequest(
        rekomendasi: rekomendasi,
        catatan: catatan,
      );

      final response = await EditorApiService.submitReview(reviewId, request);

      if (response.sukses) {
        final rekomendasiLabel = _getRekomendasiLabel(rekomendasi);
        return ReviewOperationResult.success(
          'Review berhasil disubmit dengan rekomendasi: $rekomendasiLabel',
          review: response.data,
        );
      } else {
        return ReviewOperationResult.error(response.pesan);
      }
    } catch (e) {
      _logger.e('Error submitReview: $e');
      return ReviewOperationResult.error('Gagal submit review');
    }
  }

  /// Submit review dengan pilihan rekomendasi
  static Future<ReviewOperationResult> submitReview({
    required String reviewId,
    required Rekomendasi rekomendasi,
    required String catatan,
  }) async {
    return _submitReviewDenganRekomendasi(
      reviewId: reviewId,
      rekomendasi: rekomendasi,
      catatan: catatan,
    );
  }

  // =====================================================
  // REVIEW CANCELLATION
  // =====================================================

  /// Batalkan review dengan alasan
  static Future<ReviewOperationResult> batalkanReview({
    required String reviewId,
    required String alasan,
  }) async {
    try {
      if (alasan.isEmpty) {
        return ReviewOperationResult.error('Alasan pembatalan wajib diisi');
      }

      final response = await EditorApiService.batalkanReview(reviewId, alasan);

      if (response.sukses) {
        return ReviewOperationResult.success(
          'Review berhasil dibatalkan',
          review: response.data,
        );
      } else {
        return ReviewOperationResult.error(response.pesan);
      }
    } catch (e) {
      _logger.e('Error batalkanReview: $e');
      return ReviewOperationResult.error('Gagal membatalkan review');
    }
  }

  // =====================================================
  // REVIEW QUERY
  // =====================================================

  /// Ambil review yang ditugaskan ke editor saya
  static Future<ApiResponse<List<ReviewNaskah>>> ambilReviewSaya({
    StatusReview? status,
    int halaman = 1,
    int limit = 20,
  }) async {
    try {
      final filter = FilterReview(
        halaman: halaman,
        limit: limit,
        status: status,
        urutkan: 'ditugaskanPada',
        arah: 'desc',
      );

      return await EditorApiService.ambilReviewSaya(filter: filter);
    } catch (e) {
      _logger.e('Error ambilReviewSaya: $e');
      return ApiResponse.error('Gagal mengambil daftar review');
    }
  }

  /// Ambil review berdasarkan status
  static Future<ApiResponse<List<ReviewNaskah>>> ambilReviewByStatus(
    StatusReview status, {
    int halaman = 1,
    int limit = 20,
  }) async {
    return ambilReviewSaya(status: status, halaman: halaman, limit: limit);
  }

  /// Ambil review yang sedang dalam proses
  static Future<ApiResponse<List<ReviewNaskah>>> ambilReviewDalamProses() async {
    return ambilReviewByStatus(StatusReview.dalam_proses);
  }

  /// Ambil review yang menunggu dikerjakan
  static Future<ApiResponse<List<ReviewNaskah>>> ambilReviewMenunggu() async {
    return ambilReviewByStatus(StatusReview.ditugaskan);
  }

  /// Ambil review yang sudah selesai
  static Future<ApiResponse<List<ReviewNaskah>>> ambilReviewSelesai({
    int halaman = 1,
    int limit = 20,
  }) async {
    return ambilReviewByStatus(StatusReview.selesai, halaman: halaman, limit: limit);
  }

  /// Ambil review untuk naskah tertentu
  static Future<ApiResponse<List<ReviewNaskah>>> ambilReviewNaskah(
    String idNaskah,
  ) async {
    try {
      return await EditorApiService.ambilReviewNaskah(idNaskah);
    } catch (e) {
      _logger.e('Error ambilReviewNaskah: $e');
      return ApiResponse.error('Gagal mengambil review naskah');
    }
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================

  /// Get label untuk rekomendasi
  static String _getRekomendasiLabel(Rekomendasi rekomendasi) {
    switch (rekomendasi) {
      case Rekomendasi.setujui:
        return 'Disetujui';
      case Rekomendasi.revisi:
        return 'Perlu Revisi';
      case Rekomendasi.tolak:
        return 'Ditolak';
    }
  }

  /// Get label untuk status review
  static String getStatusLabel(StatusReview status) {
    switch (status) {
      case StatusReview.ditugaskan:
        return 'Ditugaskan';
      case StatusReview.dalam_proses:
        return 'Dalam Proses';
      case StatusReview.selesai:
        return 'Selesai';
      case StatusReview.dibatalkan:
        return 'Dibatalkan';
    }
  }

  /// Get warna untuk status review
  static int getStatusColor(StatusReview status) {
    switch (status) {
      case StatusReview.ditugaskan:
        return 0xFF2196F3; // Blue
      case StatusReview.dalam_proses:
        return 0xFFFF9800; // Orange
      case StatusReview.selesai:
        return 0xFF4CAF50; // Green
      case StatusReview.dibatalkan:
        return 0xFFF44336; // Red
    }
  }

  /// Get warna untuk rekomendasi
  static int getRekomendasiColor(Rekomendasi rekomendasi) {
    switch (rekomendasi) {
      case Rekomendasi.setujui:
        return 0xFF4CAF50; // Green
      case Rekomendasi.revisi:
        return 0xFFFF9800; // Orange
      case Rekomendasi.tolak:
        return 0xFFF44336; // Red
    }
  }

  /// Cek apakah review masih bisa diedit
  static bool canEditReview(StatusReview status) {
    return status == StatusReview.ditugaskan || 
           status == StatusReview.dalam_proses;
  }

  /// Cek apakah review sudah bisa di-submit
  static bool canSubmitReview(ReviewNaskah review) {
    // Review harus dalam proses dan sudah ada minimal 1 feedback
    return review.status == StatusReview.dalam_proses && 
           review.feedback.isNotEmpty;
  }

  /// Cek apakah review bisa dibatalkan
  static bool canCancelReview(StatusReview status) {
    // Hanya bisa dibatalkan jika masih dalam proses atau ditugaskan
    return status == StatusReview.ditugaskan || 
           status == StatusReview.dalam_proses;
  }
}
