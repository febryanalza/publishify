// Model untuk Response List Naskah dari API /api/naskah/penulis/saya
class NaskahListResponse {
  final bool sukses;
  final String pesan;
  final List<NaskahData>? data;
  final MetaData? metadata;

  NaskahListResponse({
    required this.sukses,
    required this.pesan,
    this.data,
    this.metadata,
  });

  factory NaskahListResponse.fromJson(Map<String, dynamic> json) {
    return NaskahListResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => NaskahData.fromJson(item))
              .toList()
          : null,
      metadata: json['metadata'] != null ? MetaData.fromJson(json['metadata']) : null,
    );
  }
}

// Model untuk Data Naskah
class NaskahData {
  final String id;
  final String judul;
  final String? subJudul;
  final String sinopsis;
  final String? isbn;
  final String status;
  final String? urlSampul;
  final int jumlahHalaman;
  final int jumlahKata;
  final bool publik;
  final String dibuatPada;
  final String diperbaruiPada;
  final NaskahPenulis? penulis;
  final NaskahKategori? kategori;
  final NaskahGenre? genre;
  final NaskahCount? count;

  NaskahData({
    required this.id,
    required this.judul,
    this.subJudul,
    required this.sinopsis,
    this.isbn,
    required this.status,
    this.urlSampul,
    required this.jumlahHalaman,
    required this.jumlahKata,
    required this.publik,
    required this.dibuatPada,
    required this.diperbaruiPada,
    this.penulis,
    this.kategori,
    this.genre,
    this.count,
  });

  factory NaskahData.fromJson(Map<String, dynamic> json) {
    return NaskahData(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      subJudul: json['subJudul'],
      sinopsis: json['sinopsis'] ?? '',
      isbn: json['isbn'],
      status: json['status'] ?? 'draft',
      urlSampul: json['urlSampul'],
      jumlahHalaman: json['jumlahHalaman'] ?? 0,
      jumlahKata: json['jumlahKata'] ?? 0,
      publik: json['publik'] ?? false,
      dibuatPada: json['dibuatPada'] ?? '',
      diperbaruiPada: json['diperbaruiPada'] ?? '',
      penulis: json['penulis'] != null ? NaskahPenulis.fromJson(json['penulis']) : null,
      kategori: json['kategori'] != null ? NaskahKategori.fromJson(json['kategori']) : null,
      genre: json['genre'] != null ? NaskahGenre.fromJson(json['genre']) : null,
      count: json['_count'] != null ? NaskahCount.fromJson(json['_count']) : null,
    );
  }
}

// Model untuk Penulis Naskah
class NaskahPenulis {
  final String id;
  final String email;
  final ProfilPengguna? profilPengguna;
  final ProfilPenulis? profilPenulis;

  NaskahPenulis({
    required this.id,
    required this.email,
    this.profilPengguna,
    this.profilPenulis,
  });

  factory NaskahPenulis.fromJson(Map<String, dynamic> json) {
    return NaskahPenulis(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      profilPengguna: json['profilPengguna'] != null
          ? ProfilPengguna.fromJson(json['profilPengguna'])
          : null,
      profilPenulis: json['profilPenulis'] != null
          ? ProfilPenulis.fromJson(json['profilPenulis'])
          : null,
    );
  }
}

class ProfilPengguna {
  final String namaDepan;
  final String namaBelakang;
  final String namaTampilan;
  final String? urlAvatar;

  ProfilPengguna({
    required this.namaDepan,
    required this.namaBelakang,
    required this.namaTampilan,
    this.urlAvatar,
  });

  factory ProfilPengguna.fromJson(Map<String, dynamic> json) {
    return ProfilPengguna(
      namaDepan: json['namaDepan'] ?? '',
      namaBelakang: json['namaBelakang'] ?? '',
      namaTampilan: json['namaTampilan'] ?? '',
      urlAvatar: json['urlAvatar'],
    );
  }
}

class ProfilPenulis {
  final String namaPena;
  final String ratingRataRata;

  ProfilPenulis({
    required this.namaPena,
    required this.ratingRataRata,
  });

  factory ProfilPenulis.fromJson(Map<String, dynamic> json) {
    return ProfilPenulis(
      namaPena: json['namaPena'] ?? '',
      ratingRataRata: json['ratingRataRata'] ?? '0.0',
    );
  }
}

// Model untuk Kategori Naskah
class NaskahKategori {
  final String id;
  final String nama;
  final String slug;

  NaskahKategori({
    required this.id,
    required this.nama,
    required this.slug,
  });

  factory NaskahKategori.fromJson(Map<String, dynamic> json) {
    return NaskahKategori(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

// Model untuk Genre Naskah
class NaskahGenre {
  final String id;
  final String nama;
  final String slug;

  NaskahGenre({
    required this.id,
    required this.nama,
    required this.slug,
  });

  factory NaskahGenre.fromJson(Map<String, dynamic> json) {
    return NaskahGenre(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

// Model untuk Count (revisi & review)
class NaskahCount {
  final int revisi;
  final int review;

  NaskahCount({
    required this.revisi,
    required this.review,
  });

  factory NaskahCount.fromJson(Map<String, dynamic> json) {
    return NaskahCount(
      revisi: json['revisi'] ?? 0,
      review: json['review'] ?? 0,
    );
  }
}

// Model untuk Metadata Pagination
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
      limit: json['limit'] ?? 10,
      totalHalaman: json['totalHalaman'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'halaman': halaman,
      'limit': limit,
      'totalHalaman': totalHalaman,
    };
  }
}

// Response model untuk detail naskah
class NaskahDetailResponse {
  final bool sukses;
  final String pesan;
  final NaskahDetail? data;

  NaskahDetailResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory NaskahDetailResponse.fromJson(Map<String, dynamic> json) {
    return NaskahDetailResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? NaskahDetail.fromJson(json['data']) : null,
    );
  }
}

class NaskahDetail {
  final String id;
  final String judul;
  final String? subJudul;
  final String sinopsis;
  final String? isbn;
  final String bahasaTulis;
  final int? jumlahHalaman;
  final int? jumlahKata;
  final String status;
  final String? urlSampul;
  final String? urlFile;
  final bool publik;
  final double? hargaJual;
  final String? formatBuku;
  final String dibuatPada;
  final String diperbaruiPada;
  final PenulisInfo penulis;
  final KategoriInfo kategori;
  final GenreInfo genre;
  final List<RevisiNaskah> revisi;
  final List<ReviewNaskah> review;

  NaskahDetail({
    required this.id,
    required this.judul,
    this.subJudul,
    required this.sinopsis,
    this.isbn,
    required this.bahasaTulis,
    this.jumlahHalaman,
    this.jumlahKata,
    required this.status,
    this.urlSampul,
    this.urlFile,
    required this.publik,
    this.hargaJual,
    this.formatBuku,
    required this.dibuatPada,
    required this.diperbaruiPada,
    required this.penulis,
    required this.kategori,
    required this.genre,
    required this.revisi,
    required this.review,
  });

  factory NaskahDetail.fromJson(Map<String, dynamic> json) {
    return NaskahDetail(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      subJudul: json['subJudul'],
      sinopsis: json['sinopsis'] ?? '',
      isbn: json['isbn'],
      bahasaTulis: json['bahasaTulis'] ?? 'id',
      jumlahHalaman: json['jumlahHalaman'],
      jumlahKata: json['jumlahKata'],
      status: json['status'] ?? 'draft',
      urlSampul: json['urlSampul'],
      urlFile: json['urlFile'],
      publik: json['publik'] ?? false,
      hargaJual: json['hargaJual'] != null ? (json['hargaJual'] as num).toDouble() : null,
      formatBuku: json['formatBuku'],
      dibuatPada: json['dibuatPada'] ?? '',
      diperbaruiPada: json['diperbaruiPada'] ?? '',
      penulis: PenulisInfo.fromJson(json['penulis'] ?? {}),
      kategori: KategoriInfo.fromJson(json['kategori'] ?? {}),
      genre: GenreInfo.fromJson(json['genre'] ?? {}),
      revisi: (json['revisi'] as List<dynamic>?)
          ?.map((e) => RevisiNaskah.fromJson(e))
          .toList() ?? [],
      review: (json['review'] as List<dynamic>?)
          ?.map((e) => ReviewNaskah.fromJson(e))
          .toList() ?? [],
    );
  }
}

class PenulisInfo {
  final String id;
  final String email;
  final ProfilPenggunaDetail? profilPengguna;

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
          ? ProfilPenggunaDetail.fromJson(json['profilPengguna'])
          : null,
    );
  }
}

class ProfilPenggunaDetail {
  final String? namaDepan;
  final String? namaBelakang;
  final String? namaTampilan;
  final String? urlAvatar;

  ProfilPenggunaDetail({
    this.namaDepan,
    this.namaBelakang,
    this.namaTampilan,
    this.urlAvatar,
  });

  factory ProfilPenggunaDetail.fromJson(Map<String, dynamic> json) {
    return ProfilPenggunaDetail(
      namaDepan: json['namaDepan'],
      namaBelakang: json['namaBelakang'],
      namaTampilan: json['namaTampilan'],
      urlAvatar: json['urlAvatar'],
    );
  }

  String get namaLengkap {
    if (namaTampilan?.isNotEmpty == true) return namaTampilan!;
    if (namaDepan?.isNotEmpty == true || namaBelakang?.isNotEmpty == true) {
      return '${namaDepan ?? ''} ${namaBelakang ?? ''}'.trim();
    }
    return 'Penulis Anonim';
  }
}

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
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

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
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

class RevisiNaskah {
  final String id;
  final int versi;
  final String catatan;
  final String? urlFile;
  final String dibuatPada;

  RevisiNaskah({
    required this.id,
    required this.versi,
    required this.catatan,
    this.urlFile,
    required this.dibuatPada,
  });

  factory RevisiNaskah.fromJson(Map<String, dynamic> json) {
    return RevisiNaskah(
      id: json['id'] ?? '',
      versi: json['versi'] ?? 1,
      catatan: json['catatan'] ?? '',
      urlFile: json['urlFile'],
      dibuatPada: json['dibuatPada'] ?? '',
    );
  }
}

class ReviewNaskah {
  final String id;
  final String status;
  final String? catatan;
  final String? rekomendasi;
  final String dibuatPada;
  final EditorInfo? editor;

  ReviewNaskah({
    required this.id,
    required this.status,
    this.catatan,
    this.rekomendasi,
    required this.dibuatPada,
    this.editor,
  });

  factory ReviewNaskah.fromJson(Map<String, dynamic> json) {
    return ReviewNaskah(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      catatan: json['catatan'],
      rekomendasi: json['rekomendasi'],
      dibuatPada: json['dibuatPada'] ?? '',
      editor: json['editor'] != null 
          ? EditorInfo.fromJson(json['editor'])
          : null,
    );
  }
}

class EditorInfo {
  final String id;
  final String email;
  final ProfilPenggunaDetail? profilPengguna;

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
          ? ProfilPenggunaDetail.fromJson(json['profilPengguna'])
          : null,
    );
  }
}

// ====================================
// MODELS UNTUK OPERASI NASKAH LANJUTAN
// ====================================

/// Request untuk terbitkan naskah (Editor/Admin)
/// PUT /api/naskah/:id/terbitkan
class TerbitkanNaskahRequest {
  final String isbn;
  final String? formatBuku; // A4, A5, B5
  final int? jumlahHalaman;

  TerbitkanNaskahRequest({
    required this.isbn,
    this.formatBuku,
    this.jumlahHalaman,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'isbn': isbn,
    };
    if (formatBuku != null) {
      data['formatBuku'] = formatBuku;
    }
    if (jumlahHalaman != null) {
      data['jumlahHalaman'] = jumlahHalaman;
    }
    return data;
  }
}

/// Response untuk terbitkan naskah
class TerbitkanNaskahResponse {
  final bool sukses;
  final String pesan;
  final NaskahData? data;

  TerbitkanNaskahResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory TerbitkanNaskahResponse.fromJson(Map<String, dynamic> json) {
    return TerbitkanNaskahResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? NaskahData.fromJson(json['data']) : null,
    );
  }
}

/// Request untuk ubah status naskah (Editor/Admin)
/// PUT /api/naskah/:id/status
class UbahStatusNaskahRequest {
  final String status;

  UbahStatusNaskahRequest({
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}

/// Response untuk ubah status naskah
class UbahStatusNaskahResponse {
  final bool sukses;
  final String pesan;
  final NaskahData? data;

  UbahStatusNaskahResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory UbahStatusNaskahResponse.fromJson(Map<String, dynamic> json) {
    return UbahStatusNaskahResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? NaskahData.fromJson(json['data']) : null,
    );
  }
}

/// Request untuk atur harga jual (Penulis)
/// PUT /api/naskah/:id/harga-jual
class AturHargaJualRequest {
  final double hargaJual;

  AturHargaJualRequest({
    required this.hargaJual,
  });

  Map<String, dynamic> toJson() {
    return {
      'hargaJual': hargaJual,
    };
  }
}

/// Response untuk atur harga jual
class AturHargaJualResponse {
  final bool sukses;
  final String pesan;
  final NaskahData? data;

  AturHargaJualResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory AturHargaJualResponse.fromJson(Map<String, dynamic> json) {
    return AturHargaJualResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? NaskahData.fromJson(json['data']) : null,
    );
  }
}

/// Response untuk hapus naskah (Penulis/Admin)
/// DELETE /api/naskah/:id
class HapusNaskahResponse {
  final bool sukses;
  final String pesan;

  HapusNaskahResponse({
    required this.sukses,
    required this.pesan,
  });

  factory HapusNaskahResponse.fromJson(Map<String, dynamic> json) {
    return HapusNaskahResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
    );
  }
}

/// Enum untuk status naskah
enum StatusNaskah {
  draft,
  diajukan,
  dalamReview,
  dalamEditing,
  siapTerbit,
  diterbitkan,
  ditolak,
  perluRevisi,
}

/// Extension untuk konversi StatusNaskah ke string backend
extension StatusNaskahExtension on StatusNaskah {
  String get value {
    switch (this) {
      case StatusNaskah.draft:
        return 'draft';
      case StatusNaskah.diajukan:
        return 'diajukan';
      case StatusNaskah.dalamReview:
        return 'dalam_review';
      case StatusNaskah.dalamEditing:
        return 'dalam_editing';
      case StatusNaskah.siapTerbit:
        return 'siap_terbit';
      case StatusNaskah.diterbitkan:
        return 'diterbitkan';
      case StatusNaskah.ditolak:
        return 'ditolak';
      case StatusNaskah.perluRevisi:
        return 'perlu_revisi';
    }
  }

  String get label {
    switch (this) {
      case StatusNaskah.draft:
        return 'Draft';
      case StatusNaskah.diajukan:
        return 'Diajukan';
      case StatusNaskah.dalamReview:
        return 'Dalam Review';
      case StatusNaskah.dalamEditing:
        return 'Dalam Editing';
      case StatusNaskah.siapTerbit:
        return 'Siap Terbit';
      case StatusNaskah.diterbitkan:
        return 'Diterbitkan';
      case StatusNaskah.ditolak:
        return 'Ditolak';
      case StatusNaskah.perluRevisi:
        return 'Perlu Revisi';
    }
  }

  static StatusNaskah fromString(String status) {
    switch (status) {
      case 'draft':
        return StatusNaskah.draft;
      case 'diajukan':
        return StatusNaskah.diajukan;
      case 'dalam_review':
        return StatusNaskah.dalamReview;
      case 'dalam_editing':
        return StatusNaskah.dalamEditing;
      case 'siap_terbit':
        return StatusNaskah.siapTerbit;
      case 'diterbitkan':
        return StatusNaskah.diterbitkan;
      case 'ditolak':
        return StatusNaskah.ditolak;
      case 'perlu_revisi':
        return StatusNaskah.perluRevisi;
      default:
        return StatusNaskah.draft;
    }
  }
}
