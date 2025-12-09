/// Models untuk module Percetakan (sesuai backend DTO & Prisma)
/// Menggunakan data dari DTO pengguna + DTO percetakan

/// Model utama untuk Pesanan Cetak
class PesananCetak {
  final String id;
  final String idNaskah;
  final String idPemesan;
  final String? idPercetakan;
  final String nomorPesanan;
  final int jumlah;
  final String formatKertas; // A4, A5, B5, Letter, Custom
  final String jenisKertas; // HVS 70gr, HVS 80gr, Art Paper, dll
  final String jenisCover; // Soft Cover, Hard Cover, Board Cover
  final List<String> finishingTambahan; // Laminasi, Emboss, dll
  final String? catatan;
  final String hargaTotal; // Decimal dari backend
  final String status; // tertunda, diterima, dalam_produksi, dll
  final DateTime tanggalPesan;
  final DateTime? estimasiSelesai;
  final DateTime? tanggalSelesai;
  final DateTime diperbaruiPada;
  
  // Relasi (include dari backend)
  final NaskahInfo? naskah;
  final PemesanInfo? pemesan;
  final PembayaranInfo? pembayaran;
  final PengirimanInfo? pengiriman;

  const PesananCetak({
    required this.id,
    required this.idNaskah,
    required this.idPemesan,
    this.idPercetakan,
    required this.nomorPesanan,
    required this.jumlah,
    required this.formatKertas,
    required this.jenisKertas,
    required this.jenisCover,
    this.finishingTambahan = const [],
    this.catatan,
    required this.hargaTotal,
    required this.status,
    required this.tanggalPesan,
    this.estimasiSelesai,
    this.tanggalSelesai,
    required this.diperbaruiPada,
    this.naskah,
    this.pemesan,
    this.pembayaran,
    this.pengiriman,
  });

  factory PesananCetak.fromJson(Map<String, dynamic> json) {
    return PesananCetak(
      id: json['id'] as String,
      idNaskah: json['idNaskah'] as String,
      idPemesan: json['idPemesan'] as String,
      idPercetakan: json['idPercetakan'] as String?,
      nomorPesanan: json['nomorPesanan'] as String,
      jumlah: json['jumlah'] as int,
      formatKertas: json['formatKertas'] as String,
      jenisKertas: json['jenisKertas'] as String,
      jenisCover: json['jenisCover'] as String,
      finishingTambahan: (json['finishingTambahan'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      catatan: json['catatan'] as String?,
      hargaTotal: json['hargaTotal'].toString(),
      status: json['status'] as String,
      tanggalPesan: DateTime.parse(json['tanggalPesan'] as String),
      estimasiSelesai: json['estimasiSelesai'] != null
          ? DateTime.parse(json['estimasiSelesai'] as String)
          : null,
      tanggalSelesai: json['tanggalSelesai'] != null
          ? DateTime.parse(json['tanggalSelesai'] as String)
          : null,
      diperbaruiPada: DateTime.parse(json['diperbaruiPada'] as String),
      naskah: json['naskah'] != null
          ? NaskahInfo.fromJson(json['naskah'] as Map<String, dynamic>)
          : null,
      pemesan: json['pemesan'] != null
          ? PemesanInfo.fromJson(json['pemesan'] as Map<String, dynamic>)
          : null,
      pembayaran: json['pembayaran'] != null
          ? PembayaranInfo.fromJson(json['pembayaran'] as Map<String, dynamic>)
          : null,
      pengiriman: json['pengiriman'] != null
          ? PengirimanInfo.fromJson(json['pengiriman'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idNaskah': idNaskah,
      'idPemesan': idPemesan,
      'idPercetakan': idPercetakan,
      'nomorPesanan': nomorPesanan,
      'jumlah': jumlah,
      'formatKertas': formatKertas,
      'jenisKertas': jenisKertas,
      'jenisCover': jenisCover,
      'finishingTambahan': finishingTambahan,
      'catatan': catatan,
      'hargaTotal': hargaTotal,
      'status': status,
      'tanggalPesan': tanggalPesan.toIso8601String(),
      'estimasiSelesai': estimasiSelesai?.toIso8601String(),
      'tanggalSelesai': tanggalSelesai?.toIso8601String(),
      'diperbaruiPada': diperbaruiPada.toIso8601String(),
      if (naskah != null) 'naskah': naskah!.toJson(),
      if (pemesan != null) 'pemesan': pemesan!.toJson(),
      if (pembayaran != null) 'pembayaran': pembayaran!.toJson(),
      if (pengiriman != null) 'pengiriman': pengiriman!.toJson(),
    };
  }
}

/// Model untuk informasi naskah dalam pesanan
class NaskahInfo {
  final String id;
  final String judul;
  final int? jumlahHalaman;

  const NaskahInfo({
    required this.id,
    required this.judul,
    this.jumlahHalaman,
  });

  factory NaskahInfo.fromJson(Map<String, dynamic> json) {
    return NaskahInfo(
      id: json['id'] as String,
      judul: json['judul'] as String,
      jumlahHalaman: json['jumlahHalaman'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'jumlahHalaman': jumlahHalaman,
    };
  }
}

/// Model untuk informasi pemesan (penulis)
class PemesanInfo {
  final String id;
  final String email;
  final ProfilPenggunaInfo? profilPengguna;

  const PemesanInfo({
    required this.id,
    required this.email,
    this.profilPengguna,
  });

  factory PemesanInfo.fromJson(Map<String, dynamic> json) {
    return PemesanInfo(
      id: json['id'] as String,
      email: json['email'] as String,
      profilPengguna: json['profilPengguna'] != null
          ? ProfilPenggunaInfo.fromJson(
              json['profilPengguna'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (profilPengguna != null) 'profilPengguna': profilPengguna!.toJson(),
    };
  }
}

/// Model untuk profil pengguna
class ProfilPenggunaInfo {
  final String? namaDepan;
  final String? namaBelakang;

  const ProfilPenggunaInfo({
    this.namaDepan,
    this.namaBelakang,
  });

  factory ProfilPenggunaInfo.fromJson(Map<String, dynamic> json) {
    return ProfilPenggunaInfo(
      namaDepan: json['namaDepan'] as String?,
      namaBelakang: json['namaBelakang'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'namaDepan': namaDepan,
      'namaBelakang': namaBelakang,
    };
  }

  String get namaLengkap {
    if (namaDepan == null && namaBelakang == null) return 'User';
    return '${namaDepan ?? ''} ${namaBelakang ?? ''}'.trim();
  }
}

/// Model untuk informasi pembayaran
class PembayaranInfo {
  final String id;
  final String idPesanan;
  final String metodePembayaran;
  final String status;
  final DateTime? tanggalBayar;

  const PembayaranInfo({
    required this.id,
    required this.idPesanan,
    required this.metodePembayaran,
    required this.status,
    this.tanggalBayar,
  });

  factory PembayaranInfo.fromJson(Map<String, dynamic> json) {
    return PembayaranInfo(
      id: json['id'] as String,
      idPesanan: json['idPesanan'] as String,
      metodePembayaran: json['metodePembayaran'] as String,
      status: json['status'] as String,
      tanggalBayar: json['tanggalBayar'] != null
          ? DateTime.parse(json['tanggalBayar'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPesanan': idPesanan,
      'metodePembayaran': metodePembayaran,
      'status': status,
      'tanggalBayar': tanggalBayar?.toIso8601String(),
    };
  }
}

/// Model untuk informasi pengiriman
class PengirimanInfo {
  final String id;
  final String idPesanan;
  final String namaEkspedisi;
  final String? nomorResi;
  final String status;
  final DateTime? tanggalKirim;
  final DateTime? estimasiTiba;

  const PengirimanInfo({
    required this.id,
    required this.idPesanan,
    required this.namaEkspedisi,
    this.nomorResi,
    required this.status,
    this.tanggalKirim,
    this.estimasiTiba,
  });

  factory PengirimanInfo.fromJson(Map<String, dynamic> json) {
    return PengirimanInfo(
      id: json['id'] as String,
      idPesanan: json['idPesanan'] as String,
      namaEkspedisi: json['namaEkspedisi'] as String,
      nomorResi: json['nomorResi'] as String?,
      status: json['status'] as String,
      tanggalKirim: json['tanggalKirim'] != null
          ? DateTime.parse(json['tanggalKirim'] as String)
          : null,
      estimasiTiba: json['estimasiTiba'] != null
          ? DateTime.parse(json['estimasiTiba'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPesanan': idPesanan,
      'namaEkspedisi': namaEkspedisi,
      'nomorResi': nomorResi,
      'status': status,
      'tanggalKirim': tanggalKirim?.toIso8601String(),
      'estimasiTiba': estimasiTiba?.toIso8601String(),
    };
  }
}

/// Model untuk statistik percetakan
class PercetakanStats {
  final int totalPesanan;
  final int pesananAktif;
  final int pesananSelesai;
  final String totalRevenue;
  final StatusBreakdown statusBreakdown;

  const PercetakanStats({
    required this.totalPesanan,
    required this.pesananAktif,
    required this.pesananSelesai,
    required this.totalRevenue,
    required this.statusBreakdown,
  });

  factory PercetakanStats.fromJson(Map<String, dynamic> json) {
    return PercetakanStats(
      totalPesanan: json['totalPesanan'] as int,
      pesananAktif: json['pesananAktif'] as int,
      pesananSelesai: json['pesananSelesai'] as int,
      totalRevenue: json['totalRevenue'].toString(),
      statusBreakdown: StatusBreakdown.fromJson(
          json['statusBreakdown'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPesanan': totalPesanan,
      'pesananAktif': pesananAktif,
      'pesananSelesai': pesananSelesai,
      'totalRevenue': totalRevenue,
      'statusBreakdown': statusBreakdown.toJson(),
    };
  }
}

/// Model untuk breakdown status pesanan
class StatusBreakdown {
  final int tertunda;
  final int diterima;
  final int dalamProduksi;
  final int kontrolKualitas;
  final int siap;
  final int dikirim;
  final int terkirim;
  final int dibatalkan;

  const StatusBreakdown({
    required this.tertunda,
    required this.diterima,
    required this.dalamProduksi,
    required this.kontrolKualitas,
    required this.siap,
    required this.dikirim,
    required this.terkirim,
    required this.dibatalkan,
  });

  factory StatusBreakdown.fromJson(Map<String, dynamic> json) {
    return StatusBreakdown(
      tertunda: json['tertunda'] as int,
      diterima: json['diterima'] as int,
      dalamProduksi: json['dalam_produksi'] as int,
      kontrolKualitas: json['kontrol_kualitas'] as int,
      siap: json['siap'] as int,
      dikirim: json['dikirim'] as int,
      terkirim: json['terkirim'] as int,
      dibatalkan: json['dibatalkan'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tertunda': tertunda,
      'diterima': diterima,
      'dalam_produksi': dalamProduksi,
      'kontrol_kualitas': kontrolKualitas,
      'siap': siap,
      'dikirim': dikirim,
      'terkirim': terkirim,
      'dibatalkan': dibatalkan,
    };
  }
}

/// API Response untuk list pesanan
class PesananListResponse {
  final bool sukses;
  final String pesan;
  final List<PesananCetak>? data;
  final PaginationMeta? metadata;

  const PesananListResponse({
    required this.sukses,
    required this.pesan,
    this.data,
    this.metadata,
  });

  factory PesananListResponse.fromJson(Map<String, dynamic> json) {
    return PesananListResponse(
      sukses: json['sukses'] as bool,
      pesan: json['pesan'] as String,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((e) => PesananCetak.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      metadata: json['metadata'] != null
          ? PaginationMeta.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// API Response untuk single pesanan
class PesananDetailResponse {
  final bool sukses;
  final String pesan;
  final PesananCetak? data;

  const PesananDetailResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory PesananDetailResponse.fromJson(Map<String, dynamic> json) {
    return PesananDetailResponse(
      sukses: json['sukses'] as bool,
      pesan: json['pesan'] as String,
      data: json['data'] != null
          ? PesananCetak.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// API Response untuk statistik
class StatsResponse {
  final bool sukses;
  final String pesan;
  final PercetakanStats? data;

  const StatsResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    return StatsResponse(
      sukses: json['sukses'] as bool,
      pesan: json['pesan'] as String,
      data: json['data'] != null
          ? PercetakanStats.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Model untuk pagination metadata
class PaginationMeta {
  final int total;
  final int halaman;
  final int limit;
  final int totalHalaman;

  const PaginationMeta({
    required this.total,
    required this.halaman,
    required this.limit,
    required this.totalHalaman,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int,
      halaman: json['halaman'] as int,
      limit: json['limit'] as int,
      totalHalaman: json['totalHalaman'] as int,
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
