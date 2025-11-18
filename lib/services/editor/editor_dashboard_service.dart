import 'package:publishify/models/editor/editor_models.dart';

/// Service untuk mengelola data Editor Dashboard
/// Berisi data dummy yang dapat dengan mudah diganti dengan API backend
class EditorDashboardService {
  
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

  /// Get Naskah yang masuk untuk Editor (Data Dummy)
  /// TODO: Ganti dengan API call ke /api/editor/naskah-masuk
  static Future<List<EditorNaskahItem>> getNaskahMasuk({
    String? status,
    int? limit,
  }) async {
    // Simulasi loading
    await Future.delayed(const Duration(milliseconds: 500));
    
    final allNaskah = [
      EditorNaskahItem(
        id: 'nsk_001',
        judul: 'Petualangan di Nusantara',
        penulis: 'Ahmad Subhan',
        status: 'dalam_review',
        prioritas: 'tinggi',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 2)),
        batasWaktu: DateTime.now().add(const Duration(days: 3)),
        deskripsi: 'Novel petualangan yang mengangkat kearifan lokal Indonesia',
        jumlahHalaman: 285,
        kategori: 'Fiksi',
        genre: 'Petualangan',
        memilikiRevisi: false,
        versiTerkini: 1,
      ),
      EditorNaskahItem(
        id: 'nsk_002',
        judul: 'Manajemen Keuangan untuk Pemula',
        penulis: 'Siti Nurhaliza',
        status: 'baru_masuk',
        prioritas: 'sedang',
        tanggalMasuk: DateTime.now().subtract(const Duration(hours: 6)),
        batasWaktu: DateTime.now().add(const Duration(days: 5)),
        deskripsi: 'Panduan praktis mengelola keuangan pribadi untuk generasi milenial',
        jumlahHalaman: 156,
        kategori: 'Non-Fiksi',
        genre: 'Bisnis & Keuangan',
        memilikiRevisi: false,
        versiTerkini: 1,
      ),
      EditorNaskahItem(
        id: 'nsk_007',
        judul: 'Strategi Digital Marketing 2024',
        penulis: 'Riko Pratama',
        status: 'baru_masuk',
        prioritas: 'tinggi',
        tanggalMasuk: DateTime.now().subtract(const Duration(hours: 1)),
        batasWaktu: DateTime.now().add(const Duration(days: 3)),
        deskripsi: 'Panduan lengkap strategi pemasaran digital terkini',
        jumlahHalaman: 198,
        kategori: 'Non-Fiksi',
        genre: 'Bisnis & Marketing',
        memilikiRevisi: false,
        versiTerkini: 1,
      ),
      EditorNaskahItem(
        id: 'nsk_008',
        judul: 'Dongeng Anak Nusantara',
        penulis: 'Kak Melati',
        status: 'baru_masuk',
        prioritas: 'sedang',
        tanggalMasuk: DateTime.now().subtract(const Duration(days: 1)),
        batasWaktu: DateTime.now().add(const Duration(days: 6)),
        deskripsi: 'Kumpulan dongeng tradisional Indonesia untuk anak-anak',
        jumlahHalaman: 89,
        kategori: 'Anak-anak',
        genre: 'Dongeng',
        memilikiRevisi: false,
        versiTerkini: 1,
      ),
    ];

    // Filter berdasarkan status jika ada
    if (status != null && status.isNotEmpty) {
      final filtered = allNaskah.where((naskah) => naskah.status == status).toList();
      return limit != null ? filtered.take(limit).toList() : filtered;
    }

    // Limit hasil jika ada
    if (limit != null) {
      return allNaskah.take(limit).toList();
    }

    return allNaskah;
  }

  /// Get Editor Notifications (Data Dummy)
  /// TODO: Ganti dengan API call ke /api/editor/notifications
  static Future<List<EditorNotifikasi>> getNotifikasi({int? limit}) async {
    // Simulasi loading
    await Future.delayed(const Duration(milliseconds: 400));
    
    final allNotifikasi = [
      EditorNotifikasi(
        id: 'notif_001',
        judul: 'Naskah Baru Ditugaskan',
        pesan: 'Anda mendapat tugas review untuk naskah "Teknologi AI dalam Pendidikan"',
        tipe: 'naskah_baru',
        tanggal: DateTime.now().subtract(const Duration(minutes: 30)),
        dibaca: false,
        idNaskah: 'nsk_006',
      ),
      EditorNotifikasi(
        id: 'notif_002',
        judul: 'Deadline Mendekat',
        pesan: 'Review naskah "Petualangan di Nusantara" harus selesai dalam 3 hari',
        tipe: 'deadline_dekat',
        tanggal: DateTime.now().subtract(const Duration(hours: 2)),
        dibaca: false,
        idNaskah: 'nsk_001',
      ),
      EditorNotifikasi(
        id: 'notif_003',
        judul: 'Review Selesai Dikirim',
        pesan: 'Review untuk naskah "Resep Masakan Tradisional Jawa" telah berhasil dikirim',
        tipe: 'review_selesai',
        tanggal: DateTime.now().subtract(const Duration(hours: 12)),
        dibaca: true,
        idNaskah: 'nsk_003',
      ),
      EditorNotifikasi(
        id: 'notif_004',
        judul: 'Feedback dari Penulis',
        pesan: 'Diana Wijaya merespons review Anda untuk naskah "Kisah Cinta di Masa Pandemi"',
        tipe: 'feedback_baru',
        tanggal: DateTime.now().subtract(const Duration(days: 1)),
        dibaca: true,
        idNaskah: 'nsk_005',
      ),
    ];

    // Limit hasil jika ada
    if (limit != null) {
      return allNotifikasi.take(limit).toList();
    }

    return allNotifikasi;
  }

  /// Mark notification as read
  /// TODO: Ganti dengan API call ke /api/editor/notifications/:id/read
  static Future<bool> markNotifikasiDibaca(String notifikasiId) async {
    // Simulasi API call
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Dummy implementation - selalu berhasil
    return true;
  }

  /// Get Quick Actions untuk Editor Dashboard
  static List<Map<String, dynamic>> getQuickActions() {
    return [
      {
        'icon': 'assignment',
        'label': 'Review Baru',
        'count': 3,
        'action': 'new_reviews',
        'color': 'blue',
      },
      {
        'icon': 'schedule',
        'label': 'Deadline Dekat',
        'count': 2,
        'action': 'urgent_reviews',
        'color': 'orange',
      },
      {
        'icon': 'feedback',
        'label': 'Beri Feedback',
        'count': 1,
        'action': 'give_feedback',
        'color': 'green',
      },
      {
        'icon': 'done_all',
        'label': 'Review Selesai',
        'count': 5,
        'action': 'completed_reviews',
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
      {
        'icon': 'people',
        'title': 'Assign Editor',
        'subtitle': 'Tugaskan review ke editor lain',
        'route': '/editor/assign',
        'badge': null,
      },
      {
        'icon': 'history',
        'title': 'Riwayat Review',
        'subtitle': 'Review yang sudah diselesaikan',
        'route': '/editor/history',
        'badge': null,
      },
    ];
  }
}