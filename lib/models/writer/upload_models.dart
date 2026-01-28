/// Model untuk Upload/File Management
/// Digunakan untuk endpoint:
/// - POST /upload/multiple - Multi-file upload
/// - GET /upload - Daftar file user
/// - GET /upload/:id - Detail file (URL)
/// - DELETE /upload/:id - Hapus file
/// - GET /upload/download/:id - Download file
/// - POST /upload/process-image - Image processing

// ==========================================
// ENUMS
// ==========================================

/// Tipe tujuan upload
enum TujuanUpload {
  naskah,
  sampul,
  gambar,
  dokumen,
}

extension TujuanUploadExtension on TujuanUpload {
  String get value {
    switch (this) {
      case TujuanUpload.naskah:
        return 'naskah';
      case TujuanUpload.sampul:
        return 'sampul';
      case TujuanUpload.gambar:
        return 'gambar';
      case TujuanUpload.dokumen:
        return 'dokumen';
    }
  }

  String get label {
    switch (this) {
      case TujuanUpload.naskah:
        return 'Naskah';
      case TujuanUpload.sampul:
        return 'Sampul Buku';
      case TujuanUpload.gambar:
        return 'Gambar';
      case TujuanUpload.dokumen:
        return 'Dokumen';
    }
  }

  static TujuanUpload fromString(String value) {
    switch (value.toLowerCase()) {
      case 'naskah':
        return TujuanUpload.naskah;
      case 'sampul':
        return TujuanUpload.sampul;
      case 'gambar':
        return TujuanUpload.gambar;
      case 'dokumen':
        return TujuanUpload.dokumen;
      default:
        return TujuanUpload.dokumen;
    }
  }
}

/// Format output gambar
enum FormatGambar {
  jpeg,
  png,
  webp,
}

extension FormatGambarExtension on FormatGambar {
  String get value {
    switch (this) {
      case FormatGambar.jpeg:
        return 'jpeg';
      case FormatGambar.png:
        return 'png';
      case FormatGambar.webp:
        return 'webp';
    }
  }
}

/// Fit mode untuk resize gambar
enum FitMode {
  cover,
  contain,
  fill,
  inside,
  outside,
}

extension FitModeExtension on FitMode {
  String get value {
    switch (this) {
      case FitMode.cover:
        return 'cover';
      case FitMode.contain:
        return 'contain';
      case FitMode.fill:
        return 'fill';
      case FitMode.inside:
        return 'inside';
      case FitMode.outside:
        return 'outside';
    }
  }
}

/// Preset untuk image processing
enum ImagePreset {
  thumbnail,
  sampulKecil,
  sampulBesar,
  banner,
}

extension ImagePresetExtension on ImagePreset {
  String get value {
    switch (this) {
      case ImagePreset.thumbnail:
        return 'thumbnail';
      case ImagePreset.sampulKecil:
        return 'sampulKecil';
      case ImagePreset.sampulBesar:
        return 'sampulBesar';
      case ImagePreset.banner:
        return 'banner';
    }
  }

  String get label {
    switch (this) {
      case ImagePreset.thumbnail:
        return 'Thumbnail (150x150)';
      case ImagePreset.sampulKecil:
        return 'Sampul Kecil (200x300)';
      case ImagePreset.sampulBesar:
        return 'Sampul Besar (400x600)';
      case ImagePreset.banner:
        return 'Banner (1200x400)';
    }
  }
}

// ==========================================
// FILE INFO MODEL
// ==========================================

/// Model untuk informasi file
class FileInfo {
  final String id;
  final String namaFileAsli;
  final String namaFileSimpan;
  final String url;
  final String? urlPublik;
  final int ukuran;
  final String mimeType;
  final String ekstensi;
  final String tujuan;
  final String path;
  final String? deskripsi;
  final String? idReferensi;
  final DateTime diuploadPada;
  final PenggunaInfo? pengguna;

  FileInfo({
    required this.id,
    required this.namaFileAsli,
    required this.namaFileSimpan,
    required this.url,
    this.urlPublik,
    required this.ukuran,
    required this.mimeType,
    required this.ekstensi,
    required this.tujuan,
    required this.path,
    this.deskripsi,
    this.idReferensi,
    required this.diuploadPada,
    this.pengguna,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      id: json['id'] ?? '',
      namaFileAsli: json['namaFileAsli'] ?? '',
      namaFileSimpan: json['namaFileSimpan'] ?? '',
      url: json['url'] ?? '',
      urlPublik: json['urlPublik'],
      ukuran: json['ukuran'] ?? 0,
      mimeType: json['mimeType'] ?? '',
      ekstensi: json['ekstensi'] ?? '',
      tujuan: json['tujuan'] ?? '',
      path: json['path'] ?? '',
      deskripsi: json['deskripsi'],
      idReferensi: json['idReferensi'],
      diuploadPada: json['diuploadPada'] != null
          ? DateTime.parse(json['diuploadPada'])
          : DateTime.now(),
      pengguna: json['pengguna'] != null
          ? PenggunaInfo.fromJson(json['pengguna'])
          : null,
    );
  }

  /// Format ukuran file ke string yang readable
  String get ukuranFormatted {
    if (ukuran < 1024) {
      return '$ukuran B';
    } else if (ukuran < 1024 * 1024) {
      return '${(ukuran / 1024).toStringAsFixed(1)} KB';
    } else if (ukuran < 1024 * 1024 * 1024) {
      return '${(ukuran / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(ukuran / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Tujuan upload sebagai enum
  TujuanUpload get tujuanEnum => TujuanUploadExtension.fromString(tujuan);

  /// Cek apakah file adalah gambar
  bool get isImage => mimeType.startsWith('image/');

  /// Cek apakah file adalah PDF
  bool get isPdf => mimeType == 'application/pdf';

  /// Cek apakah file adalah dokumen Word
  bool get isWord =>
      mimeType == 'application/msword' ||
      mimeType ==
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
}

/// Model untuk informasi pengguna yang upload
class PenggunaInfo {
  final String id;
  final String email;
  final ProfilPenggunaInfo? profilPengguna;

  PenggunaInfo({
    required this.id,
    required this.email,
    this.profilPengguna,
  });

  factory PenggunaInfo.fromJson(Map<String, dynamic> json) {
    return PenggunaInfo(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      profilPengguna: json['profilPengguna'] != null
          ? ProfilPenggunaInfo.fromJson(json['profilPengguna'])
          : null,
    );
  }

  String get namaLengkap {
    if (profilPengguna != null) {
      final nama = [profilPengguna!.namaDepan, profilPengguna!.namaBelakang]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');
      if (nama.isNotEmpty) return nama;
    }
    return email;
  }
}

class ProfilPenggunaInfo {
  final String? namaDepan;
  final String? namaBelakang;
  final String? urlAvatar;

  ProfilPenggunaInfo({this.namaDepan, this.namaBelakang, this.urlAvatar});

  factory ProfilPenggunaInfo.fromJson(Map<String, dynamic> json) {
    return ProfilPenggunaInfo(
      namaDepan: json['namaDepan'],
      namaBelakang: json['namaBelakang'],
      urlAvatar: json['urlAvatar'],
    );
  }
}

// ==========================================
// REQUEST MODELS
// ==========================================

/// Request untuk upload file
class UploadFileRequest {
  final String tujuan;
  final String? deskripsi;
  final String? idReferensi;

  UploadFileRequest({
    required this.tujuan,
    this.deskripsi,
    this.idReferensi,
  });

  Map<String, String> toFields() {
    final fields = <String, String>{
      'tujuan': tujuan,
    };
    if (deskripsi != null) fields['deskripsi'] = deskripsi!;
    if (idReferensi != null) fields['idReferensi'] = idReferensi!;
    return fields;
  }
}

/// Request untuk filter daftar file
class FilterFileRequest {
  final int? halaman;
  final int? limit;
  final String? tujuan;
  final String? idPengguna;
  final String? idReferensi;
  final String? mimeType;
  final String? cari;
  final String? urutkan;
  final String? arah;

  FilterFileRequest({
    this.halaman,
    this.limit,
    this.tujuan,
    this.idPengguna,
    this.idReferensi,
    this.mimeType,
    this.cari,
    this.urutkan,
    this.arah,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (halaman != null) params['halaman'] = halaman.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (tujuan != null) params['tujuan'] = tujuan!;
    if (idPengguna != null) params['idPengguna'] = idPengguna!;
    if (idReferensi != null) params['idReferensi'] = idReferensi!;
    if (mimeType != null) params['mimeType'] = mimeType!;
    if (cari != null) params['cari'] = cari!;
    if (urutkan != null) params['urutkan'] = urutkan!;
    if (arah != null) params['arah'] = arah!;
    return params;
  }
}

/// Request untuk proses gambar
class ProcessImageRequest {
  final int? lebar;
  final int? tinggi;
  final int? kualitas;
  final String? format;
  final String? fit;
  final bool? pertahankanAspekRasio;

  ProcessImageRequest({
    this.lebar,
    this.tinggi,
    this.kualitas,
    this.format,
    this.fit,
    this.pertahankanAspekRasio,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (lebar != null) data['lebar'] = lebar;
    if (tinggi != null) data['tinggi'] = tinggi;
    if (kualitas != null) data['kualitas'] = kualitas;
    if (format != null) data['format'] = format;
    if (fit != null) data['fit'] = fit;
    if (pertahankanAspekRasio != null) {
      data['pertahankanAspekRasio'] = pertahankanAspekRasio;
    }
    return data;
  }
}

// ==========================================
// RESPONSE MODELS
// ==========================================

/// Response untuk upload single file
class UploadFileResponse {
  final bool sukses;
  final String pesan;
  final FileInfo? data;

  UploadFileResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory UploadFileResponse.fromJson(Map<String, dynamic> json) {
    return UploadFileResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? FileInfo.fromJson(json['data']) : null,
    );
  }
}

/// Response untuk upload multiple files
class UploadMultipleResponse {
  final bool sukses;
  final String pesan;
  final List<FileInfo> berhasil;
  final List<UploadGagal> gagal;
  final int totalBerhasil;
  final int totalGagal;

  UploadMultipleResponse({
    required this.sukses,
    required this.pesan,
    required this.berhasil,
    required this.gagal,
    required this.totalBerhasil,
    required this.totalGagal,
  });

  factory UploadMultipleResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return UploadMultipleResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      berhasil: (data?['berhasil'] as List<dynamic>?)
              ?.map((e) => FileInfo.fromJson(e))
              .toList() ??
          [],
      gagal: (data?['gagal'] as List<dynamic>?)
              ?.map((e) => UploadGagal.fromJson(e))
              .toList() ??
          [],
      totalBerhasil: data?['totalBerhasil'] ?? 0,
      totalGagal: data?['totalGagal'] ?? 0,
    );
  }
}

/// Model untuk file yang gagal diupload
class UploadGagal {
  final String namaFile;
  final String error;

  UploadGagal({required this.namaFile, required this.error});

  factory UploadGagal.fromJson(Map<String, dynamic> json) {
    return UploadGagal(
      namaFile: json['namaFile'] ?? '',
      error: json['error'] ?? '',
    );
  }
}

/// Response untuk daftar file
class DaftarFileResponse {
  final bool sukses;
  final String pesan;
  final List<FileInfo> data;
  final PaginationMetadata? metadata;

  DaftarFileResponse({
    required this.sukses,
    required this.pesan,
    required this.data,
    this.metadata,
  });

  factory DaftarFileResponse.fromJson(Map<String, dynamic> json) {
    return DaftarFileResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => FileInfo.fromJson(e))
              .toList() ??
          [],
      metadata: json['metadata'] != null
          ? PaginationMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

/// Metadata paginasi
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
      limit: json['limit'] ?? 20,
      totalHalaman: json['totalHalaman'] ?? 1,
    );
  }
}

/// Response untuk get file URL
class FileUrlResponse {
  final bool sukses;
  final String url;

  FileUrlResponse({required this.sukses, required this.url});

  factory FileUrlResponse.fromJson(Map<String, dynamic> json) {
    return FileUrlResponse(
      sukses: json['sukses'] ?? false,
      url: json['url'] ?? '',
    );
  }
}

/// Response untuk detail/metadata file
class FileMetadataResponse {
  final bool sukses;
  final String pesan;
  final FileInfo? data;

  FileMetadataResponse({required this.sukses, this.pesan = '', this.data});

  factory FileMetadataResponse.fromJson(Map<String, dynamic> json) {
    return FileMetadataResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? FileInfo.fromJson(json['data']) : null,
    );
  }
}

/// Response untuk hapus file
class HapusFileResponse {
  final bool sukses;
  final String pesan;

  HapusFileResponse({required this.sukses, required this.pesan});

  factory HapusFileResponse.fromJson(Map<String, dynamic> json) {
    return HapusFileResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
    );
  }
}

/// Response untuk proses gambar
class ProcessImageResponse {
  final bool sukses;
  final String pesan;
  final FileInfo? data;

  ProcessImageResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory ProcessImageResponse.fromJson(Map<String, dynamic> json) {
    return ProcessImageResponse(
      sukses: json['sukses'] ?? false,
      pesan: json['pesan'] ?? '',
      data: json['data'] != null ? FileInfo.fromJson(json['data']) : null,
    );
  }
}
