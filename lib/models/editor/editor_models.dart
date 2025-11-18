/// Models untuk Editor Dashboard
/// Berisi data dummy yang dapat dengan mudah dihubungkan dengan backend

// Export review collection models
export 'review_collection_models.dart';

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

/// Model untuk Review Assignment
class ReviewAssignment {
  final String id;
  final String idNaskah;
  final String judulNaskah;
  final String penulis;
  final String editorYangDitugaskan;
  final String status; // ditugaskan, sedang_review, selesai, ditolak
  final DateTime tanggalDitugaskan;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final DateTime batasWaktu;
  final String? catatan;
  final String? rekomendasi; // setujui, revisi, tolak
  final int prioritas; // 1-5 (1=sangat tinggi, 5=rendah)
  final List<String>? tags;

  ReviewAssignment({
    required this.id,
    required this.idNaskah,
    required this.judulNaskah,
    required this.penulis,
    required this.editorYangDitugaskan,
    required this.status,
    required this.tanggalDitugaskan,
    this.tanggalMulai,
    this.tanggalSelesai,
    required this.batasWaktu,
    this.catatan,
    this.rekomendasi,
    this.prioritas = 3,
    this.tags,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'idNaskah': idNaskah,
    'judulNaskah': judulNaskah,
    'penulis': penulis,
    'editorYangDitugaskan': editorYangDitugaskan,
    'status': status,
    'tanggalDitugaskan': tanggalDitugaskan.toIso8601String(),
    'tanggalMulai': tanggalMulai?.toIso8601String(),
    'tanggalSelesai': tanggalSelesai?.toIso8601String(),
    'batasWaktu': batasWaktu.toIso8601String(),
    'catatan': catatan,
    'rekomendasi': rekomendasi,
    'prioritas': prioritas,
    'tags': tags,
  };

  /// Create from JSON
  factory ReviewAssignment.fromJson(Map<String, dynamic> json) {
    return ReviewAssignment(
      id: json['id'] ?? '',
      idNaskah: json['idNaskah'] ?? '',
      judulNaskah: json['judulNaskah'] ?? '',
      penulis: json['penulis'] ?? '',
      editorYangDitugaskan: json['editorYangDitugaskan'] ?? '',
      status: json['status'] ?? 'ditugaskan',
      tanggalDitugaskan: DateTime.tryParse(json['tanggalDitugaskan'] ?? '') ?? DateTime.now(),
      tanggalMulai: json['tanggalMulai'] != null 
          ? DateTime.tryParse(json['tanggalMulai']) 
          : null,
      tanggalSelesai: json['tanggalSelesai'] != null 
          ? DateTime.tryParse(json['tanggalSelesai']) 
          : null,
      batasWaktu: DateTime.tryParse(json['batasWaktu'] ?? '') ?? DateTime.now(),
      catatan: json['catatan'],
      rekomendasi: json['rekomendasi'],
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
      case 'sedang_review': return 'Sedang Review';
      case 'selesai': return 'Selesai';
      case 'ditolak': return 'Ditolak';
      default: return status;
    }
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
  };

  /// Create from JSON
  factory EditorStats.fromJson(Map<String, dynamic> json) {
    return EditorStats(
      totalReviewDitugaskan: json['totalReviewDitugaskan'] ?? 0,
      reviewSelesaiHariIni: json['reviewSelesaiHariIni'] ?? 0,
      reviewDalamProses: json['reviewDalamProses'] ?? 0,
      reviewTertunda: json['reviewTertunda'] ?? 0,
      naskahDisetujui: json['naskahDisetujui'] ?? 0,
      naskahPerluRevisi: json['naskahPerluRevisi'] ?? 0,
      naskahDitolak: json['naskahDitolak'] ?? 0,
      rataRataWaktuReview: (json['rataRataWaktuReview'] ?? 0).toDouble(),
      targetHarian: json['targetHarian'] ?? 5,
      pencapaianHarian: json['pencapaianHarian'] ?? 0,
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