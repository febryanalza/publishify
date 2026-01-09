/// Models untuk Naskah Masuk (Belum Direview)
/// Menampilkan naskah dengan status 'diajukan' yang belum memiliki review aktif

class NaskahMasukResponse {
  final bool sukses;
  final String pesan;
  final List<NaskahMasuk>? data;
  final MetadataPaginasi? metadata;

  NaskahMasukResponse({
    required this.sukses,
    required this.pesan,
    this.data,
    this.metadata,
  });

  factory NaskahMasukResponse.fromJson(Map<String, dynamic> json) {
    return NaskahMasukResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List).map((item) => NaskahMasuk.fromJson(item)).toList()
          : null,
      metadata: json['metadata'] != null
          ? MetadataPaginasi.fromJson(json['metadata'])
          : null,
    );
  }
}

class NaskahMasuk {
  final String id;
  final String judul;
  final String? subJudul;
  final String sinopsis;
  final String? isbn;
  final String status;
  final String? urlSampul;
  final String? urlFile;
  final int? jumlahHalaman;
  final int? jumlahKata;
  final String bahasaTulis;
  final bool publik;
  final DateTime dibuatPada;
  final DateTime diperbaruiPada;
  
  // Penulis info
  final String idPenulis;
  final PenulisNaskah penulis;
  
  // Kategori & Genre
  final KategoriNaskah kategori;
  final GenreNaskah genre;
  
  // Review info (untuk cek apakah sudah ada review)
  final List<ReviewInfo> review;

  NaskahMasuk({
    required this.id,
    required this.judul,
    this.subJudul,
    required this.sinopsis,
    this.isbn,
    required this.status,
    this.urlSampul,
    this.urlFile,
    this.jumlahHalaman,
    this.jumlahKata,
    required this.bahasaTulis,
    required this.publik,
    required this.dibuatPada,
    required this.diperbaruiPada,
    required this.idPenulis,
    required this.penulis,
    required this.kategori,
    required this.genre,
    required this.review,
  });

  factory NaskahMasuk.fromJson(Map<String, dynamic> json) {
    return NaskahMasuk(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      subJudul: json['subJudul'],
      sinopsis: json['sinopsis'] ?? '',
      isbn: json['isbn'],
      status: json['status'] ?? '',
      urlSampul: json['urlSampul'],
      urlFile: json['urlFile'],
      jumlahHalaman: json['jumlahHalaman'],
      jumlahKata: json['jumlahKata'],
      bahasaTulis: json['bahasaTulis'] ?? 'id',
      publik: json['publik'] ?? false,
      dibuatPada: DateTime.parse(json['dibuatPada']),
      diperbaruiPada: DateTime.parse(json['diperbaruiPada']),
      idPenulis: json['idPenulis'] ?? '',
      penulis: PenulisNaskah.fromJson(json['penulis'] ?? {}),
      kategori: KategoriNaskah.fromJson(json['kategori'] ?? {}),
      genre: GenreNaskah.fromJson(json['genre'] ?? {}),
      review: json['review'] != null
          ? (json['review'] as List).map((item) => ReviewInfo.fromJson(item)).toList()
          : [],
    );
  }

  /// Check apakah naskah sudah memiliki review aktif
  bool get hasActiveReview {
    return review.any((r) => 
      r.status == 'ditugaskan' || 
      r.status == 'dalam_proses'
    );
  }

  /// Get nama penulis
  String get namaPenulis {
    if (penulis.profilPengguna?.namaLengkap != null && 
        penulis.profilPengguna!.namaLengkap!.isNotEmpty) {
      return penulis.profilPengguna!.namaLengkap!;
    }
    return penulis.email;
  }
}

class PenulisNaskah {
  final String id;
  final String email;
  final ProfilPengguna? profilPengguna;

  PenulisNaskah({
    required this.id,
    required this.email,
    this.profilPengguna,
  });

  factory PenulisNaskah.fromJson(Map<String, dynamic> json) {
    return PenulisNaskah(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      profilPengguna: json['profilPengguna'] != null
          ? ProfilPengguna.fromJson(json['profilPengguna'])
          : null,
    );
  }
}

class ProfilPengguna {
  final String? namaDepan;
  final String? namaBelakang;
  final String? namaTampilan;
  final String? urlAvatar;

  ProfilPengguna({
    this.namaDepan,
    this.namaBelakang,
    this.namaTampilan,
    this.urlAvatar,
  });

  factory ProfilPengguna.fromJson(Map<String, dynamic> json) {
    return ProfilPengguna(
      namaDepan: json['namaDepan'],
      namaBelakang: json['namaBelakang'],
      namaTampilan: json['namaTampilan'],
      urlAvatar: json['urlAvatar'],
    );
  }

  String? get namaLengkap {
    if (namaTampilan != null && namaTampilan!.isNotEmpty) {
      return namaTampilan;
    }
    if (namaDepan != null || namaBelakang != null) {
      return '${namaDepan ?? ''} ${namaBelakang ?? ''}'.trim();
    }
    return null;
  }
}

class KategoriNaskah {
  final String id;
  final String nama;
  final String slug;

  KategoriNaskah({
    required this.id,
    required this.nama,
    required this.slug,
  });

  factory KategoriNaskah.fromJson(Map<String, dynamic> json) {
    return KategoriNaskah(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

class GenreNaskah {
  final String id;
  final String nama;
  final String slug;

  GenreNaskah({
    required this.id,
    required this.nama,
    required this.slug,
  });

  factory GenreNaskah.fromJson(Map<String, dynamic> json) {
    return GenreNaskah(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

class ReviewInfo {
  final String id;
  final String status;
  final String? idEditor;

  ReviewInfo({
    required this.id,
    required this.status,
    this.idEditor,
  });

  factory ReviewInfo.fromJson(Map<String, dynamic> json) {
    return ReviewInfo(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      idEditor: json['idEditor'],
    );
  }
}

class MetadataPaginasi {
  final int total;
  final int halaman;
  final int limit;
  final int totalHalaman;

  MetadataPaginasi({
    required this.total,
    required this.halaman,
    required this.limit,
    required this.totalHalaman,
  });

  factory MetadataPaginasi.fromJson(Map<String, dynamic> json) {
    return MetadataPaginasi(
      total: json['total'] ?? 0,
      halaman: json['halaman'] ?? 1,
      limit: json['limit'] ?? 20,
      totalHalaman: json['totalHalaman'] ?? 0,
    );
  }
}

/// Model untuk tugaskan review
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
      if (catatan != null) 'catatan': catatan,
    };
  }
}

class TugaskanReviewResponse {
  final bool sukses;
  final String pesan;
  final ReviewTugasan? data;

  TugaskanReviewResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory TugaskanReviewResponse.fromJson(Map<String, dynamic> json) {
    return TugaskanReviewResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? ReviewTugasan.fromJson(json['data']) : null,
    );
  }
}

class ReviewTugasan {
  final String id;
  final String idNaskah;
  final String idEditor;
  final String status;
  final String? catatan;
  final DateTime ditugaskanPada;

  ReviewTugasan({
    required this.id,
    required this.idNaskah,
    required this.idEditor,
    required this.status,
    this.catatan,
    required this.ditugaskanPada,
  });

  factory ReviewTugasan.fromJson(Map<String, dynamic> json) {
    return ReviewTugasan(
      id: json['id'] ?? '',
      idNaskah: json['idNaskah'] ?? '',
      idEditor: json['idEditor'] ?? '',
      status: json['status'] ?? '',
      catatan: json['catatan'],
      ditugaskanPada: DateTime.parse(json['ditugaskanPada']),
    );
  }
}

/// Model untuk daftar editor
class EditorListResponse {
  final bool sukses;
  final String pesan;
  final List<EditorInfo>? data;

  EditorListResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory EditorListResponse.fromJson(Map<String, dynamic> json) {
    return EditorListResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List).map((item) => EditorInfo.fromJson(item)).toList()
          : null,
    );
  }
}

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

  String get namaEditor {
    if (profilPengguna?.namaLengkap != null && 
        profilPengguna!.namaLengkap!.isNotEmpty) {
      return profilPengguna!.namaLengkap!;
    }
    return email;
  }
}
