import 'package:publishify/models/editor/editor_models.dart';

/// Service untuk mengelola data Editor Dashboard
/// Berisi data dummy yang dapat dengan mudah diganti dengan API backend
class EditorService {
  
  /// Get Editor Statistics (Data Dummy)
  /// TODO: Ganti dengan API call ke /api/editor/statistics
  static Future<EditorStats> getEditorStats() async {
    // Simulasi loading
    await Future.delayed(const Duration(milliseconds: 800));
    
    return EditorStats(
      totalReviewDitugaskan: 15,
      reviewSelesaiHariIni: 3,
      reviewDalamProses: 7,
      reviewTertunda: 5,
      naskahDisetujui: 42,
      naskahPerluRevisi: 18,
      naskahDitolak: 8,
      rataRataWaktuReview: 2.5,
      targetHarian: 5,
      pencapaianHarian: 3,
    );
  }

  /// Get Review Assignments (Data Dummy)
  /// TODO: Ganti dengan API call ke /api/editor/reviews
  static Future<List<ReviewAssignment>> getReviewAssignments({
    String? status,
    int? limit,
  }) async {
    // Simulasi loading
    await Future.delayed(const Duration(milliseconds: 600));
    
    final allReviews = [
      ReviewAssignment(
        id: 'rev_001',
        idNaskah: 'nsk_001',
        judulNaskah: 'Petualangan di Nusantara',
        penulis: 'Ahmad Subhan',
        editorYangDitugaskan: 'Sarah Editor',
        status: 'sedang_review',
        tanggalDitugaskan: DateTime.now().subtract(const Duration(days: 2)),
        tanggalMulai: DateTime.now().subtract(const Duration(days: 1)),
        batasWaktu: DateTime.now().add(const Duration(days: 3)),
        prioritas: 1,
        tags: ['Fiksi', 'Petualangan', 'Budaya'],
      ),
      ReviewAssignment(
        id: 'rev_002',
        idNaskah: 'nsk_002',
        judulNaskah: 'Manajemen Keuangan untuk Pemula',
        penulis: 'Siti Nurhaliza',
        editorYangDitugaskan: 'Sarah Editor',
        status: 'ditugaskan',
        tanggalDitugaskan: DateTime.now().subtract(const Duration(hours: 6)),
        batasWaktu: DateTime.now().add(const Duration(days: 5)),
        prioritas: 2,
        tags: ['Non-Fiksi', 'Keuangan', 'Bisnis'],
      ),
      ReviewAssignment(
        id: 'rev_003',
        idNaskah: 'nsk_003',
        judulNaskah: 'Resep Masakan Tradisional Jawa',
        penulis: 'Ibu Warsini',
        editorYangDitugaskan: 'Sarah Editor',
        status: 'selesai',
        tanggalDitugaskan: DateTime.now().subtract(const Duration(days: 5)),
        tanggalMulai: DateTime.now().subtract(const Duration(days: 4)),
        tanggalSelesai: DateTime.now().subtract(const Duration(hours: 12)),
        batasWaktu: DateTime.now().subtract(const Duration(days: 1)),
        rekomendasi: 'setujui',
        catatan: 'Naskah sangat baik, siap untuk publikasi',
        prioritas: 3,
        tags: ['Kuliner', 'Budaya', 'Tradisional'],
      ),
      ReviewAssignment(
        id: 'rev_004',
        idNaskah: 'nsk_004',
        judulNaskah: 'Panduan Berkebun Urban',
        penulis: 'Budi Santoso',
        editorYangDitugaskan: 'Sarah Editor',
        status: 'sedang_review',
        tanggalDitugaskan: DateTime.now().subtract(const Duration(days: 1)),
        tanggalMulai: DateTime.now().subtract(const Duration(hours: 4)),
        batasWaktu: DateTime.now().add(const Duration(days: 4)),
        prioritas: 2,
        tags: ['Hobby', 'Lingkungan', 'Praktis'],
      ),
      ReviewAssignment(
        id: 'rev_005',
        idNaskah: 'nsk_005',
        judulNaskah: 'Kisah Cinta di Masa Pandemi',
        penulis: 'Diana Wijaya',
        editorYangDitugaskan: 'Sarah Editor',
        status: 'selesai',
        tanggalDitugaskan: DateTime.now().subtract(const Duration(days: 7)),
        tanggalMulai: DateTime.now().subtract(const Duration(days: 6)),
        tanggalSelesai: DateTime.now().subtract(const Duration(days: 2)),
        batasWaktu: DateTime.now().subtract(const Duration(days: 1)),
        rekomendasi: 'revisi',
        catatan: 'Perlu perbaikan pada alur cerita dan karakter development',
        prioritas: 3,
        tags: ['Romance', 'Drama', 'Kontemporer'],
      ),
      ReviewAssignment(
        id: 'rev_006',
        idNaskah: 'nsk_006',
        judulNaskah: 'Teknologi AI dalam Pendidikan',
        penulis: 'Dr. Hendro Susanto',
        editorYangDitugaskan: 'Sarah Editor',
        status: 'ditugaskan',
        tanggalDitugaskan: DateTime.now().subtract(const Duration(hours: 2)),
        batasWaktu: DateTime.now().add(const Duration(days: 7)),
        prioritas: 1,
        tags: ['Teknologi', 'Pendidikan', 'AI'],
      ),
    ];

    // Filter berdasarkan status jika ada
    if (status != null && status.isNotEmpty) {
      final filtered = allReviews.where((review) => review.status == status).toList();
      return limit != null ? filtered.take(limit).toList() : filtered;
    }

    // Limit hasil jika ada
    if (limit != null) {
      return allReviews.take(limit).toList();
    }

    return allReviews;
  }

  /// Get Quick Actions untuk Editor Dashboard
  static List<Map<String, dynamic>> getQuickActions() {
    return [
      {
        'icon': 'assignment',
        'label': 'Review Baru',
        'count': 3,
        'action': 'new_reviews',
        'route': '/editor/review-naskah',
        'color': 'blue',
      },
      {
        'icon': 'schedule',
        'label': 'Deadline Dekat',
        'count': 2,
        'action': 'urgent_reviews',
        'route': '/editor/review-naskah',
        'color': 'orange',
      },
      {
        'icon': 'feedback',
        'label': 'Beri Feedback',
        'count': 1,
        'action': 'give_feedback',
        'route': '/editor/feedback',
        'color': 'green',
      },
      {
        'icon': 'done_all',
        'label': 'Review Selesai',
        'count': 5,
        'action': 'completed_reviews',
        'route': '/editor/review-naskah',
        'color': 'teal',
      },
    ];
  }

  /// Get Menu Items untuk Editor Navigation
  static List<Map<String, dynamic>> getEditorMenuItems() {
    return [
      {
        'icon': 'assignment_turned_in',
        'title': 'Review Naskah',
        'subtitle': 'Kelola review yang ditugaskan',
        'route': '/editor/reviews',
        'badge': 7, // jumlah review aktif
      },
      {
        'icon': 'book_online',
        'title': 'Kelola Review Naskah',
        'subtitle': 'Terima dan tugaskan review naskah',
        'route': '/editor/review-naskah',
        'badge': 5, // jumlah naskah menunggu review
      },
      {
        'icon': 'rate_review',
        'title': 'Beri Feedback',
        'subtitle': 'Berikan feedback untuk penulis',
        'route': '/editor/feedback',
        'badge': null,
      },
      {
        'icon': 'assignment',
        'title': 'Naskah Masuk',
        'subtitle': 'Naskah baru yang perlu direview',
        'route': '/editor/naskah-masuk',
        'badge': 4, // jumlah naskah baru
      },
      {
        'icon': 'analytics',
        'title': 'Statistik Review',
        'subtitle': 'Lihat performa review Anda',
        'route': '/editor/statistics',
        'badge': null,
      },
    ];
  }
}