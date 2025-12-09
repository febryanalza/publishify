/// Models untuk Editor Dashboard
/// Menggunakan backend integration models saja

// Export review models yang backend-compatible
export 'review_models.dart';

// Import StatistikReview untuk factory method
import 'package:publishify/models/editor/review_models.dart';

/// Legacy model - akan dihapus, gunakan ReviewNaskah dari review_models.dart
/// Model untuk Naskah yang masuk ke Editor
class EditorNaskahItem {
  final String id;
  final String judul;
  final String penulis;
  final String status;
  final String prioritas; // tinggi, sedang, rendah
  final DateTime tanggalMasuk;
  final DateTime? batasWaktu;
  final String? deskripsi;
  final int? jumlahHalaman;
  final String? kategori;
  final String? genre;
  final String? urlSampul;
  final bool memilikiRevisi;
  final int? versiTerkini;

  EditorNaskahItem({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.status,
    required this.prioritas,
    required this.tanggalMasuk,
    this.batasWaktu,
    this.deskripsi,
    this.jumlahHalaman,
    this.kategori,
    this.genre,
    this.urlSampul,
    this.memilikiRevisi = false,
    this.versiTerkini,
  });

  /// Convert to JSON untuk backend integration
  Map<String, dynamic> toJson() => {
    'id': id,
    'judul': judul,
    'penulis': penulis,
    'status': status,
    'prioritas': prioritas,
    'tanggalMasuk': tanggalMasuk.toIso8601String(),
    'batasWaktu': batasWaktu?.toIso8601String(),
    'deskripsi': deskripsi,
    'jumlahHalaman': jumlahHalaman,
    'kategori': kategori,
    'genre': genre,
    'urlSampul': urlSampul,
    'memilikiRevisi': memilikiRevisi,
    'versiTerkini': versiTerkini,
  };

  /// Create from JSON untuk backend integration
  factory EditorNaskahItem.fromJson(Map<String, dynamic> json) {
    return EditorNaskahItem(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      penulis: json['penulis'] ?? '',
      status: json['status'] ?? '',
      prioritas: json['prioritas'] ?? 'sedang',
      tanggalMasuk: DateTime.tryParse(json['tanggalMasuk'] ?? '') ?? DateTime.now(),
      batasWaktu: json['batasWaktu'] != null 
          ? DateTime.tryParse(json['batasWaktu']) 
          : null,
      deskripsi: json['deskripsi'],
      jumlahHalaman: json['jumlahHalaman'],
      kategori: json['kategori'],
      genre: json['genre'],
      urlSampul: json['urlSampul'],
      memilikiRevisi: json['memilikiRevisi'] ?? false,
      versiTerkini: json['versiTerkini'],
    );
  }
}

/// Model untuk Review Assignment - UI compatible
/// Digunakan untuk menampilkan daftar review di dashboard
class ReviewAssignment {
  final String id;
  final String judulNaskah;
  final String penulisNaskah;
  final DateTime tanggalDitugaskan;
  final DateTime batasWaktu;
  final String status; // ditugaskan, dalam_proses, selesai, dibatalkan
  final double progress; // 0.0 - 1.0
  final String? kategori;
  final int jumlahHalaman;
  final String? catatan;
  final String? rekomendasi;
  
  // Legacy fields untuk kompatibilitas
  final String? idNaskah;
  final String? penulis;
  final String? editorYangDitugaskan;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final int prioritas;
  final List<String>? tags;

  ReviewAssignment({
    required this.id,
    required this.judulNaskah,
    required this.penulisNaskah,
    required this.tanggalDitugaskan,
    required this.batasWaktu,
    required this.status,
    this.progress = 0.0,
    this.kategori,
    this.jumlahHalaman = 0,
    this.catatan,
    this.rekomendasi,
    // Legacy
    this.idNaskah,
    this.penulis,
    this.editorYangDitugaskan,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.prioritas = 3,
    this.tags,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'judulNaskah': judulNaskah,
    'penulisNaskah': penulisNaskah,
    'tanggalDitugaskan': tanggalDitugaskan.toIso8601String(),
    'batasWaktu': batasWaktu.toIso8601String(),
    'status': status,
    'progress': progress,
    'kategori': kategori,
    'jumlahHalaman': jumlahHalaman,
    'catatan': catatan,
    'rekomendasi': rekomendasi,
    'idNaskah': idNaskah,
    'penulis': penulis,
    'editorYangDitugaskan': editorYangDitugaskan,
    'tanggalMulai': tanggalMulai?.toIso8601String(),
    'tanggalSelesai': tanggalSelesai?.toIso8601String(),
    'prioritas': prioritas,
    'tags': tags,
  };

  /// Create from JSON
  factory ReviewAssignment.fromJson(Map<String, dynamic> json) {
    return ReviewAssignment(
      id: json['id'] ?? '',
      judulNaskah: json['judulNaskah'] ?? '',
      penulisNaskah: json['penulisNaskah'] ?? json['penulis'] ?? '',
      tanggalDitugaskan: DateTime.tryParse(json['tanggalDitugaskan'] ?? '') ?? DateTime.now(),
      batasWaktu: DateTime.tryParse(json['batasWaktu'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'ditugaskan',
      progress: (json['progress'] ?? 0.0).toDouble(),
      kategori: json['kategori'],
      jumlahHalaman: json['jumlahHalaman'] ?? 0,
      catatan: json['catatan'],
      rekomendasi: json['rekomendasi'],
      idNaskah: json['idNaskah'],
      penulis: json['penulis'],
      editorYangDitugaskan: json['editorYangDitugaskan'],
      tanggalMulai: json['tanggalMulai'] != null 
          ? DateTime.tryParse(json['tanggalMulai']) 
          : null,
      tanggalSelesai: json['tanggalSelesai'] != null 
          ? DateTime.tryParse(json['tanggalSelesai']) 
          : null,
      prioritas: json['prioritas'] ?? 3,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  /// Helper untuk mendapatkan warna berdasarkan prioritas
  String get prioritasLabel {
    switch (prioritas) {
      case 1: return 'Sangat Tinggi';
      case 2: return 'Tinggi';
      case 3: return 'Sedang';
      case 4: return 'Rendah';
      case 5: return 'Sangat Rendah';
      default: return 'Sedang';
    }
  }

  /// Helper untuk mendapatkan status label Indonesia
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'ditugaskan': return 'Ditugaskan';
      case 'dalam_proses': return 'Dalam Proses';
      case 'sedang_review': return 'Sedang Review';
      case 'selesai': return 'Selesai';
      case 'dibatalkan': return 'Dibatalkan';
      case 'ditolak': return 'Ditolak';
      default: return status;
    }
  }

  /// Helper untuk mendapatkan warna status
  int get statusColor {
    switch (status.toLowerCase()) {
      case 'ditugaskan': return 0xFF2196F3; // Blue
      case 'dalam_proses': return 0xFFFF9800; // Orange
      case 'selesai': return 0xFF4CAF50; // Green
      case 'dibatalkan': return 0xFFF44336; // Red
      default: return 0xFF9E9E9E; // Grey
    }
  }

  /// Check apakah sudah melewati batas waktu
  bool get isOverdue => DateTime.now().isAfter(batasWaktu);

  /// Sisa hari sampai batas waktu
  int get sisaHari {
    final diff = batasWaktu.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }
}

/// Model untuk Editor Statistics Dashboard
class EditorStats {
  final int totalReviewDitugaskan;
  final int reviewSelesaiHariIni;
  final int reviewDalamProses;
  final int reviewTertunda;
  final int naskahDisetujui;
  final int naskahPerluRevisi;
  final int naskahDitolak;
  final double rataRataWaktuReview; // dalam hari
  final int targetHarian;
  final int pencapaianHarian;

  // Alias untuk kompatibilitas
  int get totalReview => totalReviewDitugaskan;
  int get reviewSelesai => reviewSelesaiHariIni + naskahDisetujui + naskahDitolak + naskahPerluRevisi;
  int get reviewMenunggu => reviewTertunda;
  int get reviewDibatalkan => 0;
  double get ratingRataRata => 4.5; // Default rating
  int get tingkatPenyelesaian => totalReviewDitugaskan > 0 
      ? ((reviewSelesai / totalReviewDitugaskan) * 100).round() 
      : 0;

  EditorStats({
    required this.totalReviewDitugaskan,
    required this.reviewSelesaiHariIni,
    required this.reviewDalamProses,
    required this.reviewTertunda,
    required this.naskahDisetujui,
    required this.naskahPerluRevisi,
    required this.naskahDitolak,
    required this.rataRataWaktuReview,
    required this.targetHarian,
    required this.pencapaianHarian,
  });

  // Computed properties untuk kompatibilitas dengan halaman statistik
  int get totalReviews => totalReviewDitugaskan;
  int get completedReviews => reviewSelesaiHariIni + totalNaskahDireview;
  int get activeReviews => reviewDalamProses;
  double get averageRating => 4.5; // Default rating, bisa diambil dari backend
  int get onTimeReviews => (completedReviews * 0.8).round(); // 80% tepat waktu
  int get lateReviews => completedReviews - onTimeReviews;
  int get pendingReviews => reviewTertunda;
  double get averageReviewDays => rataRataWaktuReview;
  int get totalFeedbacks => completedReviews; // Asumsi setiap review ada feedback

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'totalReviewDitugaskan': totalReviewDitugaskan,
    'reviewSelesaiHariIni': reviewSelesaiHariIni,
    'reviewDalamProses': reviewDalamProses,
    'reviewTertunda': reviewTertunda,
    'naskahDisetujui': naskahDisetujui,
    'naskahPerluRevisi': naskahPerluRevisi,
    'naskahDitolak': naskahDitolak,
    'rataRataWaktuReview': rataRataWaktuReview,
    'targetHarian': targetHarian,
    'pencapaianHarian': pencapaianHarian,
    // Alias untuk kompatibilitas
    'totalReview': totalReview,
    'reviewSelesai': reviewSelesai,
    'reviewMenunggu': reviewMenunggu,
    'reviewDibatalkan': reviewDibatalkan,
    'ratingRataRata': ratingRataRata,
    'tingkatPenyelesaian': tingkatPenyelesaian,
  };

  /// Create from JSON
  factory EditorStats.fromJson(Map<String, dynamic> json) {
    return EditorStats(
      totalReviewDitugaskan: json['totalReviewDitugaskan'] ?? json['totalReview'] ?? 0,
      reviewSelesaiHariIni: json['reviewSelesaiHariIni'] ?? 0,
      reviewDalamProses: json['reviewDalamProses'] ?? json['dalam_proses'] ?? 0,
      reviewTertunda: json['reviewTertunda'] ?? json['reviewMenunggu'] ?? json['ditugaskan'] ?? 0,
      naskahDisetujui: json['naskahDisetujui'] ?? json['disetujui'] ?? 0,
      naskahPerluRevisi: json['naskahPerluRevisi'] ?? json['perlu_revisi'] ?? 0,
      naskahDitolak: json['naskahDitolak'] ?? json['ditolak'] ?? 0,
      rataRataWaktuReview: (json['rataRataWaktuReview'] ?? 0).toDouble(),
      targetHarian: json['targetHarian'] ?? 5,
      pencapaianHarian: json['pencapaianHarian'] ?? 0,
    );
  }

  /// Create from StatistikReview
  factory EditorStats.fromStatistikReview(StatistikReview stats) {
    return EditorStats(
      totalReviewDitugaskan: stats.totalReview,
      reviewSelesaiHariIni: stats.perStatus['selesai'] ?? 0,
      reviewDalamProses: stats.perStatus['dalam_proses'] ?? 0,
      reviewTertunda: stats.perStatus['ditugaskan'] ?? 0,
      naskahDisetujui: 0,
      naskahPerluRevisi: 0,
      naskahDitolak: 0,
      rataRataWaktuReview: 3.0,
      targetHarian: 5,
      pencapaianHarian: stats.perStatus['selesai'] ?? 0,
    );
  }

  /// Helper untuk mendapatkan persentase pencapaian
  double get persentasePencapaian {
    if (targetHarian == 0) return 0.0;
    return (pencapaianHarian / targetHarian * 100).clamp(0.0, 100.0);
  }

  /// Total naskah yang sudah di-review
  int get totalNaskahDireview {
    return naskahDisetujui + naskahPerluRevisi + naskahDitolak;
  }
}

/// Model untuk notifikasi editor
class EditorNotifikasi {
  final String id;
  final String judul;
  final String pesan;
  final String tipe; // naskah_baru, deadline_dekat, review_selesai, feedback_baru
  final DateTime tanggal;
  final bool dibaca;
  final String? idNaskah;
  final String? actionUrl;

  EditorNotifikasi({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.tanggal,
    this.dibaca = false,
    this.idNaskah,
    this.actionUrl,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'judul': judul,
    'pesan': pesan,
    'tipe': tipe,
    'tanggal': tanggal.toIso8601String(),
    'dibaca': dibaca,
    'idNaskah': idNaskah,
    'actionUrl': actionUrl,
  };

  /// Create from JSON
  factory EditorNotifikasi.fromJson(Map<String, dynamic> json) {
    return EditorNotifikasi(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      tipe: json['tipe'] ?? '',
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
      dibaca: json['dibaca'] ?? false,
      idNaskah: json['idNaskah'],
      actionUrl: json['actionUrl'],
    );
  }
}