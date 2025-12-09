/// Review Collection Service - Service untuk Buku Masuk Review
/// Mengelola buku yang masuk untuk direview oleh editor
/// Best Practice: Integration dengan EditorApiService

import 'package:publishify/models/editor/review_collection_models.dart';
import 'package:publishify/models/editor/review_models.dart';
import 'package:publishify/services/editor/editor_api_service.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(methodCount: 0, printTime: true),
);

/// Service untuk mengelola Review Collection
class ReviewCollectionService {
  // Singleton
  static final ReviewCollectionService _instance = ReviewCollectionService._internal();
  factory ReviewCollectionService() => _instance;
  ReviewCollectionService._internal();

  // =====================================================
  // GET BUKU MASUK
  // =====================================================

  /// Get daftar buku masuk untuk direview
  static Future<BukuMasukResponse> getBukuMasukReview({
    String filter = 'semua',
    int limit = 20,
  }) async {
    try {
      final reviewFilter = FilterReview(
        status: _parseFilter(filter),
        limit: limit,
        urutkan: 'ditugaskanPada',
        arah: 'desc',
      );

      final response = await EditorApiService.ambilReviewSaya(filter: reviewFilter);

      if (response.sukses && response.data != null) {
        final books = response.data!
            .map((review) => BukuMasukReview.fromReviewNaskah(review))
            .toList();

        // Calculate filter counts
        final counts = await _getFilterCounts();

        return BukuMasukResponse.success(
          books,
          metadata: {'filters': counts},
        );
      }

      return BukuMasukResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error getBukuMasukReview: $e');
      return BukuMasukResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Parse filter string ke StatusReview enum
  static StatusReview? _parseFilter(String filter) {
    switch (filter.toLowerCase()) {
      case 'menunggu':
      case 'ditugaskan':
        return StatusReview.ditugaskan;
      case 'sedang_review':
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

  /// Get filter counts dari statistik
  static Future<Map<String, int>> _getFilterCounts() async {
    try {
      final response = await EditorApiService.ambilStatistikReview();
      
      if (response.sukses && response.data != null) {
        final stats = response.data!;
        return {
          'semua': stats.totalReview,
          'menunggu': stats.perStatus['ditugaskan'] ?? 0,
          'sedang_review': stats.perStatus['dalam_proses'] ?? 0,
          'selesai': stats.perStatus['selesai'] ?? 0,
        };
      }
      
      return {};
    } catch (e) {
      return {};
    }
  }

  // =====================================================
  // DETAIL BUKU
  // =====================================================

  /// Get detail buku by ID
  static Future<DetailBukuResponse> getDetailBuku(String id) async {
    try {
      final response = await EditorApiService.ambilReviewById(id);

      if (response.sukses && response.data != null) {
        final detail = DetailBukuReview.fromReviewNaskah(response.data!);
        return DetailBukuResponse.success(detail);
      }

      return DetailBukuResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error getDetailBuku: $e');
      return DetailBukuResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // =====================================================
  // ACTIONS
  // =====================================================

  /// Terima buku untuk direview
  static Future<SimpleResponse> terimaBuku(String id) async {
    try {
      final request = PerbaruiReviewRequest(
        status: StatusReview.dalam_proses,
      );

      final response = await EditorApiService.perbaruiReview(id, request);

      if (response.sukses) {
        return SimpleResponse.success('Buku berhasil diterima untuk direview');
      }

      return SimpleResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error terimaBuku: $e');
      return SimpleResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Tugaskan buku ke editor lain
  static Future<SimpleResponse> tugaskanKeEditor(
    String idBuku,
    String idEditor,
    String alasan,
  ) async {
    try {
      // Get review detail first to get idNaskah
      final detailResponse = await EditorApiService.ambilReviewById(idBuku);
      
      if (!detailResponse.sukses || detailResponse.data == null) {
        return SimpleResponse.error('Buku tidak ditemukan');
      }

      final request = TugaskanReviewRequest(
        idNaskah: detailResponse.data!.idNaskah,
        idEditor: idEditor,
        catatan: alasan,
      );

      final response = await EditorApiService.tugaskanReview(request);

      if (response.sukses) {
        return SimpleResponse.success('Buku berhasil ditugaskan ke editor lain');
      }

      return SimpleResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error tugaskanKeEditor: $e');
      return SimpleResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Submit review dengan rekomendasi
  static Future<SimpleResponse> submitReview({
    required String idReview,
    required String rekomendasi, // setujui, revisi, tolak
    required String catatan,
    String? feedback,
  }) async {
    try {
      // Add feedback if provided (backend hanya menerima bab, halaman, komentar)
      if (feedback != null && feedback.isNotEmpty && feedback.length >= 10) {
        final feedbackRequest = TambahFeedbackRequest(
          komentar: feedback,
        );
        await EditorApiService.tambahFeedback(idReview, feedbackRequest);
      }

      // Submit review
      final rekomendasiEnum = Rekomendasi.values.firstWhere(
        (e) => e.name == rekomendasi,
        orElse: () => Rekomendasi.revisi,
      );

      final request = SubmitReviewRequest(
        rekomendasi: rekomendasiEnum,
        catatan: catatan,
      );

      final response = await EditorApiService.submitReview(idReview, request);

      if (response.sukses) {
        return SimpleResponse.success('Review berhasil disubmit');
      }

      return SimpleResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error submitReview: $e');
      return SimpleResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Submit review dengan InputReview model
  static Future<SimpleResponse> submitReviewFromInput(InputReview input) async {
    try {
      // Combine feedback list jadi satu string (backend tidak support rating/skor)
      final feedbackStr = input.feedback.isNotEmpty 
          ? input.feedback.join('\n') 
          : null;

      return await submitReview(
        idReview: input.idBuku,
        rekomendasi: input.rekomendasi,
        catatan: input.catatan,
        feedback: feedbackStr,
      );
    } catch (e) {
      _logger.e('Error submitReviewFromInput: $e');
      return SimpleResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Batalkan review
  static Future<SimpleResponse> batalkanReview(String id, String alasan) async {
    try {
      final response = await EditorApiService.batalkanReview(id, alasan);

      if (response.sukses) {
        return SimpleResponse.success('Review berhasil dibatalkan');
      }

      return SimpleResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error batalkanReview: $e');
      return SimpleResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // =====================================================
  // DAFTAR EDITOR
  // =====================================================

  /// Get daftar editor yang tersedia untuk ditugaskan
  static Future<EditorListResponse> getAvailableEditors() async {
    try {
      // Call API to get available editors
      // Untuk sementara, gunakan placeholder sampai backend ready
      final response = await EditorApiService.ambilDaftarEditor();
      
      if (response.sukses && response.data != null) {
        final editors = response.data!
            .map((e) => EditorOption.fromJson(e))
            .toList();
        return EditorListResponse.success(editors);
      }
      
      return EditorListResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error getAvailableEditors: $e');
      return EditorListResponse.error('Gagal mengambil daftar editor: ${e.toString()}');
    }
  }

  /// Tugaskan review ke editor lain
  static Future<SimpleResponse> tugaskanEditorLain({
    required String idReview,
    required String idEditorBaru,
    String? alasan,
  }) async {
    try {
      // Get review detail first to get idNaskah
      final detailResponse = await EditorApiService.ambilReviewById(idReview);
      
      if (!detailResponse.sukses || detailResponse.data == null) {
        return SimpleResponse.error('Review tidak ditemukan');
      }

      final request = TugaskanReviewRequest(
        idNaskah: detailResponse.data!.idNaskah,
        idEditor: idEditorBaru,
        catatan: alasan,
      );

      final response = await EditorApiService.tugaskanReview(request);

      if (response.sukses) {
        return SimpleResponse.success('Review berhasil ditugaskan ke editor lain');
      }

      return SimpleResponse.error(response.pesan);
    } catch (e) {
      _logger.e('Error tugaskanEditorLain: $e');
      return SimpleResponse.error('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get daftar editor yang tersedia (versi lama - untuk kompatibilitas)
  /// @deprecated Use getAvailableEditors() instead
  static Future<List<Map<String, dynamic>>> getDaftarEditor() async {
    try {
      final response = await getAvailableEditors();
      if (response.sukses && response.data != null) {
        return response.data!.map((e) => e.toJson()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
