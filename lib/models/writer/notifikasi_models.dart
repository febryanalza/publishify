// Model untuk Notifikasi dari Backend API

class NotifikasiData {
  final String id;
  final String idPengguna;
  final String judul;
  final String pesan;
  final String tipe; // 'info', 'sukses', 'peringatan', 'error'
  final String? url;
  final bool dibaca;
  final String dibuatPada;
  final String? dibacaPada;

  NotifikasiData({
    required this.id,
    required this.idPengguna,
    required this.judul,
    required this.pesan,
    required this.tipe,
    this.url,
    required this.dibaca,
    required this.dibuatPada,
    this.dibacaPada,
  });

  factory NotifikasiData.fromJson(Map<String, dynamic> json) {
    return NotifikasiData(
      id: json['id'] ?? '',
      idPengguna: json['idPengguna'] ?? '',
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      tipe: json['tipe'] ?? 'info',
      url: json['url'],
      dibaca: json['dibaca'] ?? false,
      dibuatPada: json['dibuatPada'] ?? '',
      dibacaPada: json['dibacaPada'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPengguna': idPengguna,
      'judul': judul,
      'pesan': pesan,
      'tipe': tipe,
      'url': url,
      'dibaca': dibaca,
      'dibuatPada': dibuatPada,
      'dibacaPada': dibacaPada,
    };
  }
}

// Response untuk list notifikasi
class NotifikasiListResponse {
  final bool sukses;
  final String? pesan;
  final List<NotifikasiData>? data;
  final MetaDataNotifikasi? metadata;

  NotifikasiListResponse({
    required this.sukses,
    this.pesan,
    this.data,
    this.metadata,
  });

  factory NotifikasiListResponse.fromJson(Map<String, dynamic> json) {
    return NotifikasiListResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => NotifikasiData.fromJson(item))
              .toList()
          : null,
      metadata: json['metadata'] != null
          ? MetaDataNotifikasi.fromJson(json['metadata'])
          : null,
    );
  }
}

// Response untuk single notifikasi
class NotifikasiResponse {
  final bool sukses;
  final String? pesan;
  final NotifikasiData? data;

  NotifikasiResponse({
    required this.sukses,
    this.pesan,
    this.data,
  });

  factory NotifikasiResponse.fromJson(Map<String, dynamic> json) {
    return NotifikasiResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'],
      data: json['data'] != null
          ? NotifikasiData.fromJson(json['data'])
          : null,
    );
  }
}

// Response untuk count belum dibaca
class NotifikasiBelumDibacaResponse {
  final bool sukses;
  final String? pesan;
  final int? data;

  NotifikasiBelumDibacaResponse({
    required this.sukses,
    this.pesan,
    this.data,
  });

  factory NotifikasiBelumDibacaResponse.fromJson(Map<String, dynamic> json) {
    return NotifikasiBelumDibacaResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'],
      data: json['data'],
    );
  }
}

// Metadata untuk pagination
class MetaDataNotifikasi {
  final int total;
  final int halaman;
  final int limit;
  final int totalHalaman;

  MetaDataNotifikasi({
    required this.total,
    required this.halaman,
    required this.limit,
    required this.totalHalaman,
  });

  factory MetaDataNotifikasi.fromJson(Map<String, dynamic> json) {
    return MetaDataNotifikasi(
      total: json['total'] ?? 0,
      halaman: json['halaman'] ?? 1,
      limit: json['limit'] ?? 20,
      totalHalaman: json['totalHalaman'] ?? 0,
    );
  }
}
