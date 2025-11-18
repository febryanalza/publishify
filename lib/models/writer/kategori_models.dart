class KategoriResponse {
  final bool sukses;
  final List<Kategori>? data;
  final KategoriMetadata? metadata;
  final int? total;

  KategoriResponse({
    required this.sukses,
    this.data,
    this.metadata,
    this.total,
  });

  factory KategoriResponse.fromJson(Map<String, dynamic> json) {
    return KategoriResponse(
      sukses: json['sukses'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((e) => Kategori.fromJson(e)).toList()
          : null,
      metadata: json['metadata'] != null
          ? KategoriMetadata.fromJson(json['metadata'])
          : null,
      total: json['total'],
    );
  }
}

class Kategori {
  final String id;
  final String nama;
  final String slug;
  final String? deskripsi;
  final bool? aktif;
  final String? dibuatPada;
  final String? diperbaruiPada;
  final KategoriCount? count;

  Kategori({
    required this.id,
    required this.nama,
    required this.slug,
    this.deskripsi,
    this.aktif,
    this.dibuatPada,
    this.diperbaruiPada,
    this.count,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      slug: json['slug'] ?? '',
      deskripsi: json['deskripsi'],
      aktif: json['aktif'],
      dibuatPada: json['dibuatPada'],
      diperbaruiPada: json['diperbaruiPada'],
      count: json['_count'] != null ? KategoriCount.fromJson(json['_count']) : null,
    );
  }
}

class KategoriCount {
  final int naskah;

  KategoriCount({required this.naskah});

  factory KategoriCount.fromJson(Map<String, dynamic> json) {
    return KategoriCount(
      naskah: json['naskah'] ?? 0,
    );
  }
}

class KategoriMetadata {
  final int total;
  final int halaman;
  final int limit;
  final int totalHalaman;

  KategoriMetadata({
    required this.total,
    required this.halaman,
    required this.limit,
    required this.totalHalaman,
  });

  factory KategoriMetadata.fromJson(Map<String, dynamic> json) {
    return KategoriMetadata(
      total: json['total'] ?? 0,
      halaman: json['halaman'] ?? 1,
      limit: json['limit'] ?? 20,
      totalHalaman: json['totalHalaman'] ?? 0,
    );
  }
}
