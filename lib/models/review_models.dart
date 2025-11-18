// Model untuk Review Response dari API /api/review/naskah/:idNaskah
class ReviewListResponse {
  final bool sukses;
  final String pesan;
  final List<ReviewData>? data;
  final MetaData? metadata;

  ReviewListResponse({
    required this.sukses,
    required this.pesan,
    this.data,
    this.metadata,
  });

  factory ReviewListResponse.fromJson(Map<String, dynamic> json) {
    return ReviewListResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => ReviewData.fromJson(item))
              .toList()
          : null,
      metadata: json['metadata'] != null 
          ? MetaData.fromJson(json['metadata']) 
          : null,
    );
  }
}

// Model untuk Data Review
class ReviewData {
  final String id;
  final String idNaskah;
  final String idEditor;
  final String status; // ditugaskan, dalam_proses, selesai, dibatalkan
  final String? rekomendasi; // setujui, revisi, tolak
  final String? catatan;
  final String ditugaskanPada;
  final String? dimulaiPada;
  final String? selesaiPada;
  final String dibuatPada;
  final String diperbaruiPada;
  final NaskahReview? naskah;
  final EditorReview? editor;
  final ReviewCount? count;
  final List<FeedbackData>? feedback;

  ReviewData({
    required this.id,
    required this.idNaskah,
    required this.idEditor,
    required this.status,
    this.rekomendasi,
    this.catatan,
    required this.ditugaskanPada,
    this.dimulaiPada,
    this.selesaiPada,
    required this.dibuatPada,
    required this.diperbaruiPada,
    this.naskah,
    this.editor,
    this.count,
    this.feedback,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      id: json['id'] ?? '',
      idNaskah: json['idNaskah'] ?? '',
      idEditor: json['idEditor'] ?? '',
      status: json['status'] ?? '',
      rekomendasi: json['rekomendasi'],
      catatan: json['catatan'],
      ditugaskanPada: json['ditugaskanPada'] ?? '',
      dimulaiPada: json['dimulaiPada'],
      selesaiPada: json['selesaiPada'],
      dibuatPada: json['dibuatPada'] ?? '',
      diperbaruiPada: json['diperbaruiPada'] ?? '',
      naskah: json['naskah'] != null 
          ? NaskahReview.fromJson(json['naskah']) 
          : null,
      editor: json['editor'] != null 
          ? EditorReview.fromJson(json['editor']) 
          : null,
      count: json['_count'] != null 
          ? ReviewCount.fromJson(json['_count']) 
          : null,
      feedback: json['feedback'] != null
          ? (json['feedback'] as List)
              .map((item) => FeedbackData.fromJson(item))
              .toList()
          : null,
    );
  }
}

// Model untuk Naskah dalam Review
class NaskahReview {
  final String id;
  final String judul;
  final String status;
  final PenulisReview? penulis;
  final KategoriReview? kategori;
  final GenreReview? genre;

  NaskahReview({
    required this.id,
    required this.judul,
    required this.status,
    this.penulis,
    this.kategori,
    this.genre,
  });

  factory NaskahReview.fromJson(Map<String, dynamic> json) {
    return NaskahReview(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      status: json['status'] ?? '',
      penulis: json['penulis'] != null 
          ? PenulisReview.fromJson(json['penulis']) 
          : null,
      kategori: json['kategori'] != null
          ? KategoriReview.fromJson(json['kategori'])
          : null,
      genre: json['genre'] != null
          ? GenreReview.fromJson(json['genre'])
          : null,
    );
  }
}

// Model untuk Kategori dalam Review
class KategoriReview {
  final String id;
  final String nama;

  KategoriReview({
    required this.id,
    required this.nama,
  });

  factory KategoriReview.fromJson(Map<String, dynamic> json) {
    return KategoriReview(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
    );
  }
}

// Model untuk Genre dalam Review
class GenreReview {
  final String id;
  final String nama;

  GenreReview({
    required this.id,
    required this.nama,
  });

  factory GenreReview.fromJson(Map<String, dynamic> json) {
    return GenreReview(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
    );
  }
}

// Model untuk Penulis dalam Review
class PenulisReview {
  final String id;
  final String email;
  final ProfilPenggunaReview? profilPengguna;

  PenulisReview({
    required this.id,
    required this.email,
    this.profilPengguna,
  });

  factory PenulisReview.fromJson(Map<String, dynamic> json) {
    return PenulisReview(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      profilPengguna: json['profilPengguna'] != null
          ? ProfilPenggunaReview.fromJson(json['profilPengguna'])
          : null,
    );
  }
}

// Model untuk Editor dalam Review
class EditorReview {
  final String id;
  final String email;
  final ProfilPenggunaReview? profilPengguna;

  EditorReview({
    required this.id,
    required this.email,
    this.profilPengguna,
  });

  factory EditorReview.fromJson(Map<String, dynamic> json) {
    return EditorReview(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      profilPengguna: json['profilPengguna'] != null
          ? ProfilPenggunaReview.fromJson(json['profilPengguna'])
          : null,
    );
  }
}

// Model untuk Profil Pengguna dalam Review
class ProfilPenggunaReview {
  final String? namaDepan;
  final String? namaBelakang;
  final String? namaTampilan;

  ProfilPenggunaReview({
    this.namaDepan,
    this.namaBelakang,
    this.namaTampilan,
  });

  factory ProfilPenggunaReview.fromJson(Map<String, dynamic> json) {
    return ProfilPenggunaReview(
      namaDepan: json['namaDepan'],
      namaBelakang: json['namaBelakang'],
      namaTampilan: json['namaTampilan'],
    );
  }

  String get namaLengkap {
    if (namaTampilan != null && namaTampilan!.isNotEmpty) {
      return namaTampilan!;
    }
    if (namaDepan != null && namaBelakang != null) {
      return '$namaDepan $namaBelakang';
    }
    if (namaDepan != null) {
      return namaDepan!;
    }
    return 'User';
  }
}

// Model untuk Count dalam Review
class ReviewCount {
  final int feedback;

  ReviewCount({
    required this.feedback,
  });

  factory ReviewCount.fromJson(Map<String, dynamic> json) {
    return ReviewCount(
      feedback: json['feedback'] ?? 0,
    );
  }
}

// Model untuk Feedback dalam Review
class FeedbackData {
  final String id;
  final String idReview;
  final String? bab;
  final int? halaman;
  final String komentar;
  final String dibuatPada;
  final EditorReview? editor;

  FeedbackData({
    required this.id,
    required this.idReview,
    this.bab,
    this.halaman,
    required this.komentar,
    required this.dibuatPada,
    this.editor,
  });

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
      id: json['id'] ?? '',
      idReview: json['idReview'] ?? '',
      bab: json['bab'],
      halaman: json['halaman'],
      komentar: json['komentar'] ?? '',
      dibuatPada: json['dibuatPada'] ?? '',
      editor: json['editor'] != null
          ? EditorReview.fromJson(json['editor'])
          : null,
    );
  }

  // Helper getter untuk mengakses isi feedback
  String get isi => komentar;
}

// Model untuk Detail Review Response
class ReviewDetailResponse {
  final bool sukses;
  final String? pesan;
  final ReviewData? data;

  ReviewDetailResponse({
    required this.sukses,
    this.pesan,
    this.data,
  });

  factory ReviewDetailResponse.fromJson(Map<String, dynamic> json) {
    return ReviewDetailResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'],
      data: json['data'] != null 
          ? ReviewData.fromJson(json['data']) 
          : null,
    );
  }
}

// Model untuk Metadata pagination
class MetaData {
  final int total;
  final int halaman;
  final int limit;
  final int totalHalaman;

  MetaData({
    required this.total,
    required this.halaman,
    required this.limit,
    required this.totalHalaman,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      total: json['total'] ?? 0,
      halaman: json['halaman'] ?? 1,
      limit: json['limit'] ?? 20,
      totalHalaman: json['totalHalaman'] ?? 0,
    );
  }
}
