// Models untuk module Pembayaran (sesuai backend DTO & Prisma)
// Digunakan untuk halaman pembayaran percetakan

/// Model utama untuk Pembayaran
class Pembayaran {
  final String id;
  final String idPesanan;
  final String idPengguna;
  final String nomorTransaksi;
  final String jumlah; // Decimal dari backend
  final String metodePembayaran;
  final String status;
  final String? urlBukti;
  final String? catatanPembayaran;
  final DateTime? tanggalPembayaran;
  final DateTime dibuatPada;
  final DateTime diperbaruiPada;

  // Relasi
  final PesananInfoPembayaran? pesanan;
  final PenggunaPembayaran? pengguna;

  const Pembayaran({
    required this.id,
    required this.idPesanan,
    required this.idPengguna,
    required this.nomorTransaksi,
    required this.jumlah,
    required this.metodePembayaran,
    required this.status,
    this.urlBukti,
    this.catatanPembayaran,
    this.tanggalPembayaran,
    required this.dibuatPada,
    required this.diperbaruiPada,
    this.pesanan,
    this.pengguna,
  });

  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    return Pembayaran(
      id: json['id'] as String,
      idPesanan: json['idPesanan'] as String,
      idPengguna: json['idPengguna'] as String,
      nomorTransaksi: json['nomorTransaksi'] as String,
      jumlah: json['jumlah'].toString(),
      metodePembayaran: json['metodePembayaran'] as String,
      status: json['status'] as String,
      urlBukti: json['urlBukti'] as String?,
      catatanPembayaran: json['catatanPembayaran'] as String?,
      tanggalPembayaran: json['tanggalPembayaran'] != null
          ? DateTime.parse(json['tanggalPembayaran'] as String)
          : null,
      dibuatPada: DateTime.parse(json['dibuatPada'] as String),
      diperbaruiPada: DateTime.parse(json['diperbaruiPada'] as String),
      pesanan: json['pesanan'] != null
          ? PesananInfoPembayaran.fromJson(json['pesanan'] as Map<String, dynamic>)
          : null,
      pengguna: json['pengguna'] != null
          ? PenggunaPembayaran.fromJson(json['pengguna'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPesanan': idPesanan,
      'idPengguna': idPengguna,
      'nomorTransaksi': nomorTransaksi,
      'jumlah': jumlah,
      'metodePembayaran': metodePembayaran,
      'status': status,
      'urlBukti': urlBukti,
      'catatanPembayaran': catatanPembayaran,
      'tanggalPembayaran': tanggalPembayaran?.toIso8601String(),
      'dibuatPada': dibuatPada.toIso8601String(),
      'diperbaruiPada': diperbaruiPada.toIso8601String(),
      if (pesanan != null) 'pesanan': pesanan!.toJson(),
      if (pengguna != null) 'pengguna': pengguna!.toJson(),
    };
  }
}

/// Info pesanan dalam pembayaran
class PesananInfoPembayaran {
  final String id;
  final String nomorPesanan;
  final int jumlah;
  final String hargaTotal;
  final NaskahInfoPembayaran? naskah;

  const PesananInfoPembayaran({
    required this.id,
    required this.nomorPesanan,
    required this.jumlah,
    required this.hargaTotal,
    this.naskah,
  });

  factory PesananInfoPembayaran.fromJson(Map<String, dynamic> json) {
    return PesananInfoPembayaran(
      id: json['id'] as String,
      nomorPesanan: json['nomorPesanan'] as String,
      jumlah: json['jumlah'] as int,
      hargaTotal: json['hargaTotal'].toString(),
      naskah: json['naskah'] != null
          ? NaskahInfoPembayaran.fromJson(json['naskah'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomorPesanan': nomorPesanan,
      'jumlah': jumlah,
      'hargaTotal': hargaTotal,
      if (naskah != null) 'naskah': naskah!.toJson(),
    };
  }
}

/// Info naskah dalam pembayaran
class NaskahInfoPembayaran {
  final String id;
  final String judul;
  final String? isbn;

  const NaskahInfoPembayaran({
    required this.id,
    required this.judul,
    this.isbn,
  });

  factory NaskahInfoPembayaran.fromJson(Map<String, dynamic> json) {
    return NaskahInfoPembayaran(
      id: json['id'] as String,
      judul: json['judul'] as String,
      isbn: json['isbn'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isbn': isbn,
    };
  }
}

/// Info pengguna pembayaran
class PenggunaPembayaran {
  final String id;
  final String email;
  final String? telepon;
  final ProfilPenggunaPembayaran? profilPengguna;

  const PenggunaPembayaran({
    required this.id,
    required this.email,
    this.telepon,
    this.profilPengguna,
  });

  factory PenggunaPembayaran.fromJson(Map<String, dynamic> json) {
    return PenggunaPembayaran(
      id: json['id'] as String,
      email: json['email'] as String,
      telepon: json['telepon'] as String?,
      profilPengguna: json['profilPengguna'] != null
          ? ProfilPenggunaPembayaran.fromJson(
              json['profilPengguna'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'telepon': telepon,
      if (profilPengguna != null) 'profilPengguna': profilPengguna!.toJson(),
    };
  }

  String get namaLengkap {
    if (profilPengguna == null) return email;
    return profilPengguna!.namaLengkap;
  }
}

/// Profil pengguna dalam pembayaran
class ProfilPenggunaPembayaran {
  final String? namaDepan;
  final String? namaBelakang;

  const ProfilPenggunaPembayaran({
    this.namaDepan,
    this.namaBelakang,
  });

  factory ProfilPenggunaPembayaran.fromJson(Map<String, dynamic> json) {
    return ProfilPenggunaPembayaran(
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

/// API Response untuk list pembayaran
class PembayaranListResponse {
  final bool sukses;
  final String? pesan;
  final List<Pembayaran>? data;
  final PaginationMetaPembayaran? metadata;

  const PembayaranListResponse({
    required this.sukses,
    this.pesan,
    this.data,
    this.metadata,
  });

  factory PembayaranListResponse.fromJson(Map<String, dynamic> json) {
    return PembayaranListResponse(
      sukses: json['sukses'] as bool,
      pesan: json['pesan'] as String?,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((e) => Pembayaran.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      metadata: json['metadata'] != null
          ? PaginationMetaPembayaran.fromJson(
              json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// API Response untuk single pembayaran
class PembayaranDetailResponse {
  final bool sukses;
  final String? pesan;
  final Pembayaran? data;

  const PembayaranDetailResponse({
    required this.sukses,
    this.pesan,
    this.data,
  });

  factory PembayaranDetailResponse.fromJson(Map<String, dynamic> json) {
    return PembayaranDetailResponse(
      sukses: json['sukses'] as bool,
      pesan: json['pesan'] as String?,
      data: json['data'] != null
          ? Pembayaran.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Model untuk pagination metadata
class PaginationMetaPembayaran {
  final int total;
  final int halaman;
  final int limit;
  final int totalHalaman;

  const PaginationMetaPembayaran({
    required this.total,
    required this.halaman,
    required this.limit,
    required this.totalHalaman,
  });

  factory PaginationMetaPembayaran.fromJson(Map<String, dynamic> json) {
    return PaginationMetaPembayaran(
      total: json['total'] as int,
      halaman: json['halaman'] as int,
      limit: json['limit'] as int,
      totalHalaman: json['totalHalaman'] as int,
    );
  }
}

/// Statistik pembayaran
class StatistikPembayaran {
  final int totalPembayaran;
  final String totalRevenue;
  final StatusBreakdownPembayaran statusBreakdown;
  final MetodeBreakdownPembayaran metodeBreakdown;

  const StatistikPembayaran({
    required this.totalPembayaran,
    required this.totalRevenue,
    required this.statusBreakdown,
    required this.metodeBreakdown,
  });

  factory StatistikPembayaran.fromJson(Map<String, dynamic> json) {
    return StatistikPembayaran(
      totalPembayaran: json['totalPembayaran'] as int,
      totalRevenue: json['totalRevenue'].toString(),
      statusBreakdown: StatusBreakdownPembayaran.fromJson(
          json['statusBreakdown'] as Map<String, dynamic>),
      metodeBreakdown: MetodeBreakdownPembayaran.fromJson(
          json['metodeBreakdown'] as Map<String, dynamic>),
    );
  }
}

/// Breakdown status pembayaran
class StatusBreakdownPembayaran {
  final int tertunda;
  final int diproses;
  final int berhasil;
  final int gagal;
  final int dikembalikan;

  const StatusBreakdownPembayaran({
    required this.tertunda,
    required this.diproses,
    required this.berhasil,
    required this.gagal,
    required this.dikembalikan,
  });

  factory StatusBreakdownPembayaran.fromJson(Map<String, dynamic> json) {
    return StatusBreakdownPembayaran(
      tertunda: json['tertunda'] as int? ?? 0,
      diproses: json['diproses'] as int? ?? 0,
      berhasil: json['berhasil'] as int? ?? 0,
      gagal: json['gagal'] as int? ?? 0,
      dikembalikan: json['dikembalikan'] as int? ?? 0,
    );
  }
}

/// Breakdown metode pembayaran
class MetodeBreakdownPembayaran {
  final int transferBank;
  final int kartuKredit;
  final int eWallet;
  final int virtualAccount;
  final int cod;

  const MetodeBreakdownPembayaran({
    required this.transferBank,
    required this.kartuKredit,
    required this.eWallet,
    required this.virtualAccount,
    required this.cod,
  });

  factory MetodeBreakdownPembayaran.fromJson(Map<String, dynamic> json) {
    return MetodeBreakdownPembayaran(
      transferBank: json['transfer_bank'] as int? ?? 0,
      kartuKredit: json['kartu_kredit'] as int? ?? 0,
      eWallet: json['e_wallet'] as int? ?? 0,
      virtualAccount: json['virtual_account'] as int? ?? 0,
      cod: json['cod'] as int? ?? 0,
    );
  }
}

/// Response statistik pembayaran
class StatistikPembayaranResponse {
  final bool sukses;
  final String? pesan;
  final StatistikPembayaran? data;

  const StatistikPembayaranResponse({
    required this.sukses,
    this.pesan,
    this.data,
  });

  factory StatistikPembayaranResponse.fromJson(Map<String, dynamic> json) {
    return StatistikPembayaranResponse(
      sukses: json['sukses'] as bool,
      pesan: json['pesan'] as String?,
      data: json['data'] != null
          ? StatistikPembayaran.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
