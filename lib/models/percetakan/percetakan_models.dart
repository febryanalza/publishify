// Models untuk module Percetakan (sesuai backend DTO & Prisma)
// Menggunakan data dari DTO pengguna + DTO percetakan

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
      id: (json['id'] ?? '').toString(),
      idNaskah: (json['idNaskah'] ?? '').toString(),
      idPemesan: (json['idPemesan'] ?? '').toString(),
      idPercetakan: json['idPercetakan']?.toString(),
      nomorPesanan: (json['nomorPesanan'] ?? '').toString(),
      jumlah: (json['jumlah'] is int) ? json['jumlah'] : int.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
      formatKertas: (json['formatKertas'] ?? '').toString(),
      jenisKertas: (json['jenisKertas'] ?? '').toString(),
      jenisCover: (json['jenisCover'] ?? '').toString(),
      finishingTambahan: (json['finishingTambahan'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      catatan: json['catatan']?.toString(),
      hargaTotal: (json['hargaTotal'] ?? '0').toString(),
      status: (json['status'] ?? 'tertunda').toString(),
      tanggalPesan: json['tanggalPesan'] != null
          ? DateTime.parse(json['tanggalPesan'].toString())
          : DateTime.now(),
      estimasiSelesai: json['estimasiSelesai'] != null
          ? DateTime.tryParse(json['estimasiSelesai'].toString())
          : null,
      tanggalSelesai: json['tanggalSelesai'] != null
          ? DateTime.tryParse(json['tanggalSelesai'].toString())
          : null,
      diperbaruiPada: json['diperbaruiPada'] != null
          ? DateTime.parse(json['diperbaruiPada'].toString())
          : DateTime.now(),
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
  final String? urlSampul;

  const NaskahInfo({
    required this.id,
    required this.judul,
    this.jumlahHalaman,
    this.urlSampul,
  });

  factory NaskahInfo.fromJson(Map<String, dynamic> json) {
    return NaskahInfo(
      id: (json['id'] ?? '').toString(),
      judul: (json['judul'] ?? 'Tanpa Judul').toString(),
      jumlahHalaman: json['jumlahHalaman'] is int 
          ? json['jumlahHalaman'] 
          : int.tryParse(json['jumlahHalaman']?.toString() ?? ''),
      urlSampul: json['urlSampul']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'jumlahHalaman': jumlahHalaman,
      'urlSampul': urlSampul,
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
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
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
      namaDepan: json['namaDepan']?.toString(),
      namaBelakang: json['namaBelakang']?.toString(),
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
      id: (json['id'] ?? '').toString(),
      idPesanan: (json['idPesanan'] ?? '').toString(),
      metodePembayaran: (json['metodePembayaran'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      tanggalBayar: json['tanggalBayar'] != null
          ? DateTime.tryParse(json['tanggalBayar'].toString())
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
      id: (json['id'] ?? '').toString(),
      idPesanan: (json['idPesanan'] ?? '').toString(),
      namaEkspedisi: (json['namaEkspedisi'] ?? '').toString(),
      nomorResi: json['nomorResi']?.toString(),
      status: (json['status'] ?? '').toString(),
      tanggalKirim: json['tanggalKirim'] != null
          ? DateTime.tryParse(json['tanggalKirim'].toString())
          : null,
      estimasiTiba: json['estimasiTiba'] != null
          ? DateTime.tryParse(json['estimasiTiba'].toString())
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
      totalPesanan: (json['totalPesanan'] is int) 
          ? json['totalPesanan'] 
          : int.tryParse(json['totalPesanan']?.toString() ?? '0') ?? 0,
      pesananAktif: (json['pesananAktif'] is int) 
          ? json['pesananAktif'] 
          : int.tryParse(json['pesananAktif']?.toString() ?? '0') ?? 0,
      pesananSelesai: (json['pesananSelesai'] is int) 
          ? json['pesananSelesai'] 
          : int.tryParse(json['pesananSelesai']?.toString() ?? '0') ?? 0,
      totalRevenue: (json['totalRevenue'] ?? '0').toString(),
      statusBreakdown: json['statusBreakdown'] != null
          ? StatusBreakdown.fromJson(json['statusBreakdown'] as Map<String, dynamic>)
          : const StatusBreakdown(
              tertunda: 0,
              diterima: 0,
              dalamProduksi: 0,
              kontrolKualitas: 0,
              siap: 0,
              dikirim: 0,
              terkirim: 0,
              dibatalkan: 0,
            ),
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
    // Backend hanya mengirim status yang ada datanya
    // Jadi kita perlu default 0 untuk status yang tidak ada
    return StatusBreakdown(
      tertunda: (json['tertunda'] as int?) ?? 0,
      diterima: (json['diterima'] as int?) ?? 0,
      dalamProduksi: (json['dalam_produksi'] as int?) ?? 0,
      kontrolKualitas: (json['kontrol_kualitas'] as int?) ?? 0,
      siap: (json['siap'] as int?) ?? 0,
      dikirim: (json['dikirim'] as int?) ?? 0,
      terkirim: (json['terkirim'] as int?) ?? 0,
      dibatalkan: (json['dibatalkan'] as int?) ?? 0,
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
  final String? pesan;
  final List<PesananCetak>? data;
  final PaginationMeta? metadata;

  const PesananListResponse({
    required this.sukses,
    this.pesan,
    this.data,
    this.metadata,
  });

  factory PesananListResponse.fromJson(Map<String, dynamic> json) {
    try {
      return PesananListResponse(
        sukses: json['sukses'] == true,
        pesan: json['pesan']?.toString(),
        data: json['data'] != null
            ? (json['data'] as List<dynamic>)
                .map((e) {
                  try {
                    return PesananCetak.fromJson(e as Map<String, dynamic>);
                  } catch (e) {
                    print('Error parsing pesanan: $e');
                    return null;
                  }
                })
                .whereType<PesananCetak>()
                .toList()
            : null,
        metadata: json['metadata'] != null
            ? PaginationMeta.fromJson(json['metadata'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('Error parsing PesananListResponse: $e');
      rethrow;
    }
  }
}

/// API Response untuk single pesanan
class PesananDetailResponse {
  final bool sukses;
  final String? pesan;
  final PesananCetak? data;

  const PesananDetailResponse({
    required this.sukses,
    this.pesan,
    this.data,
  });

  factory PesananDetailResponse.fromJson(Map<String, dynamic> json) {
    try {
      return PesananDetailResponse(
        sukses: json['sukses'] == true,
        pesan: json['pesan']?.toString(),
        data: json['data'] != null
            ? PesananCetak.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('Error parsing PesananDetailResponse: $e');
      rethrow;
    }
  }
}

/// API Response untuk statistik
class StatsResponse {
  final bool sukses;
  final String? pesan;
  final PercetakanStats? data;

  const StatsResponse({
    required this.sukses,
    this.pesan,
    this.data,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    try {
      return StatsResponse(
        sukses: json['sukses'] == true,
        pesan: json['pesan']?.toString(),
        data: json['data'] != null
            ? PercetakanStats.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('Error parsing StatsResponse: $e');
      rethrow;
    }
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
      total: (json['total'] is int) 
          ? json['total'] 
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      halaman: (json['halaman'] is int) 
          ? json['halaman'] 
          : int.tryParse(json['halaman']?.toString() ?? '1') ?? 1,
      limit: (json['limit'] is int) 
          ? json['limit'] 
          : int.tryParse(json['limit']?.toString() ?? '20') ?? 20,
      totalHalaman: (json['totalHalaman'] is int) 
          ? json['totalHalaman'] 
          : int.tryParse(json['totalHalaman']?.toString() ?? '1') ?? 1,
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
