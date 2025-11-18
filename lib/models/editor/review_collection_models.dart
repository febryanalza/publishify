/// Model untuk halaman pengumpulan review editor
/// Data struktur untuk buku yang masuk untuk direview

class BukuMasukReview {
  final String id;
  final String judul;
  final String subJudul;
  final String sinopsis;
  final String namaPenulis;
  final String kategori;
  final String genre;
  final String status; // 'belum_ditugaskan', 'ditugaskan', 'dalam_review', 'selesai'
  final DateTime tanggalSubmit;
  final DateTime? deadlineReview;
  final String? urlSampul;
  final String? urlFile;
  final int jumlahHalaman;
  final int jumlahKata;
  final String? editorYangDitugaskan;
  final String? catatanAdmin;
  final int prioritas; // 1 = rendah, 2 = sedang, 3 = tinggi

  const BukuMasukReview({
    required this.id,
    required this.judul,
    required this.subJudul,
    required this.sinopsis,
    required this.namaPenulis,
    required this.kategori,
    required this.genre,
    required this.status,
    required this.tanggalSubmit,
    this.deadlineReview,
    this.urlSampul,
    this.urlFile,
    required this.jumlahHalaman,
    required this.jumlahKata,
    this.editorYangDitugaskan,
    this.catatanAdmin,
    required this.prioritas,
  });

  factory BukuMasukReview.fromJson(Map<String, dynamic> json) {
    return BukuMasukReview(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      subJudul: json['subJudul'] ?? '',
      sinopsis: json['sinopsis'] ?? '',
      namaPenulis: json['namaPenulis'] ?? '',
      kategori: json['kategori'] ?? '',
      genre: json['genre'] ?? '',
      status: json['status'] ?? 'belum_ditugaskan',
      tanggalSubmit: DateTime.tryParse(json['tanggalSubmit'] ?? '') ?? DateTime.now(),
      deadlineReview: json['deadlineReview'] != null 
          ? DateTime.tryParse(json['deadlineReview']) 
          : null,
      urlSampul: json['urlSampul'],
      urlFile: json['urlFile'],
      jumlahHalaman: json['jumlahHalaman'] ?? 0,
      jumlahKata: json['jumlahKata'] ?? 0,
      editorYangDitugaskan: json['editorYangDitugaskan'],
      catatanAdmin: json['catatanAdmin'],
      prioritas: json['prioritas'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'subJudul': subJudul,
      'sinopsis': sinopsis,
      'namaPenulis': namaPenulis,
      'kategori': kategori,
      'genre': genre,
      'status': status,
      'tanggalSubmit': tanggalSubmit.toIso8601String(),
      'deadlineReview': deadlineReview?.toIso8601String(),
      'urlSampul': urlSampul,
      'urlFile': urlFile,
      'jumlahHalaman': jumlahHalaman,
      'jumlahKata': jumlahKata,
      'editorYangDitugaskan': editorYangDitugaskan,
      'catatanAdmin': catatanAdmin,
      'prioritas': prioritas,
    };
  }

  /// Helper untuk mendapatkan label status
  String get statusLabel {
    switch (status) {
      case 'belum_ditugaskan':
        return 'Belum Ditugaskan';
      case 'ditugaskan':
        return 'Ditugaskan';
      case 'dalam_review':
        return 'Dalam Review';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Tidak Diketahui';
    }
  }

  /// Helper untuk mendapatkan label prioritas
  String get prioritasLabel {
    switch (prioritas) {
      case 1:
        return 'Rendah';
      case 2:
        return 'Sedang';
      case 3:
        return 'Tinggi';
      default:
        return 'Sedang';
    }
  }
}

/// Model untuk detail buku ketika melihat detail
class DetailBukuReview {
  final BukuMasukReview bukuInfo;
  final List<RiwayatReview> riwayatReview;
  final String? fileContent; // Jika ada preview konten
  final List<String> tagKeyword;
  final Map<String, dynamic> metadata;

  const DetailBukuReview({
    required this.bukuInfo,
    required this.riwayatReview,
    this.fileContent,
    required this.tagKeyword,
    required this.metadata,
  });

  factory DetailBukuReview.fromJson(Map<String, dynamic> json) {
    return DetailBukuReview(
      bukuInfo: BukuMasukReview.fromJson(json['bukuInfo'] ?? {}),
      riwayatReview: (json['riwayatReview'] as List<dynamic>?)
          ?.map((item) => RiwayatReview.fromJson(item))
          .toList() ?? [],
      fileContent: json['fileContent'],
      tagKeyword: List<String>.from(json['tagKeyword'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

/// Model untuk riwayat review
class RiwayatReview {
  final String id;
  final String namaEditor;
  final String status;
  final String? catatan;
  final DateTime tanggal;
  final String? rekomendasi; // 'setujui', 'revisi', 'tolak'

  const RiwayatReview({
    required this.id,
    required this.namaEditor,
    required this.status,
    this.catatan,
    required this.tanggal,
    this.rekomendasi,
  });

  factory RiwayatReview.fromJson(Map<String, dynamic> json) {
    return RiwayatReview(
      id: json['id'] ?? '',
      namaEditor: json['namaEditor'] ?? '',
      status: json['status'] ?? '',
      catatan: json['catatan'],
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
      rekomendasi: json['rekomendasi'],
    );
  }
}

/// Model untuk input review
class InputReview {
  final String idBuku;
  final String catatan;
  final String rekomendasi; // 'setujui', 'revisi', 'tolak'
  final List<String> feedback;
  final int rating; // 1-5

  const InputReview({
    required this.idBuku,
    required this.catatan,
    required this.rekomendasi,
    required this.feedback,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'idBuku': idBuku,
      'catatan': catatan,
      'rekomendasi': rekomendasi,
      'feedback': feedback,
      'rating': rating,
    };
  }
}

/// Filter options untuk dropdown
class FilterReviewOption {
  final String key;
  final String label;
  final int count;

  const FilterReviewOption({
    required this.key,
    required this.label,
    required this.count,
  });
}

/// Response model untuk API
class ReviewCollectionResponse<T> {
  final bool sukses;
  final String pesan;
  final T? data;
  final Map<String, dynamic>? metadata;

  const ReviewCollectionResponse({
    required this.sukses,
    required this.pesan,
    this.data,
    this.metadata,
  });

  factory ReviewCollectionResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic) fromJsonT
  ) {
    return ReviewCollectionResponse<T>(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      metadata: json['metadata'],
    );
  }
}