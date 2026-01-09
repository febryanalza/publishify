/// Model untuk request buat pesanan cetak
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
      hargaTotal: json['hargaTotal']?.toString() ?? '0',
      status: json['status'] as String,
      tanggalPesan: DateTime.parse(json['tanggalPesan'] as String),
      tanggalSelesai: json['tanggalSelesai'] != null
          ? DateTime.parse(json['tanggalSelesai'] as String)
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
      id: json['id'] as String,
      judul: json['judul'] as String,
      isbn: json['isbn'] as String?,
      jumlahHalaman: json['jumlahHalaman'] as int?,
      urlSampul: json['urlSampul'] as String?,
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
      id: json['id'] as String,
      email: json['email'] as String,
      telepon: json['telepon'] as String?,
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
      namaDepan: json['namaDepan'] as String?,
      namaBelakang: json['namaBelakang'] as String?,
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
      id: json['id'] as String,
      namaEkspedisi: json['namaEkspedisi'] as String?,
      nomorResi: json['nomorResi'] as String?,
      status: json['status'] as String?,
      alamatTujuan: json['alamatTujuan'] as String?,
      kotaTujuan: json['kotaTujuan'] as String?,
      provinsiTujuan: json['provinsiTujuan'] as String?,
      kodePosTujuan: json['kodePosTujuan'] as String?,
      estimasiTiba: json['estimasiTiba'] as String?,
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

/// Constants untuk opsi cetak
class CetakOptions {
  static const List<String> formatKertas = ['A4', 'A5', 'B5', 'Letter', 'Custom'];
  
  static const List<String> jenisKertas = [
    'HVS 70gr',
    'HVS 80gr',
    'Art Paper 120gr',
    'Art Paper 150gr',
    'Bookpaper',
  ];
  
  static const List<String> jenisCover = [
    'Soft Cover',
    'Hard Cover',
    'Board Cover',
  ];
  
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
