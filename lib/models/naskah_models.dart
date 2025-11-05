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
