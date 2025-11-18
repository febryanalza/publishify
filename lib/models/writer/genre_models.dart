class GenreResponse {
  final bool sukses;
  final List<Genre>? data;
  final GenreMetadata? metadata;
  final int? total;

  GenreResponse({
    required this.sukses,
    this.data,
    this.metadata,
    this.total,
  });

  factory GenreResponse.fromJson(Map<String, dynamic> json) {
    return GenreResponse(
      sukses: json['sukses'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((e) => Genre.fromJson(e)).toList()
          : null,
      metadata: json['metadata'] != null
          ? GenreMetadata.fromJson(json['metadata'])
          : null,
      total: json['total'],
    );
  }
}

class Genre {
  final String id;
  final String nama;
  final String slug;
  final String? deskripsi;
  final bool? aktif;
  final String? dibuatPada;
  final String? diperbaruiPada;
  final GenreCount? count;

  Genre({
    required this.id,
    required this.nama,
    required this.slug,
    this.deskripsi,
    this.aktif,
    this.dibuatPada,
    this.diperbaruiPada,
    this.count,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      slug: json['slug'] ?? '',
      deskripsi: json['deskripsi'],
      aktif: json['aktif'],
      dibuatPada: json['dibuatPada'],
      diperbaruiPada: json['diperbaruiPada'],
      count: json['_count'] != null ? GenreCount.fromJson(json['_count']) : null,
    );
  }
}

class GenreCount {
  final int naskah;

  GenreCount({required this.naskah});

  factory GenreCount.fromJson(Map<String, dynamic> json) {
    return GenreCount(
      naskah: json['naskah'] ?? 0,
    );
  }
}

class GenreMetadata {
  final int total;
  final int halaman;
  final int limit;
  final int totalHalaman;

  GenreMetadata({
    required this.total,
    required this.halaman,
    required this.limit,
    required this.totalHalaman,
  });

  factory GenreMetadata.fromJson(Map<String, dynamic> json) {
    return GenreMetadata(
      total: json['total'] ?? 0,
      halaman: json['halaman'] ?? 1,
      limit: json['limit'] ?? 20,
      totalHalaman: json['totalHalaman'] ?? 0,
    );
  }
}
