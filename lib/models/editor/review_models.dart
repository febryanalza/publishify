/// Models untuk Review System Editor
/// Sesuai dengan backend structure dari review.controller.ts dan review.service.ts

/// Enum untuk Status Review
enum StatusReview {
  ditugaskan,
  dalam_proses,
  selesai,
  dibatalkan,
}

/// Enum untuk Rekomendasi Review
enum Rekomendasi {
  setujui,
  revisi,
  tolak,
}

/// Enum untuk Status Naskah
enum StatusNaskah {
  draft,
  diajukan,
  dalam_review,
  perlu_revisi,
  disetujui,
  ditolak,
  diterbitkan,
}

/// Model untuk Review Naskah
class ReviewNaskah {
  final String id;
  final String idNaskah;
  final String idEditor;
  final StatusReview status;
  final Rekomendasi? rekomendasi;
  final String? catatan;
  final DateTime ditugaskanPada;
  final DateTime? dimulaiPada;
  final DateTime? selesaiPada;
  final NaskahInfo naskah;
  final EditorInfo editor;
  final List<FeedbackReview> feedback;
  final int? feedbackCount; // from _count.feedback

  ReviewNaskah({
    required this.id,
    required this.idNaskah,
    required this.idEditor,
    required this.status,
    this.rekomendasi,
    this.catatan,
    required this.ditugaskanPada,
    this.dimulaiPada,
    this.selesaiPada,
    required this.naskah,
    required this.editor,
    this.feedback = const [],
    this.feedbackCount,
  });

  factory ReviewNaskah.fromJson(Map<String, dynamic> json) {
    // Handle _count dari backend
    int? feedbackCount;
    if (json['_count'] != null && json['_count']['feedback'] != null) {
      feedbackCount = json['_count']['feedback'] as int?;
    }

    return ReviewNaskah(
      id: json['id'] ?? '',
      idNaskah: json['idNaskah'] ?? '',
      idEditor: json['idEditor'] ?? '',
      status: StatusReview.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StatusReview.ditugaskan,
      ),
      rekomendasi: json['rekomendasi'] != null 
          ? Rekomendasi.values.firstWhere(
              (e) => e.name == json['rekomendasi'],
              orElse: () => Rekomendasi.revisi,
            )
          : null,
      catatan: json['catatan'],
      ditugaskanPada: json['ditugaskanPada'] != null 
          ? DateTime.parse(json['ditugaskanPada']) 
          : DateTime.now(),
      dimulaiPada: json['dimulaiPada'] != null ? DateTime.parse(json['dimulaiPada']) : null,
      selesaiPada: json['selesaiPada'] != null ? DateTime.parse(json['selesaiPada']) : null,
      naskah: NaskahInfo.fromJson(json['naskah'] ?? {}),
      editor: EditorInfo.fromJson(json['editor'] ?? {}),
      feedback: (json['feedback'] as List<dynamic>?)
          ?.map((f) => FeedbackReview.fromJson(f))
          .toList() ?? [],
      feedbackCount: feedbackCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idNaskah': idNaskah,
      'idEditor': idEditor,
      'status': status.name,
      'rekomendasi': rekomendasi?.name,
      'catatan': catatan,
      'ditugaskanPada': ditugaskanPada.toIso8601String(),
      'dimulaiPada': dimulaiPada?.toIso8601String(),
      'selesaiPada': selesaiPada?.toIso8601String(),
      'naskah': naskah.toJson(),
      'editor': editor.toJson(),
      'feedback': feedback.map((f) => f.toJson()).toList(),
    };
  }
}

/// Model untuk Info Naskah dalam Review
class NaskahInfo {
  final String id;
  final String judul;
  final String? subJudul;
  final String? sinopsis;
  final String? isbn;
  final StatusNaskah status;
  final String? urlSampul;
  final String? urlFile;
  final int? jumlahHalaman;
  final int? jumlahKata;
  final PenulisInfo? penulis;
  final KategoriInfo? kategori;
  final GenreInfo? genre;

  NaskahInfo({
    required this.id,
    required this.judul,
    this.subJudul,
    this.sinopsis,
    this.isbn,
    required this.status,
    this.urlSampul,
    this.urlFile,
    this.jumlahHalaman,
    this.jumlahKata,
    this.penulis,
    this.kategori,
    this.genre,
  });

  factory NaskahInfo.fromJson(Map<String, dynamic> json) {
    return NaskahInfo(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      subJudul: json['subJudul'],
      sinopsis: json['sinopsis'],
      isbn: json['isbn'],
      status: json['status'] != null 
          ? StatusNaskah.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => StatusNaskah.draft,
            )
          : StatusNaskah.draft,
      urlSampul: json['urlSampul'],
      urlFile: json['urlFile'],
      jumlahHalaman: json['jumlahHalaman'],
      jumlahKata: json['jumlahKata'],
      penulis: json['penulis'] != null ? PenulisInfo.fromJson(json['penulis']) : null,
      kategori: json['kategori'] != null ? KategoriInfo.fromJson(json['kategori']) : null,
      genre: json['genre'] != null ? GenreInfo.fromJson(json['genre']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'subJudul': subJudul,
      'sinopsis': sinopsis,
      'isbn': isbn,
      'status': status.name,
      'urlSampul': urlSampul,
      'urlFile': urlFile,
      'jumlahHalaman': jumlahHalaman,
      'jumlahKata': jumlahKata,
      'penulis': penulis?.toJson(),
      'kategori': kategori?.toJson(),
      'genre': genre?.toJson(),
    };
  }
}

/// Model untuk Info Penulis
class PenulisInfo {
  final String id;
  final String email;
  final ProfilPengguna? profilPengguna;

  PenulisInfo({
    required this.id,
    required this.email,
    this.profilPengguna,
  });

  factory PenulisInfo.fromJson(Map<String, dynamic> json) {
    return PenulisInfo(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      profilPengguna: json['profilPengguna'] != null 
          ? ProfilPengguna.fromJson(json['profilPengguna'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'profilPengguna': profilPengguna?.toJson(),
    };
  }
}

/// Model untuk Profil Pengguna
class ProfilPengguna {
  final String? namaDepan;
  final String? namaBelakang;
  final String? namaTampilan;

  ProfilPengguna({
    this.namaDepan,
    this.namaBelakang,
    this.namaTampilan,
  });

  factory ProfilPengguna.fromJson(Map<String, dynamic> json) {
    return ProfilPengguna(
      namaDepan: json['namaDepan'],
      namaBelakang: json['namaBelakang'],
      namaTampilan: json['namaTampilan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'namaDepan': namaDepan,
      'namaBelakang': namaBelakang,
      'namaTampilan': namaTampilan,
    };
  }

  String get namaLengkap => '${namaDepan ?? ''} ${namaBelakang ?? ''}'.trim();
}

/// Model untuk Info Editor
class EditorInfo {
  final String id;
  final String email;
  final ProfilPengguna? profilPengguna;

  EditorInfo({
    required this.id,
    required this.email,
    this.profilPengguna,
  });

  factory EditorInfo.fromJson(Map<String, dynamic> json) {
    return EditorInfo(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      profilPengguna: json['profilPengguna'] != null 
          ? ProfilPengguna.fromJson(json['profilPengguna'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'profilPengguna': profilPengguna?.toJson(),
    };
  }
}

/// Model untuk Kategori
class KategoriInfo {
  final String id;
  final String nama;
  final String slug;

  KategoriInfo({
    required this.id,
    required this.nama,
    required this.slug,
  });

  factory KategoriInfo.fromJson(Map<String, dynamic> json) {
    return KategoriInfo(
      id: json['id'],
      nama: json['nama'],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'slug': slug,
    };
  }
}

/// Model untuk Genre
class GenreInfo {
  final String id;
  final String nama;
  final String slug;

  GenreInfo({
    required this.id,
    required this.nama,
    required this.slug,
  });

  factory GenreInfo.fromJson(Map<String, dynamic> json) {
    return GenreInfo(
      id: json['id'],
      nama: json['nama'],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'slug': slug,
    };
  }
}

/// Model untuk Feedback Review
/// Sesuai dengan backend schema: bab, halaman, komentar
class FeedbackReview {
  final String id;
  final String idReview;
  final String? bab;
  final int? halaman;
  final String komentar;
  final DateTime dibuatPada;

  FeedbackReview({
    required this.id,
    required this.idReview,
    this.bab,
    this.halaman,
    required this.komentar,
    required this.dibuatPada,
  });

  factory FeedbackReview.fromJson(Map<String, dynamic> json) {
    return FeedbackReview(
      id: json['id'],
      idReview: json['idReview'],
      bab: json['bab'],
      halaman: json['halaman'],
      komentar: json['komentar'],
      dibuatPada: DateTime.parse(json['dibuatPada']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idReview': idReview,
      'bab': bab,
      'halaman': halaman,
      'komentar': komentar,
      'dibuatPada': dibuatPada.toIso8601String(),
    };
  }
}

/// Model untuk Statistik Review
class StatistikReview {
  final int totalReview;
  final Map<String, int> perStatus;
  final Map<String, int> perRekomendasi;
  final int rataRataHariReview;
  final List<ReviewTerbaru> reviewTerbaru;

  StatistikReview({
    required this.totalReview,
    required this.perStatus,
    required this.perRekomendasi,
    required this.rataRataHariReview,
    required this.reviewTerbaru,
  });

  factory StatistikReview.fromJson(Map<String, dynamic> json) {
    return StatistikReview(
      totalReview: json['totalReview'],
      perStatus: Map<String, int>.from(json['perStatus']),
      perRekomendasi: Map<String, int>.from(json['perRekomendasi']),
      rataRataHariReview: json['rataRataHariReview'],
      reviewTerbaru: (json['reviewTerbaru'] as List<dynamic>)
          .map((r) => ReviewTerbaru.fromJson(r))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReview': totalReview,
      'perStatus': perStatus,
      'perRekomendasi': perRekomendasi,
      'rataRataHariReview': rataRataHariReview,
      'reviewTerbaru': reviewTerbaru.map((r) => r.toJson()).toList(),
    };
  }
}

/// Model untuk Review Terbaru dalam Statistik
class ReviewTerbaru {
  final String id;
  final StatusReview status;
  final Rekomendasi? rekomendasi;
  final DateTime ditugaskanPada;
  final DateTime? selesaiPada;
  final String judulNaskah;

  ReviewTerbaru({
    required this.id,
    required this.status,
    this.rekomendasi,
    required this.ditugaskanPada,
    this.selesaiPada,
    required this.judulNaskah,
  });

  factory ReviewTerbaru.fromJson(Map<String, dynamic> json) {
    return ReviewTerbaru(
      id: json['id'],
      status: StatusReview.values.firstWhere((e) => e.name == json['status']),
      rekomendasi: json['rekomendasi'] != null 
          ? Rekomendasi.values.firstWhere((e) => e.name == json['rekomendasi'])
          : null,
      ditugaskanPada: DateTime.parse(json['ditugaskanPada']),
      selesaiPada: json['selesaiPada'] != null ? DateTime.parse(json['selesaiPada']) : null,
      judulNaskah: json['naskah']['judul'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'rekomendasi': rekomendasi?.name,
      'ditugaskanPada': ditugaskanPada.toIso8601String(),
      'selesaiPada': selesaiPada?.toIso8601String(),
      'naskah': {'judul': judulNaskah},
    };
  }
}

/// Model untuk Request Tugaskan Review
class TugaskanReviewRequest {
  final String idNaskah;
  final String idEditor;
  final String? catatan;

  TugaskanReviewRequest({
    required this.idNaskah,
    required this.idEditor,
    this.catatan,
  });

  Map<String, dynamic> toJson() {
    return {
      'idNaskah': idNaskah,
      'idEditor': idEditor,
      'catatan': catatan,
    };
  }
}

/// Model untuk Request Update Review
/// Sesuai dengan backend DTO: status, catatan, dimulaiPada
class PerbaruiReviewRequest {
  final StatusReview? status;
  final String? catatan;
  final DateTime? dimulaiPada;

  PerbaruiReviewRequest({
    this.status,
    this.catatan,
    this.dimulaiPada,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (status != null) data['status'] = status!.name;
    if (catatan != null) data['catatan'] = catatan;
    if (dimulaiPada != null) data['dimulaiPada'] = dimulaiPada!.toIso8601String();
    return data;
  }
}

/// Model untuk Request Submit Review
/// Catatan wajib diisi minimal 50 karakter (sesuai backend)
class SubmitReviewRequest {
  final Rekomendasi rekomendasi;
  final String catatan; // required, min 50 chars

  SubmitReviewRequest({
    required this.rekomendasi,
    required this.catatan,
  });

  Map<String, dynamic> toJson() {
    return {
      'rekomendasi': rekomendasi.name,
      'catatan': catatan,
    };
  }
}

/// Model untuk Request Tambah Feedback
/// Sesuai dengan backend DTO: bab (optional), halaman (optional), komentar (required min 10 chars)
class TambahFeedbackRequest {
  final String? bab;
  final int? halaman;
  final String komentar; // required, min 10 chars

  TambahFeedbackRequest({
    this.bab,
    this.halaman,
    required this.komentar,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'komentar': komentar,
    };
    if (bab != null) data['bab'] = bab;
    if (halaman != null) data['halaman'] = halaman;
    return data;
  }
}

/// Model untuk Filter Review
class FilterReview {
  final int halaman;
  final int limit;
  final StatusReview? status;
  final Rekomendasi? rekomendasi;
  final String? idNaskah;
  final String? idEditor;
  final String urutkan;
  final String arah;

  FilterReview({
    this.halaman = 1,
    this.limit = 20,
    this.status,
    this.rekomendasi,
    this.idNaskah,
    this.idEditor,
    this.urutkan = 'ditugaskanPada',
    this.arah = 'desc',
  });

  Map<String, String> toQueryParams() {
    Map<String, String> params = {
      'halaman': halaman.toString(),
      'limit': limit.toString(),
      'urutkan': urutkan,
      'arah': arah,
    };

    if (status != null) params['status'] = status!.name;
    if (rekomendasi != null) params['rekomendasi'] = rekomendasi!.name;
    if (idNaskah != null) params['idNaskah'] = idNaskah!;
    if (idEditor != null) params['idEditor'] = idEditor!;

    return params;
  }
}

/// Model untuk Response API
class ReviewResponse<T> {
  final bool sukses;
  final String pesan;
  final T? data;
  final Map<String, dynamic>? metadata;

  ReviewResponse({
    required this.sukses,
    required this.pesan,
    this.data,
    this.metadata,
  });

  factory ReviewResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ReviewResponse<T>(
      sukses: json['sukses'],
      pesan: json['pesan'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      metadata: json['metadata'],
    );
  }
}