/// Model untuk request buat pesanan cetak (OLD - deprecated)
class BuatPesananRequest {
  final String idNaskah;
  final int jumlah;
  final String formatKertas;
  final String jenisKertas;
  final String jenisCover;
  final List<String> finishingTambahan;
  final String? catatan;

  BuatPesananRequest({
    required this.idNaskah,
    required this.jumlah,
    required this.formatKertas,
    required this.jenisKertas,
    required this.jenisCover,
    this.finishingTambahan = const [],
    this.catatan,
  });

  Map<String, dynamic> toJson() {
    return {
      'idNaskah': idNaskah,
      'jumlah': jumlah,
      'formatKertas': formatKertas,
      'jenisKertas': jenisKertas,
      'jenisCover': jenisCover,
      'finishingTambahan': finishingTambahan,
      if (catatan != null) 'catatan': catatan,
    };
  }
}

/// Model untuk request buat pesanan cetak baru (endpoint simplified)
/// POST /api/percetakan/pesanan/baru
class BuatPesananBaruRequest {
  final String idNaskah;
  final String idPercetakan;
  final int jumlah;
  final String formatKertas;
  final String jenisKertas;
  final String jenisCover;
  final List<String>? finishingTambahan;
  final String? catatan;
  final String alamatPengiriman;
  final String namaPenerima;
  final String teleponPenerima;

  BuatPesananBaruRequest({
    required this.idNaskah,
    required this.idPercetakan,
    required this.jumlah,
    required this.formatKertas,
    required this.jenisKertas,
    required this.jenisCover,
    this.finishingTambahan,
    this.catatan,
    required this.alamatPengiriman,
    required this.namaPenerima,
    required this.teleponPenerima,
  });

  Map<String, dynamic> toJson() {
    return {
      'idNaskah': idNaskah,
      'idPercetakan': idPercetakan,
      'jumlah': jumlah,
      'formatKertas': formatKertas,
      'jenisKertas': jenisKertas,
      'jenisCover': jenisCover,
      if (finishingTambahan != null && finishingTambahan!.isNotEmpty) 'finishingTambahan': finishingTambahan,
      if (catatan != null && catatan!.isNotEmpty) 'catatan': catatan,
      'alamatPengiriman': alamatPengiriman,
      'namaPenerima': namaPenerima,
      'teleponPenerima': teleponPenerima,
    };
  }
}

/// Model untuk response pesanan cetak
class PesananCetak {
  final String id;
  final String idNaskah;
  final String idPemesan;
  final String? idPercetakan;
  final String nomorPesanan;
  final int jumlah;
  final String formatKertas;
  final String jenisKertas;
  final String jenisCover;
  final List<String> finishingTambahan;
  final String? catatan;
  final String hargaTotal;
  final String status;
  final DateTime tanggalPesan;
  final DateTime? tanggalSelesai;
  final NaskahInfo? naskah;
  final PemesanInfo? pemesan;
  final PengirimanInfo? pengiriman;

  PesananCetak({
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
    this.tanggalSelesai,
    this.naskah,
    this.pemesan,
    this.pengiriman,
  });

  factory PesananCetak.fromJson(Map<String, dynamic> json) {
    return PesananCetak(
      id: (json['id'] ?? '').toString(),
      idNaskah: (json['idNaskah'] ?? '').toString(),
      idPemesan: (json['idPemesan'] ?? '').toString(),
      idPercetakan: json['idPercetakan']?.toString(),
      nomorPesanan: (json['nomorPesanan'] ?? '').toString(),
      jumlah: (json['jumlah'] is int) 
          ? json['jumlah'] 
          : int.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
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
      tanggalSelesai: json['tanggalSelesai'] != null
          ? DateTime.tryParse(json['tanggalSelesai'].toString())
          : null,
      naskah: json['naskah'] != null
          ? NaskahInfo.fromJson(json['naskah'] as Map<String, dynamic>)
          : null,
      pemesan: json['pemesan'] != null
          ? PemesanInfo.fromJson(json['pemesan'] as Map<String, dynamic>)
          : null,
      pengiriman: json['pengiriman'] != null
          ? PengirimanInfo.fromJson(json['pengiriman'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Get formatted status label
  String get statusLabel {
    const statusLabels = {
      'tertunda': 'Tertunda',
      'diterima': 'Diterima',
      'dalam_produksi': 'Dalam Produksi',
      'kontrol_kualitas': 'Kontrol Kualitas',
      'siap': 'Siap Kirim',
      'dikirim': 'Dikirim',
      'terkirim': 'Selesai',
      'dibatalkan': 'Dibatalkan',
    };
    return statusLabels[status] ?? status;
  }

  /// Format harga as Indonesian Rupiah
  String get hargaFormatted {
    final harga = double.tryParse(hargaTotal) ?? 0;
    return 'Rp ${_formatNumber(harga.toInt())}';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

/// Model untuk info naskah dalam pesanan
class NaskahInfo {
  final String id;
  final String judul;
  final String? isbn;
  final int? jumlahHalaman;
  final String? urlSampul;

  NaskahInfo({
    required this.id,
    required this.judul,
    this.isbn,
    this.jumlahHalaman,
    this.urlSampul,
  });

  factory NaskahInfo.fromJson(Map<String, dynamic> json) {
    return NaskahInfo(
      id: (json['id'] ?? '').toString(),
      judul: (json['judul'] ?? 'Tanpa Judul').toString(),
      isbn: json['isbn']?.toString(),
      jumlahHalaman: json['jumlahHalaman'] is int
          ? json['jumlahHalaman']
          : int.tryParse(json['jumlahHalaman']?.toString() ?? ''),
      urlSampul: json['urlSampul']?.toString(),
    );
  }
}

/// Model untuk info pemesan dalam pesanan
class PemesanInfo {
  final String id;
  final String email;
  final String? telepon;
  final ProfilInfo? profilPengguna;

  PemesanInfo({
    required this.id,
    required this.email,
    this.telepon,
    this.profilPengguna,
  });

  factory PemesanInfo.fromJson(Map<String, dynamic> json) {
    return PemesanInfo(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      telepon: json['telepon']?.toString(),
      profilPengguna: json['profilPengguna'] != null
          ? ProfilInfo.fromJson(json['profilPengguna'] as Map<String, dynamic>)
          : null,
    );
  }

  String get namaLengkap {
    if (profilPengguna != null) {
      return '${profilPengguna!.namaDepan ?? ''} ${profilPengguna!.namaBelakang ?? ''}'.trim();
    }
    return email;
  }
}

/// Model untuk info profil
class ProfilInfo {
  final String? namaDepan;
  final String? namaBelakang;

  ProfilInfo({
    this.namaDepan,
    this.namaBelakang,
  });

  factory ProfilInfo.fromJson(Map<String, dynamic> json) {
    return ProfilInfo(
      namaDepan: json['namaDepan']?.toString(),
      namaBelakang: json['namaBelakang']?.toString(),
    );
  }
}

/// Model untuk info pengiriman
class PengirimanInfo {
  final String id;
  final String? namaEkspedisi;
  final String? nomorResi;
  final String? status;
  final String? alamatTujuan;
  final String? kotaTujuan;
  final String? provinsiTujuan;
  final String? kodePosTujuan;
  final String? estimasiTiba;

  PengirimanInfo({
    required this.id,
    this.namaEkspedisi,
    this.nomorResi,
    this.status,
    this.alamatTujuan,
    this.kotaTujuan,
    this.provinsiTujuan,
    this.kodePosTujuan,
    this.estimasiTiba,
  });

  factory PengirimanInfo.fromJson(Map<String, dynamic> json) {
    return PengirimanInfo(
      id: (json['id'] ?? '').toString(),
      namaEkspedisi: json['namaEkspedisi']?.toString(),
      nomorResi: json['nomorResi']?.toString(),
      status: json['status']?.toString(),
      alamatTujuan: json['alamatTujuan']?.toString(),
      kotaTujuan: json['kotaTujuan']?.toString(),
      provinsiTujuan: json['provinsiTujuan']?.toString(),
      kodePosTujuan: json['kodePosTujuan']?.toString(),
      estimasiTiba: json['estimasiTiba']?.toString(),
    );
  }
}

/// Model untuk response API
class CetakApiResponse<T> {
  final bool sukses;
  final String? pesan;
  final T? data;
  final PaginationMetadata? metadata;

  CetakApiResponse({
    required this.sukses,
    this.pesan,
    this.data,
    this.metadata,
  });
}

/// Model untuk response list pesanan
class PesananListResponse {
  final bool sukses;
  final String? pesan;
  final List<PesananCetak> data;
  final PaginationMetadata? metadata;

  PesananListResponse({
    required this.sukses,
    this.pesan,
    this.data = const [],
    this.metadata,
  });

  factory PesananListResponse.fromJson(Map<String, dynamic> json) {
    return PesananListResponse(
      sukses: json['sukses'] as bool? ?? false,
      pesan: json['pesan'] as String?,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => PesananCetak.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: json['metadata'] != null
          ? PaginationMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Model untuk response single pesanan
class PesananDetailResponse {
  final bool sukses;
  final String? pesan;
  final PesananCetak? data;

  PesananDetailResponse({
    required this.sukses,
    this.pesan,
    this.data,
  });

  factory PesananDetailResponse.fromJson(Map<String, dynamic> json) {
    return PesananDetailResponse(
      sukses: json['sukses'] as bool? ?? false,
      pesan: json['pesan'] as String?,
      data: json['data'] != null
          ? PesananCetak.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Model untuk pagination metadata
class PaginationMetadata {
  final int total;
  final int halaman;
  final int limit;
  final int totalHalaman;

  PaginationMetadata({
    required this.total,
    required this.halaman,
    required this.limit,
    required this.totalHalaman,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      total: (json['total'] as int?) ?? 0,
      halaman: (json['halaman'] as int?) ?? 1,
      limit: (json['limit'] as int?) ?? 20,
      totalHalaman: (json['totalHalaman'] as int?) ?? 0,
    );
  }
}

/// Model untuk info tarif percetakan
class TarifInfo {
  final String id;
  final String namaKombinasi;
  final int hargaKertasA4;
  final int hargaKertasA5;
  final int hargaSoftcover;
  final int hargaHardcover;
  final int biayaJilid;
  final int minimumPesanan;

  TarifInfo({
    required this.id,
    required this.namaKombinasi,
    required this.hargaKertasA4,
    required this.hargaKertasA5,
    required this.hargaSoftcover,
    required this.hargaHardcover,
    required this.biayaJilid,
    required this.minimumPesanan,
  });

  factory TarifInfo.fromJson(Map<String, dynamic> json) {
    return TarifInfo(
      id: json['id']?.toString() ?? '',
      namaKombinasi: json['namaKombinasi']?.toString() ?? '',
      hargaKertasA4: int.tryParse(json['hargaKertasA4']?.toString() ?? '0') ?? 0,
      hargaKertasA5: int.tryParse(json['hargaKertasA5']?.toString() ?? '0') ?? 0,
      hargaSoftcover: int.tryParse(json['hargaSoftcover']?.toString() ?? '0') ?? 0,
      hargaHardcover: int.tryParse(json['hargaHardcover']?.toString() ?? '0') ?? 0,
      biayaJilid: int.tryParse(json['biayaJilid']?.toString() ?? '0') ?? 0,
      minimumPesanan: int.tryParse(json['minimumPesanan']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Model untuk info percetakan
class PercetakanInfo {
  final String id;
  final String? email;
  final String nama;
  final String? alamat;
  final String? kota;
  final String? provinsi;
  final TarifInfo? tarifAktif;

  PercetakanInfo({
    required this.id,
    this.email,
    required this.nama,
    this.alamat,
    this.kota,
    this.provinsi,
    this.tarifAktif,
  });

  factory PercetakanInfo.fromJson(Map<String, dynamic> json) {
    return PercetakanInfo(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString(),
      nama: json['nama']?.toString() ?? '',
      alamat: json['alamat']?.toString(),
      kota: json['kota']?.toString(),
      provinsi: json['provinsi']?.toString(),
      tarifAktif: json['tarifAktif'] != null
          ? TarifInfo.fromJson(json['tarifAktif'])
          : null,
    );
  }
}

/// Response untuk daftar percetakan
class PercetakanListResponse {
  final bool sukses;
  final String pesan;
  final List<PercetakanInfo> data;
  final int total;

  PercetakanListResponse({
    required this.sukses,
    required this.pesan,
    this.data = const [],
    this.total = 0,
  });

  factory PercetakanListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>?;
    return PercetakanListResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan']?.toString() ?? '',
      data: dataList?.map((e) => PercetakanInfo.fromJson(e)).toList() ?? [],
      total: json['total'] ?? dataList?.length ?? 0,
    );
  }
}

/// Constants untuk opsi cetak
class CetakOptions {
  static const List<String> formatKertas = ['A4', 'A5', 'B5'];
  
  // ⚠️ HARUS MATCH dengan backend enum!
  static const List<String> jenisKertas = [
    'HVS',
    'BOOKPAPER',
    'ART_PAPER',
  ];
  
  // Label untuk display di UI
  static const Map<String, String> jenisKertasLabel = {
    'HVS': 'HVS',
    'BOOKPAPER': 'Bookpaper',
    'ART_PAPER': 'Art Paper',
  };
  
  // ⚠️ HARUS MATCH dengan backend enum!
  static const List<String> jenisCover = [
    'SOFTCOVER',
    'HARDCOVER',
  ];
  
  // Label untuk display di UI
  static const Map<String, String> jenisCoverLabel = {
    'SOFTCOVER': 'Soft Cover',
    'HARDCOVER': 'Hard Cover',
  };
  
  static const List<String> finishingTambahan = [
    'Laminasi Glossy',
    'Laminasi Doff',
    'Emboss',
    'Deboss',
    'Spot UV',
    'Foil',
    'Tidak Ada',
  ];
}
