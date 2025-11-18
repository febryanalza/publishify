/// Model untuk sistem review naskah editor
/// File ini berisi semua model data yang digunakan untuk mengelola review naskah

class NaskahSubmission {
  final String id;
  final String judul;
  final String subJudul;
  final String sinopsis;
  final String namaPenulis;
  final String emailPenulis;
  final String kategori;
  final String genre;
  final int jumlahHalaman;
  final int jumlahKata;
  final String bahasaTulis;
  final String urlSampul;
  final String urlFile;
  final String status; // 'menunggu_review', 'dalam_review', 'selesai_review'
  final String? idEditorDitugaskan;
  final String? namaEditorDitugaskan;
  final DateTime tanggalSubmit;
  final DateTime? tanggalDitugaskan;
  final String prioritas; // 'rendah', 'sedang', 'tinggi', 'urgent'

  const NaskahSubmission({
    required this.id,
    required this.judul,
    this.subJudul = '',
    required this.sinopsis,
    required this.namaPenulis,
    required this.emailPenulis,
    required this.kategori,
    required this.genre,
    required this.jumlahHalaman,
    required this.jumlahKata,
    required this.bahasaTulis,
    required this.urlSampul,
    required this.urlFile,
    required this.status,
    this.idEditorDitugaskan,
    this.namaEditorDitugaskan,
    required this.tanggalSubmit,
    this.tanggalDitugaskan,
    required this.prioritas,
  });

  factory NaskahSubmission.fromJson(Map<String, dynamic> json) {
    return NaskahSubmission(
      id: json['id'],
      judul: json['judul'],
      subJudul: json['sub_judul'] ?? '',
      sinopsis: json['sinopsis'],
      namaPenulis: json['nama_penulis'],
      emailPenulis: json['email_penulis'],
      kategori: json['kategori'],
      genre: json['genre'],
      jumlahHalaman: json['jumlah_halaman'],
      jumlahKata: json['jumlah_kata'],
      bahasaTulis: json['bahasa_tulis'],
      urlSampul: json['url_sampul'],
      urlFile: json['url_file'],
      status: json['status'],
      idEditorDitugaskan: json['id_editor_ditugaskan'],
      namaEditorDitugaskan: json['nama_editor_ditugaskan'],
      tanggalSubmit: DateTime.parse(json['tanggal_submit']),
      tanggalDitugaskan: json['tanggal_ditugaskan'] != null 
          ? DateTime.parse(json['tanggal_ditugaskan']) 
          : null,
      prioritas: json['prioritas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'sub_judul': subJudul,
      'sinopsis': sinopsis,
      'nama_penulis': namaPenulis,
      'email_penulis': emailPenulis,
      'kategori': kategori,
      'genre': genre,
      'jumlah_halaman': jumlahHalaman,
      'jumlah_kata': jumlahKata,
      'bahasa_tulis': bahasaTulis,
      'url_sampul': urlSampul,
      'url_file': urlFile,
      'status': status,
      'id_editor_ditugaskan': idEditorDitugaskan,
      'nama_editor_ditugaskan': namaEditorDitugaskan,
      'tanggal_submit': tanggalSubmit.toIso8601String(),
      'tanggal_ditugaskan': tanggalDitugaskan?.toIso8601String(),
      'prioritas': prioritas,
    };
  }

  /// Helper method untuk mendapatkan label status
  String get statusLabel {
    switch (status) {
      case 'menunggu_review':
        return 'Menunggu Review';
      case 'dalam_review':
        return 'Dalam Review';
      case 'selesai_review':
        return 'Selesai Review';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  /// Helper method untuk mendapatkan label prioritas
  String get prioritasLabel {
    switch (prioritas) {
      case 'rendah':
        return 'Rendah';
      case 'sedang':
        return 'Sedang';
      case 'tinggi':
        return 'Tinggi';
      case 'urgent':
        return 'Urgent';
      default:
        return 'Normal';
    }
  }
}

class DetailNaskahSubmission {
  final NaskahSubmission naskah;
  final List<RiwayatReview> riwayatReview;
  final List<KomentarReview> komentar;
  final Map<String, dynamic> metadata;

  const DetailNaskahSubmission({
    required this.naskah,
    required this.riwayatReview,
    required this.komentar,
    required this.metadata,
  });

  factory DetailNaskahSubmission.fromJson(Map<String, dynamic> json) {
    return DetailNaskahSubmission(
      naskah: NaskahSubmission.fromJson(json['naskah']),
      riwayatReview: (json['riwayat_review'] as List)
          .map((item) => RiwayatReview.fromJson(item))
          .toList(),
      komentar: (json['komentar'] as List)
          .map((item) => KomentarReview.fromJson(item))
          .toList(),
      metadata: json['metadata'] ?? {},
    );
  }
}

class RiwayatReview {
  final String id;
  final String idNaskah;
  final String idEditor;
  final String namaEditor;
  final String aksi; // 'ditugaskan', 'diterima', 'ditolak', 'selesai'
  final String? catatan;
  final DateTime tanggal;

  const RiwayatReview({
    required this.id,
    required this.idNaskah,
    required this.idEditor,
    required this.namaEditor,
    required this.aksi,
    this.catatan,
    required this.tanggal,
  });

  factory RiwayatReview.fromJson(Map<String, dynamic> json) {
    return RiwayatReview(
      id: json['id'],
      idNaskah: json['id_naskah'],
      idEditor: json['id_editor'],
      namaEditor: json['nama_editor'],
      aksi: json['aksi'],
      catatan: json['catatan'],
      tanggal: DateTime.parse(json['tanggal']),
    );
  }

  /// Helper method untuk mendapatkan label aksi
  String get aksiLabel {
    switch (aksi) {
      case 'ditugaskan':
        return 'Ditugaskan untuk Review';
      case 'diterima':
        return 'Review Diterima';
      case 'ditolak':
        return 'Review Ditolak';
      case 'selesai':
        return 'Review Selesai';
      default:
        return aksi;
    }
  }
}

class KomentarReview {
  final String id;
  final String idNaskah;
  final String idEditor;
  final String namaEditor;
  final String komentar;
  final String tipe; // 'catatan', 'saran', 'koreksi'
  final DateTime tanggal;

  const KomentarReview({
    required this.id,
    required this.idNaskah,
    required this.idEditor,
    required this.namaEditor,
    required this.komentar,
    required this.tipe,
    required this.tanggal,
  });

  factory KomentarReview.fromJson(Map<String, dynamic> json) {
    return KomentarReview(
      id: json['id'],
      idNaskah: json['id_naskah'],
      idEditor: json['id_editor'],
      namaEditor: json['nama_editor'],
      komentar: json['komentar'],
      tipe: json['tipe'],
      tanggal: DateTime.parse(json['tanggal']),
    );
  }
}

class EditorTersedia {
  final String id;
  final String nama;
  final String email;
  final String spesialisasi;
  final int jumlahTugasAktif;
  final double rating;
  final bool tersedia;
  final String? urlFoto;

  const EditorTersedia({
    required this.id,
    required this.nama,
    required this.email,
    required this.spesialisasi,
    required this.jumlahTugasAktif,
    required this.rating,
    required this.tersedia,
    this.urlFoto,
  });

  factory EditorTersedia.fromJson(Map<String, dynamic> json) {
    return EditorTersedia(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      spesialisasi: json['spesialisasi'],
      jumlahTugasAktif: json['jumlah_tugas_aktif'],
      rating: json['rating'].toDouble(),
      tersedia: json['tersedia'],
      urlFoto: json['url_foto'],
    );
  }
}

class ReviewNaskahResponse<T> {
  final bool sukses;
  final String pesan;
  final T? data;
  final Map<String, dynamic>? metadata;

  const ReviewNaskahResponse({
    required this.sukses,
    required this.pesan,
    this.data,
    this.metadata,
  });

  factory ReviewNaskahResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ReviewNaskahResponse<T>(
      sukses: json['sukses'],
      pesan: json['pesan'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      metadata: json['metadata'],
    );
  }
}