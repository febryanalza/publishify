/// Models untuk Pesanan Terbit (Publishing Order)
/// Digunakan oleh Penulis dan Editor

// ============================================
// ENUMS
// ============================================

/// Status proses penerbitan
enum StatusPenerbitan {
  draft,
  menungguPembayaran,
  pembayaranDikonfirmasi,
  naskahDikirim,
  dalamPemeriksaan,
  perluRevisi,
  prosesEditing,
  prosesLayout,
  prosesIsbn,
  siapTerbit,
  diterbitkan,
  dalamDistribusi;

  /// Konversi enum ke string API
  String toApiString() => statusPenerbitanToString(this);
}

/// Helper untuk konversi string ke enum StatusPenerbitan
StatusPenerbitan statusPenerbitanFromString(String? value) {
  switch (value) {
    case 'draft':
      return StatusPenerbitan.draft;
    case 'menunggu_pembayaran':
      return StatusPenerbitan.menungguPembayaran;
    case 'pembayaran_dikonfirmasi':
      return StatusPenerbitan.pembayaranDikonfirmasi;
    case 'naskah_dikirim':
      return StatusPenerbitan.naskahDikirim;
    case 'dalam_pemeriksaan':
      return StatusPenerbitan.dalamPemeriksaan;
    case 'perlu_revisi':
      return StatusPenerbitan.perluRevisi;
    case 'proses_editing':
      return StatusPenerbitan.prosesEditing;
    case 'proses_layout':
      return StatusPenerbitan.prosesLayout;
    case 'proses_isbn':
      return StatusPenerbitan.prosesIsbn;
    case 'siap_terbit':
      return StatusPenerbitan.siapTerbit;
    case 'diterbitkan':
      return StatusPenerbitan.diterbitkan;
    case 'dalam_distribusi':
      return StatusPenerbitan.dalamDistribusi;
    default:
      return StatusPenerbitan.draft;
  }
}

/// Helper untuk konversi enum ke string
String statusPenerbitanToString(StatusPenerbitan status) {
  switch (status) {
    case StatusPenerbitan.draft:
      return 'draft';
    case StatusPenerbitan.menungguPembayaran:
      return 'menunggu_pembayaran';
    case StatusPenerbitan.pembayaranDikonfirmasi:
      return 'pembayaran_dikonfirmasi';
    case StatusPenerbitan.naskahDikirim:
      return 'naskah_dikirim';
    case StatusPenerbitan.dalamPemeriksaan:
      return 'dalam_pemeriksaan';
    case StatusPenerbitan.perluRevisi:
      return 'perlu_revisi';
    case StatusPenerbitan.prosesEditing:
      return 'proses_editing';
    case StatusPenerbitan.prosesLayout:
      return 'proses_layout';
    case StatusPenerbitan.prosesIsbn:
      return 'proses_isbn';
    case StatusPenerbitan.siapTerbit:
      return 'siap_terbit';
    case StatusPenerbitan.diterbitkan:
      return 'diterbitkan';
    case StatusPenerbitan.dalamDistribusi:
      return 'dalam_distribusi';
  }
}

/// Label tampilan untuk status
String getLabelStatusPenerbitan(StatusPenerbitan status) {
  switch (status) {
    case StatusPenerbitan.draft:
      return 'Draft';
    case StatusPenerbitan.menungguPembayaran:
      return 'Menunggu Pembayaran';
    case StatusPenerbitan.pembayaranDikonfirmasi:
      return 'Pembayaran Dikonfirmasi';
    case StatusPenerbitan.naskahDikirim:
      return 'Naskah Dikirim';
    case StatusPenerbitan.dalamPemeriksaan:
      return 'Dalam Pemeriksaan';
    case StatusPenerbitan.perluRevisi:
      return 'Perlu Revisi';
    case StatusPenerbitan.prosesEditing:
      return 'Proses Editing';
    case StatusPenerbitan.prosesLayout:
      return 'Proses Layout';
    case StatusPenerbitan.prosesIsbn:
      return 'Proses ISBN';
    case StatusPenerbitan.siapTerbit:
      return 'Siap Terbit';
    case StatusPenerbitan.diterbitkan:
      return 'Diterbitkan';
    case StatusPenerbitan.dalamDistribusi:
      return 'Dalam Distribusi';
  }
}

/// Status pembayaran
enum StatusPembayaranTerbit {
  belumBayar,
  menungguKonfirmasi,
  lunas,
  dibatalkan;

  /// Konversi enum ke string API
  String toApiString() => statusPembayaranFromEnum(this);
}

String statusPembayaranFromEnum(StatusPembayaranTerbit status) {
  switch (status) {
    case StatusPembayaranTerbit.belumBayar:
      return 'belum_bayar';
    case StatusPembayaranTerbit.menungguKonfirmasi:
      return 'menunggu_konfirmasi';
    case StatusPembayaranTerbit.lunas:
      return 'lunas';
    case StatusPembayaranTerbit.dibatalkan:
      return 'dibatalkan';
  }
}

StatusPembayaranTerbit statusPembayaranFromString(String? value) {
  switch (value) {
    case 'belum_bayar':
      return StatusPembayaranTerbit.belumBayar;
    case 'menunggu_konfirmasi':
      return StatusPembayaranTerbit.menungguKonfirmasi;
    case 'lunas':
      return StatusPembayaranTerbit.lunas;
    case 'dibatalkan':
      return StatusPembayaranTerbit.dibatalkan;
    default:
      return StatusPembayaranTerbit.belumBayar;
  }
}

String getLabelStatusPembayaran(StatusPembayaranTerbit status) {
  switch (status) {
    case StatusPembayaranTerbit.belumBayar:
      return 'Belum Bayar';
    case StatusPembayaranTerbit.menungguKonfirmasi:
      return 'Menunggu Konfirmasi';
    case StatusPembayaranTerbit.lunas:
      return 'Lunas';
    case StatusPembayaranTerbit.dibatalkan:
      return 'Dibatalkan';
  }
}

// ============================================
// PAKET PENERBITAN RESPONSE
// ============================================

/// Response untuk daftar paket penerbitan
class DaftarPaketResponse {
  final bool sukses;
  final String pesan;
  final List<PaketPenerbitan> data;

  DaftarPaketResponse({
    required this.sukses,
    this.pesan = '',
    required this.data,
  });

  factory DaftarPaketResponse.fromJson(Map<String, dynamic> json) {
    return DaftarPaketResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => PaketPenerbitan.fromJson(e))
              .toList()
          : [],
    );
  }
}

// ============================================
// REQUEST MODELS
// ============================================

/// Request untuk membuat pesanan terbit baru
class BuatPesananTerbitRequest {
  final String idNaskah;
  final String idPaket;
  final int jumlahBuku;
  final String? catatanPenulis;

  BuatPesananTerbitRequest({
    required this.idNaskah,
    required this.idPaket,
    required this.jumlahBuku,
    this.catatanPenulis,
  });

  Map<String, dynamic> toJson() {
    return {
      'idNaskah': idNaskah,
      'idPaket': idPaket,
      'jumlahBuku': jumlahBuku,
      if (catatanPenulis != null && catatanPenulis!.isNotEmpty)
        'catatanPenulis': catatanPenulis,
    };
  }
}

/// Request untuk update spesifikasi buku
class UpdateSpesifikasiRequest {
  final String? jenisSampul;
  final String? lapisSampul;
  final String? jenisKertas;
  final String? ukuranBuku;
  final int? ukuranCustomPanjang;
  final int? ukuranCustomLebar;
  final String? jenisJilid;
  final String? laminasi;
  final bool? pembatasBuku;
  final bool? packingKhusus;
  final String? catatanTambahan;

  UpdateSpesifikasiRequest({
    this.jenisSampul,
    this.lapisSampul,
    this.jenisKertas,
    this.ukuranBuku,
    this.ukuranCustomPanjang,
    this.ukuranCustomLebar,
    this.jenisJilid,
    this.laminasi,
    this.pembatasBuku,
    this.packingKhusus,
    this.catatanTambahan,
  });

  Map<String, dynamic> toJson() {
    return {
      if (jenisSampul != null) 'jenisSampul': jenisSampul,
      if (lapisSampul != null) 'lapisSampul': lapisSampul,
      if (jenisKertas != null) 'jenisKertas': jenisKertas,
      if (ukuranBuku != null) 'ukuranBuku': ukuranBuku,
      if (ukuranCustomPanjang != null) 'ukuranCustomPanjang': ukuranCustomPanjang,
      if (ukuranCustomLebar != null) 'ukuranCustomLebar': ukuranCustomLebar,
      if (jenisJilid != null) 'jenisJilid': jenisJilid,
      if (laminasi != null) 'laminasi': laminasi,
      if (pembatasBuku != null) 'pembatasBuku': pembatasBuku,
      if (packingKhusus != null) 'packingKhusus': packingKhusus,
      if (catatanTambahan != null) 'catatanTambahan': catatanTambahan,
    };
  }
}

/// Request untuk update kelengkapan naskah
class UpdateKelengkapanRequest {
  final bool? adaKataPengantar;
  final bool? adaDaftarIsi;
  final bool? adaBabIsi;
  final bool? adaDaftarPustaka;
  final bool? adaTentangPenulis;
  final bool? adaSinopsis;
  final bool? adaLampiran;
  final String? urlKataPengantar;
  final String? urlDaftarIsi;
  final String? urlDaftarPustaka;
  final String? urlTentangPenulis;
  final String? urlSinopsis;
  final String? urlLampiran;
  final String? catatanKelengkapan;

  UpdateKelengkapanRequest({
    this.adaKataPengantar,
    this.adaDaftarIsi,
    this.adaBabIsi,
    this.adaDaftarPustaka,
    this.adaTentangPenulis,
    this.adaSinopsis,
    this.adaLampiran,
    this.urlKataPengantar,
    this.urlDaftarIsi,
    this.urlDaftarPustaka,
    this.urlTentangPenulis,
    this.urlSinopsis,
    this.urlLampiran,
    this.catatanKelengkapan,
  });

  Map<String, dynamic> toJson() {
    return {
      if (adaKataPengantar != null) 'adaKataPengantar': adaKataPengantar,
      if (adaDaftarIsi != null) 'adaDaftarIsi': adaDaftarIsi,
      if (adaBabIsi != null) 'adaBabIsi': adaBabIsi,
      if (adaDaftarPustaka != null) 'adaDaftarPustaka': adaDaftarPustaka,
      if (adaTentangPenulis != null) 'adaTentangPenulis': adaTentangPenulis,
      if (adaSinopsis != null) 'adaSinopsis': adaSinopsis,
      if (adaLampiran != null) 'adaLampiran': adaLampiran,
      if (urlKataPengantar != null) 'urlKataPengantar': urlKataPengantar,
      if (urlDaftarIsi != null) 'urlDaftarIsi': urlDaftarIsi,
      if (urlDaftarPustaka != null) 'urlDaftarPustaka': urlDaftarPustaka,
      if (urlTentangPenulis != null) 'urlTentangPenulis': urlTentangPenulis,
      if (urlSinopsis != null) 'urlSinopsis': urlSinopsis,
      if (urlLampiran != null) 'urlLampiran': urlLampiran,
      if (catatanKelengkapan != null) 'catatanKelengkapan': catatanKelengkapan,
    };
  }
}

/// Request untuk update status (Editor)
class UpdateStatusPesananRequest {
  final String status;
  final String? statusPembayaran;
  final String? catatan;

  UpdateStatusPesananRequest({
    required this.status,
    this.statusPembayaran,
    this.catatan,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (statusPembayaran != null) 'statusPembayaran': statusPembayaran,
      if (catatan != null && catatan!.isNotEmpty) 'catatan': catatan,
    };
  }
}

// ============================================
// RESPONSE MODELS
// ============================================

/// Response generik untuk API
class PesananTerbitResponse<T> {
  final bool sukses;
  final String pesan;
  final T? data;
  final Map<String, dynamic>? metadata;

  PesananTerbitResponse({
    required this.sukses,
    required this.pesan,
    this.data,
    this.metadata,
  });
}

/// Response untuk list pesanan terbit
class DaftarPesananTerbitResponse {
  final bool sukses;
  final String pesan;
  final List<PesananTerbitSummary> data;
  final PaginationMetadata? metadata;

  DaftarPesananTerbitResponse({
    required this.sukses,
    required this.pesan,
    required this.data,
    this.metadata,
  });

  factory DaftarPesananTerbitResponse.fromJson(Map<String, dynamic> json) {
    return DaftarPesananTerbitResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => PesananTerbitSummary.fromJson(e))
              .toList() ??
          [],
      metadata: json['metadata'] != null
          ? PaginationMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

/// Metadata untuk pagination
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
      total: json['total'] ?? 0,
      halaman: json['halaman'] ?? 1,
      limit: json['limit'] ?? 10,
      totalHalaman: json['totalHalaman'] ?? 1,
    );
  }
}

// ============================================
// DATA MODELS
// ============================================

/// Model ringkas untuk list pesanan terbit
class PesananTerbitSummary {
  final String id;
  final String nomorPesanan;
  final String status;
  final String statusPembayaran;
  final int jumlahBuku;
  final double totalHarga;
  final String tanggalPesan;
  final NaskahInfoTerbit? naskah;
  final PaketPenerbitan? paket;
  final PenulisInfo? penulis;
  final SpesifikasiBuku? spesifikasi;
  final KelengkapanNaskah? kelengkapan;

  PesananTerbitSummary({
    required this.id,
    required this.nomorPesanan,
    required this.status,
    required this.statusPembayaran,
    required this.jumlahBuku,
    required this.totalHarga,
    required this.tanggalPesan,
    this.naskah,
    this.paket,
    this.penulis,
    this.spesifikasi,
    this.kelengkapan,
  });

  factory PesananTerbitSummary.fromJson(Map<String, dynamic> json) {
    return PesananTerbitSummary(
      id: json['id'] ?? '',
      nomorPesanan: json['nomorPesanan'] ?? '',
      status: json['status'] ?? 'draft',
      statusPembayaran: json['statusPembayaran'] ?? 'belum_bayar',
      jumlahBuku: json['jumlahBuku'] ?? 0,
      totalHarga: _parseDouble(json['totalHarga']),
      tanggalPesan: json['tanggalPesan'] ?? '',
      naskah: json['naskah'] != null
          ? NaskahInfoTerbit.fromJson(json['naskah'])
          : null,
      paket: json['paket'] != null
          ? PaketPenerbitan.fromJson(json['paket'])
          : null,
      penulis: json['penulis'] != null
          ? PenulisInfo.fromJson(json['penulis'])
          : null,
      spesifikasi: json['spesifikasi'] != null
          ? SpesifikasiBuku.fromJson(json['spesifikasi'])
          : null,
      kelengkapan: json['kelengkapan'] != null
          ? KelengkapanNaskah.fromJson(json['kelengkapan'])
          : null,
    );
  }

  StatusPenerbitan get statusEnum => statusPenerbitanFromString(status);
  StatusPembayaranTerbit get statusPembayaranEnum =>
      statusPembayaranFromString(statusPembayaran);
}

/// Model detail lengkap pesanan terbit
class PesananTerbitDetail {
  final String id;
  final String nomorPesanan;
  final String status;
  final String statusPembayaran;
  final int jumlahBuku;
  final double totalHarga;
  final String? isbn;
  final String statusISBN;
  final String statusEditing;
  final String statusLayout;
  final String statusProofreading;
  final int jumlahRevisiDesain;
  final int jumlahRevisiLayout;
  final int revisiMaksimal;
  final String? buktiPembayaran;
  final String tanggalPesan;
  final String? tanggalBayar;
  final String? tanggalMulaiProses;
  final String? tanggalSelesai;
  final String? catatanPenulis;
  final String? catatanEditor;
  final String? catatanAdmin;
  final NaskahInfoTerbit? naskah;
  final PaketPenerbitan? paket;
  final PenulisInfo? penulis;
  final SpesifikasiBuku? spesifikasi;
  final KelengkapanNaskah? kelengkapan;
  final List<LogProsesTerbit> logProsesTerbit;

  PesananTerbitDetail({
    required this.id,
    required this.nomorPesanan,
    required this.status,
    required this.statusPembayaran,
    required this.jumlahBuku,
    required this.totalHarga,
    this.isbn,
    required this.statusISBN,
    required this.statusEditing,
    required this.statusLayout,
    required this.statusProofreading,
    required this.jumlahRevisiDesain,
    required this.jumlahRevisiLayout,
    required this.revisiMaksimal,
    this.buktiPembayaran,
    required this.tanggalPesan,
    this.tanggalBayar,
    this.tanggalMulaiProses,
    this.tanggalSelesai,
    this.catatanPenulis,
    this.catatanEditor,
    this.catatanAdmin,
    this.naskah,
    this.paket,
    this.penulis,
    this.spesifikasi,
    this.kelengkapan,
    required this.logProsesTerbit,
  });

  factory PesananTerbitDetail.fromJson(Map<String, dynamic> json) {
    return PesananTerbitDetail(
      id: json['id'] ?? '',
      nomorPesanan: json['nomorPesanan'] ?? '',
      status: json['status'] ?? 'draft',
      statusPembayaran: json['statusPembayaran'] ?? 'belum_bayar',
      jumlahBuku: json['jumlahBuku'] ?? 0,
      totalHarga: _parseDouble(json['totalHarga']),
      isbn: json['isbn'],
      statusISBN: json['statusISBN'] ?? 'belum_diurus',
      statusEditing: json['statusEditing'] ?? 'belum_mulai',
      statusLayout: json['statusLayout'] ?? 'belum_mulai',
      statusProofreading: json['statusProofreading'] ?? 'tidak_termasuk',
      jumlahRevisiDesain: json['jumlahRevisiDesain'] ?? 0,
      jumlahRevisiLayout: json['jumlahRevisiLayout'] ?? 0,
      revisiMaksimal: json['revisiMaksimal'] ?? 2,
      buktiPembayaran: json['buktiPembayaran'],
      tanggalPesan: json['tanggalPesan'] ?? '',
      tanggalBayar: json['tanggalBayar'],
      tanggalMulaiProses: json['tanggalMulaiProses'],
      tanggalSelesai: json['tanggalSelesai'],
      catatanPenulis: json['catatanPenulis'],
      catatanEditor: json['catatanEditor'],
      catatanAdmin: json['catatanAdmin'],
      naskah: json['naskah'] != null
          ? NaskahInfoTerbit.fromJson(json['naskah'])
          : null,
      paket:
          json['paket'] != null ? PaketPenerbitan.fromJson(json['paket']) : null,
      penulis:
          json['penulis'] != null ? PenulisInfo.fromJson(json['penulis']) : null,
      spesifikasi: json['spesifikasi'] != null
          ? SpesifikasiBuku.fromJson(json['spesifikasi'])
          : null,
      kelengkapan: json['kelengkapan'] != null
          ? KelengkapanNaskah.fromJson(json['kelengkapan'])
          : null,
      logProsesTerbit: (json['logProsesTerbit'] as List<dynamic>?)
              ?.map((e) => LogProsesTerbit.fromJson(e))
              .toList() ??
          [],
    );
  }

  StatusPenerbitan get statusEnum => statusPenerbitanFromString(status);
  StatusPembayaranTerbit get statusPembayaranEnum =>
      statusPembayaranFromString(statusPembayaran);
}

/// Info naskah untuk pesanan terbit
class NaskahInfoTerbit {
  final String id;
  final String judul;
  final String? subJudul;
  final String? sinopsis;
  final String? urlSampul;
  final String? urlFile;
  final int? jumlahHalaman;

  NaskahInfoTerbit({
    required this.id,
    required this.judul,
    this.subJudul,
    this.sinopsis,
    this.urlSampul,
    this.urlFile,
    this.jumlahHalaman,
  });

  factory NaskahInfoTerbit.fromJson(Map<String, dynamic> json) {
    return NaskahInfoTerbit(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      subJudul: json['subJudul'],
      sinopsis: json['sinopsis'],
      urlSampul: json['urlSampul'],
      urlFile: json['urlFile'],
      jumlahHalaman: json['jumlahHalaman'],
    );
  }
}

/// Info paket penerbitan
class PaketPenerbitan {
  final String id;
  final String nama;
  final double harga;
  final String? deskripsi;
  final String? kode;
  final int? jumlahBukuMin;
  final bool? termasukProofreading;
  final bool? termasukLayoutDesain;
  final bool? termasukISBN;
  final bool? termasukEbook;
  final int? revisiMaksimal;
  final List<String>? fiturTambahan;

  PaketPenerbitan({
    required this.id,
    required this.nama,
    required this.harga,
    this.deskripsi,
    this.kode,
    this.jumlahBukuMin,
    this.termasukProofreading,
    this.termasukLayoutDesain,
    this.termasukISBN,
    this.termasukEbook,
    this.revisiMaksimal,
    this.fiturTambahan,
  });

  factory PaketPenerbitan.fromJson(Map<String, dynamic> json) {
    return PaketPenerbitan(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      harga: _parseDouble(json['harga']),
      deskripsi: json['deskripsi'],
      kode: json['kode'],
      jumlahBukuMin: json['jumlahBukuMin'],
      termasukProofreading: json['termasukProofreading'],
      termasukLayoutDesain: json['termasukLayoutDesain'],
      termasukISBN: json['termasukISBN'],
      termasukEbook: json['termasukEbook'],
      revisiMaksimal: json['revisiMaksimal'],
      fiturTambahan: json['fiturTambahan'] != null
          ? List<String>.from(json['fiturTambahan'])
          : null,
    );
  }
}

/// Info penulis
class PenulisInfo {
  final String id;
  final String email;
  final ProfilPenggunaTerbit? profilPengguna;

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
          ? ProfilPenggunaTerbit.fromJson(json['profilPengguna'])
          : null,
    );
  }

  String get namaLengkap {
    if (profilPengguna != null) {
      final namaDepan = profilPengguna!.namaDepan ?? '';
      final namaBelakang = profilPengguna!.namaBelakang ?? '';
      final fullName = '$namaDepan $namaBelakang'.trim();
      return fullName.isNotEmpty ? fullName : email;
    }
    return email;
  }

  /// URL avatar dari profil pengguna
  String? get urlAvatar => profilPengguna?.urlAvatar;
}

class ProfilPenggunaTerbit {
  final String? namaDepan;
  final String? namaBelakang;
  final String? urlAvatar;

  ProfilPenggunaTerbit({
    this.namaDepan,
    this.namaBelakang,
    this.urlAvatar,
  });

  factory ProfilPenggunaTerbit.fromJson(Map<String, dynamic> json) {
    return ProfilPenggunaTerbit(
      namaDepan: json['namaDepan'],
      namaBelakang: json['namaBelakang'],
      urlAvatar: json['urlAvatar'],
    );
  }
}

/// Spesifikasi buku
class SpesifikasiBuku {
  final String id;
  final String jenisSampul;
  final String? lapisSampul;
  final String jenisKertas;
  final String ukuranBuku;
  final int? ukuranCustomPanjang;
  final int? ukuranCustomLebar;
  final String jenisJilid;
  final String? laminasi;
  final bool pembatasBuku;
  final bool packingKhusus;
  final String? catatanTambahan;

  SpesifikasiBuku({
    required this.id,
    required this.jenisSampul,
    this.lapisSampul,
    required this.jenisKertas,
    required this.ukuranBuku,
    this.ukuranCustomPanjang,
    this.ukuranCustomLebar,
    required this.jenisJilid,
    this.laminasi,
    required this.pembatasBuku,
    required this.packingKhusus,
    this.catatanTambahan,
  });

  factory SpesifikasiBuku.fromJson(Map<String, dynamic> json) {
    return SpesifikasiBuku(
      id: json['id'] ?? '',
      jenisSampul: json['jenisSampul'] ?? 'softcover',
      lapisSampul: json['lapisSampul'],
      jenisKertas: json['jenisKertas'] ?? 'bookpaper_55',
      ukuranBuku: json['ukuranBuku'] ?? 'A5',
      ukuranCustomPanjang: json['ukuranCustomPanjang'],
      ukuranCustomLebar: json['ukuranCustomLebar'],
      jenisJilid: json['jenisJilid'] ?? 'lem_panas',
      laminasi: json['laminasi'],
      pembatasBuku: json['pembatasBuku'] ?? false,
      packingKhusus: json['packingKhusus'] ?? false,
      catatanTambahan: json['catatanTambahan'],
    );
  }
}

/// Kelengkapan naskah
class KelengkapanNaskah {
  final String id;
  final bool adaKataPengantar;
  final bool adaDaftarIsi;
  final bool adaBabIsi;
  final bool adaDaftarPustaka;
  final bool adaTentangPenulis;
  final bool adaSinopsis;
  final bool adaLampiran;
  final String? urlKataPengantar;
  final String? urlDaftarIsi;
  final String? urlDaftarPustaka;
  final String? urlTentangPenulis;
  final String? urlSinopsis;
  final String? urlLampiran;
  final String? catatanKelengkapan;
  final String statusVerifikasi;

  KelengkapanNaskah({
    required this.id,
    required this.adaKataPengantar,
    required this.adaDaftarIsi,
    required this.adaBabIsi,
    required this.adaDaftarPustaka,
    required this.adaTentangPenulis,
    required this.adaSinopsis,
    required this.adaLampiran,
    this.urlKataPengantar,
    this.urlDaftarIsi,
    this.urlDaftarPustaka,
    this.urlTentangPenulis,
    this.urlSinopsis,
    this.urlLampiran,
    this.catatanKelengkapan,
    required this.statusVerifikasi,
  });

  factory KelengkapanNaskah.fromJson(Map<String, dynamic> json) {
    return KelengkapanNaskah(
      id: json['id'] ?? '',
      adaKataPengantar: json['adaKataPengantar'] ?? false,
      adaDaftarIsi: json['adaDaftarIsi'] ?? false,
      adaBabIsi: json['adaBabIsi'] ?? false,
      adaDaftarPustaka: json['adaDaftarPustaka'] ?? false,
      adaTentangPenulis: json['adaTentangPenulis'] ?? false,
      adaSinopsis: json['adaSinopsis'] ?? false,
      adaLampiran: json['adaLampiran'] ?? false,
      urlKataPengantar: json['urlKataPengantar'],
      urlDaftarIsi: json['urlDaftarIsi'],
      urlDaftarPustaka: json['urlDaftarPustaka'],
      urlTentangPenulis: json['urlTentangPenulis'],
      urlSinopsis: json['urlSinopsis'],
      urlLampiran: json['urlLampiran'],
      catatanKelengkapan: json['catatanKelengkapan'],
      statusVerifikasi: json['statusVerifikasi'] ?? 'belum_diperiksa',
    );
  }
}

/// Log proses terbit
class LogProsesTerbit {
  final String id;
  final String? statusSebelumnya;
  final String statusBaru;
  final String? catatan;
  final String? dibuatOleh;
  final String dibuatPada;

  LogProsesTerbit({
    required this.id,
    this.statusSebelumnya,
    required this.statusBaru,
    this.catatan,
    this.dibuatOleh,
    required this.dibuatPada,
  });

  factory LogProsesTerbit.fromJson(Map<String, dynamic> json) {
    return LogProsesTerbit(
      id: json['id'] ?? '',
      statusSebelumnya: json['statusSebelumnya'],
      statusBaru: json['statusBaru'] ?? '',
      catatan: json['catatan'],
      dibuatOleh: json['dibuatOleh'],
      dibuatPada: json['dibuatPada'] ?? '',
    );
  }
}

// ============================================
// HELPER FUNCTIONS
// ============================================

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
