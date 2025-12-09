/// Review Naskah Service - Service untuk Naskah Submissions
/// Mengelola naskah yang disubmit untuk direview
/// Best Practice: Integration dengan EditorApiService

import 'package:publishify/models/editor/review_naskah_models.dart';
import 'package:publishify/models/editor/review_models.dart';
import 'package:publishify/services/editor/editor_api_service.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(methodCount: 0, printTime: true),
);

/// Service untuk mengelola Naskah Submission Review
class ReviewNaskahService {
  // Singleton
  static final ReviewNaskahService _instance = ReviewNaskahService._internal();
  factory ReviewNaskahService() => _instance;
  ReviewNaskahService._internal();

  // =====================================================
  // GET NASKAH SUBMISSIONS
  // =====================================================

  /// Get daftar naskah yang disubmit untuk direview
  /// Filter berdasarkan status: semua, diajukan, dalam_review, perlu_revisi
  static Future<NaskahSubmissionResponse> getNaskahSubmissions({
    String? status,
    int limit = 20,
  }) async {
    try {
      // Gunakan API review untuk mendapatkan naskah yang ditugaskan
      final filter = FilterReview(
        status: _parseStatus(status),
        limit: limit,
        urutkan: 'ditugaskanPada',
        arah: 'desc',
      );

      final response = await EditorApiService.ambilReviewSaya(filter: filter);

      if (response.sukses && response.data != null) {
        final submissions = response.data!
            .map((review) => NaskahSubmission.fromReviewNaskah(review))
            .toList();

        return NaskahSubmissionResponse.success(
          submissions,
          pesan: 'Data naskah berhasil dimuat',
        );
      }

      return NaskahSubmissionResponse.error(
        response.pesan ?? 'Gagal memuat data naskah',
      );
    } catch (e) {
      _logger.e('Error getNaskahSubmissions: $e');
      return NaskahSubmissionResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Parse status string ke enum
  static StatusReview? _parseStatus(String? status) {
    if (status == null || status == 'semua') return null;
    
    switch (status.toLowerCase()) {
      case 'ditugaskan': return StatusReview.ditugaskan;
      case 'dalam_proses': return StatusReview.dalam_proses;
      case 'selesai': return StatusReview.selesai;
      case 'dibatalkan': return StatusReview.dibatalkan;
      default: return null;
    }
  }

  // =====================================================
  // STATUS COUNT
  // =====================================================

  /// Get jumlah naskah per status
  static Future<Map<String, int>> getStatusCount() async {
    try {
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
    } catch (e) {
      _logger.e('Error getStatusCount: $e');
      return {};
    }
  }

  // =====================================================
  // REVIEW ACTIONS
  // =====================================================

  /// Terima review - mulai proses review
  static Future<ActionResponse> terimaReview(String idNaskah, String idEditor) async {
    try {
      // Update status review ke dalam_proses
      final request = PerbaruiReviewRequest(
        status: StatusReview.dalam_proses,
      );

      // Cari review ID dari naskah
      final reviewResponse = await EditorApiService.ambilReviewNaskah(idNaskah);
      
      if (!reviewResponse.sukses || reviewResponse.data == null || reviewResponse.data!.isEmpty) {
        return ActionResponse.error('Review tidak ditemukan untuk naskah ini');
      }

      final review = reviewResponse.data!.first;
      final updateResponse = await EditorApiService.perbaruiReview(review.id, request);

      if (updateResponse.sukses) {
        return ActionResponse.success('Review berhasil diterima');
      }

      return ActionResponse.error(updateResponse.pesan ?? 'Gagal menerima review');
    } catch (e) {
      _logger.e('Error terimaReview: $e');
      return ActionResponse.error('Terjadi kesalahan: ${e.toString()}');
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
        return ActionResponse.success('Naskah berhasil ditugaskan ke editor lain');
      }

      return ActionResponse.error(response.pesan ?? 'Gagal menugaskan review');
    } catch (e) {
      _logger.e('Error tugaskanEditor: $e');
      return ActionResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Mulai review naskah
  static Future<ActionResponse> mulaiReview(String reviewId) async {
    try {
      final request = PerbaruiReviewRequest(
        status: StatusReview.dalam_proses,
      );

      final response = await EditorApiService.perbaruiReview(reviewId, request);

      if (response.sukses) {
        return ActionResponse.success('Review berhasil dimulai');
      }

      return ActionResponse.error(response.pesan ?? 'Gagal memulai review');
    } catch (e) {
      _logger.e('Error mulaiReview: $e');
      return ActionResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Tolak naskah
  static Future<ActionResponse> tolakNaskah(
    String reviewId,
    String alasan,
  ) async {
    try {
      final request = SubmitReviewRequest(
        rekomendasi: Rekomendasi.tolak,
        catatan: alasan,
      );

      final response = await EditorApiService.submitReview(reviewId, request);

      if (response.sukses) {
        return ActionResponse.success('Naskah berhasil ditolak');
      }

      return ActionResponse.error(response.pesan ?? 'Gagal menolak naskah');
    } catch (e) {
      _logger.e('Error tolakNaskah: $e');
      return ActionResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Setujui naskah
  static Future<ActionResponse> setujuiNaskah(
    String reviewId,
    String catatan,
  ) async {
    try {
      final request = SubmitReviewRequest(
        rekomendasi: Rekomendasi.setujui,
        catatan: catatan,
      );

      final response = await EditorApiService.submitReview(reviewId, request);

      if (response.sukses) {
        return ActionResponse.success('Naskah berhasil disetujui');
      }

      return ActionResponse.error(response.pesan ?? 'Gagal menyetujui naskah');
    } catch (e) {
      _logger.e('Error setujuiNaskah: $e');
      return ActionResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Minta revisi
  static Future<ActionResponse> mintaRevisi(
    String reviewId,
    String catatan,
  ) async {
    try {
      final request = SubmitReviewRequest(
        rekomendasi: Rekomendasi.revisi,
        catatan: catatan,
      );

      final response = await EditorApiService.submitReview(reviewId, request);

      if (response.sukses) {
        return ActionResponse.success('Permintaan revisi berhasil dikirim');
      }

      return ActionResponse.error(response.pesan ?? 'Gagal mengirim permintaan revisi');
    } catch (e) {
      _logger.e('Error mintaRevisi: $e');
      return ActionResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // =====================================================
  // DETAIL & SEARCH
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
      return DetailNaskahResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get detail naskah sederhana (nullable)
  static Future<NaskahSubmission?> getNaskahDetail(String id) async {
    try {
      final response = await EditorApiService.ambilReviewNaskah(id);

      if (response.sukses && response.data != null && response.data!.isNotEmpty) {
        return NaskahSubmission.fromReviewNaskah(response.data!.first);
      }

      return null;
    } catch (e) {
      _logger.e('Error getNaskahDetail: $e');
      return null;
    }
  }

  /// Search naskah by keyword
  /// Note: Filtering dilakukan di client side karena API tidak support search
  static Future<NaskahSubmissionResponse> searchNaskah(String keyword) async {
    try {
      final filter = FilterReview(
        limit: 100, // Get more for client-side filtering
      );

      final response = await EditorApiService.ambilReviewSaya(filter: filter);

      if (response.sukses && response.data != null) {
        final keywordLower = keyword.toLowerCase();
        final submissions = response.data!
            .map((review) => NaskahSubmission.fromReviewNaskah(review))
            .where((naskah) =>
                naskah.judul.toLowerCase().contains(keywordLower) ||
                naskah.penulis.toLowerCase().contains(keywordLower) ||
                naskah.kategori.toLowerCase().contains(keywordLower) ||
                naskah.genre.toLowerCase().contains(keywordLower))
            .toList();

        return NaskahSubmissionResponse.success(
          submissions,
          pesan: '${submissions.length} naskah ditemukan',
        );
      }

      return NaskahSubmissionResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error searchNaskah: $e');
      return NaskahSubmissionResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // =====================================================
  // EDITOR TERSEDIA
  // =====================================================

  /// Get daftar editor yang tersedia untuk ditugaskan
  static Future<EditorTersediaResponse> getEditorTersedia() async {
    try {
      final response = await EditorApiService.ambilDaftarEditor();
      
      if (response.sukses && response.data != null) {
        final editors = response.data!
            .map((e) => EditorTersedia.fromJson(e))
            .toList();
        return EditorTersediaResponse.success(editors);
      }
      
      return EditorTersediaResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error getEditorTersedia: $e');
      return EditorTersediaResponse.error('Gagal mengambil daftar editor: ${e.toString()}');
    }
  }
}
