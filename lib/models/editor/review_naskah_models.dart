/// Review Naskah Models - Model untuk Naskah Submission Review
/// Digunakan pada halaman review_naskah_page.dart dan detail_review_naskah_page.dart

import 'package:publishify/models/editor/review_models.dart';

/// Model untuk Naskah Submission yang perlu direview
class NaskahSubmission {
  final String id;
  final String judul;
  final String? subJudul;
  final String sinopsis;
  final String penulis;
  final String namaPenulis;
  final String idPenulis;
  final String emailPenulis;
  final String kategori;
  final String genre;
  final String status;
  final int jumlahHalaman;
  final int jumlahKata;
  final String bahasaTulis;
  final DateTime tanggalSubmit;
  final String? urlSampul;
  final String? urlFile;
  final int? versi;
  final String? editorDitugaskan;
  final String? namaEditorDitugaskan;
  final DateTime? tanggalDitugaskan;
  final String? catatan;
  final String prioritas;

  NaskahSubmission({
    required this.id,
    required this.judul,
    this.subJudul,
    required this.sinopsis,
    required this.penulis,
    required this.namaPenulis,
    required this.idPenulis,
    required this.emailPenulis,
    required this.kategori,
    required this.genre,
    required this.status,
    required this.jumlahHalaman,
    required this.jumlahKata,
    this.bahasaTulis = 'Indonesia',
    required this.tanggalSubmit,
    this.urlSampul,
    this.urlFile,
    this.versi,
    this.editorDitugaskan,
    this.namaEditorDitugaskan,
    this.tanggalDitugaskan,
    this.catatan,
    this.prioritas = 'normal',
  });

  factory NaskahSubmission.fromJson(Map<String, dynamic> json) {
    // Extract penulis info
    String penulis = '';
    String namaPenulis = '';
    String emailPenulis = '';
    String idPenulis = '';
    
    if (json['penulis'] is Map) {
      final penulisData = json['penulis'] as Map<String, dynamic>;
      emailPenulis = penulisData['email'] ?? '';
      idPenulis = penulisData['id'] ?? '';
      
      if (penulisData['profilPengguna'] is Map) {
        final profil = penulisData['profilPengguna'] as Map<String, dynamic>;
        namaPenulis = profil['namaLengkap'] ?? profil['namaTampilan'] ?? emailPenulis;
      } else {
        namaPenulis = emailPenulis;
      }
      penulis = namaPenulis;
    } else {
      penulis = json['penulis']?.toString() ?? '';
      namaPenulis = json['namaPenulis'] ?? penulis;
      emailPenulis = json['emailPenulis'] ?? '';
      idPenulis = json['idPenulis'] ?? '';
    }

    // Extract kategori
    String kategori = '';
    if (json['kategori'] is Map) {
      kategori = json['kategori']['nama'] ?? '';
    } else {
      kategori = json['kategori']?.toString() ?? '';
    }

    // Extract genre
    String genre = '';
    if (json['genre'] is Map) {
      genre = json['genre']['nama'] ?? '';
    } else {
      genre = json['genre']?.toString() ?? '';
    }

    // Extract editor info
    String? editorDitugaskan;
    String? namaEditorDitugaskan;
    if (json['editor'] is Map) {
      final editorData = json['editor'] as Map<String, dynamic>;
      editorDitugaskan = editorData['id'];
      if (editorData['profilPengguna'] is Map) {
        namaEditorDitugaskan = editorData['profilPengguna']['namaLengkap'] ?? 
                               editorData['profilPengguna']['namaTampilan'] ?? 
                               editorData['email'];
      } else {
        namaEditorDitugaskan = editorData['email'];
      }
    } else {
      editorDitugaskan = json['editorDitugaskan'];
      namaEditorDitugaskan = json['namaEditorDitugaskan'];
    }

    return NaskahSubmission(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      subJudul: json['subJudul'],
      sinopsis: json['sinopsis'] ?? '',
      penulis: penulis,
      namaPenulis: namaPenulis,
      idPenulis: idPenulis,
      emailPenulis: emailPenulis,
      kategori: kategori,
      genre: genre,
      status: json['status'] ?? 'diajukan',
      jumlahHalaman: json['jumlahHalaman'] ?? 0,
      jumlahKata: json['jumlahKata'] ?? 0,
      bahasaTulis: json['bahasaTulis'] ?? json['bahasa'] ?? 'Indonesia',
      tanggalSubmit: DateTime.tryParse(json['dibuatPada'] ?? json['tanggalSubmit'] ?? '') ?? DateTime.now(),
      urlSampul: json['urlSampul'],
      urlFile: json['urlFile'],
      versi: json['versi'],
      editorDitugaskan: editorDitugaskan,
      namaEditorDitugaskan: namaEditorDitugaskan,
      tanggalDitugaskan: json['tanggalDitugaskan'] != null 
          ? DateTime.tryParse(json['tanggalDitugaskan'])
          : null,
      catatan: json['catatan'],
      prioritas: json['prioritas'] ?? 'normal',
    );
  }

  /// Create from ReviewNaskah model
  factory NaskahSubmission.fromReviewNaskah(ReviewNaskah review) {
    final naskahData = review.naskah;
    final penulisData = naskahData.penulis;
    final namaLengkap = penulisData.profilPengguna?.namaLengkap ?? penulisData.email;
    
    return NaskahSubmission(
      id: review.idNaskah,
      judul: naskahData.judul,
      subJudul: naskahData.subJudul,
      sinopsis: naskahData.sinopsis,
      penulis: namaLengkap,
      namaPenulis: namaLengkap,
      idPenulis: penulisData.id,
      emailPenulis: penulisData.email,
      kategori: naskahData.kategori.nama,
      genre: naskahData.genre.nama,
      status: naskahData.status.name,
      jumlahHalaman: naskahData.jumlahHalaman ?? 0,
      jumlahKata: naskahData.jumlahKata ?? 0,
      bahasaTulis: 'Indonesia', // Default, NaskahInfo tidak punya field ini
      tanggalSubmit: review.ditugaskanPada,
      urlSampul: naskahData.urlSampul,
      urlFile: naskahData.urlFile,
      catatan: review.catatan,
      prioritas: 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'subJudul': subJudul,
      'sinopsis': sinopsis,
      'penulis': penulis,
      'namaPenulis': namaPenulis,
      'idPenulis': idPenulis,
      'emailPenulis': emailPenulis,
      'kategori': kategori,
      'genre': genre,
      'status': status,
      'jumlahHalaman': jumlahHalaman,
      'jumlahKata': jumlahKata,
      'bahasaTulis': bahasaTulis,
      'tanggalSubmit': tanggalSubmit.toIso8601String(),
      'urlSampul': urlSampul,
      'urlFile': urlFile,
      'versi': versi,
      'editorDitugaskan': editorDitugaskan,
      'namaEditorDitugaskan': namaEditorDitugaskan,
      'tanggalDitugaskan': tanggalDitugaskan?.toIso8601String(),
      'catatan': catatan,
      'prioritas': prioritas,
    };
  }

  /// Helper untuk label status
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'diajukan': return 'Diajukan';
      case 'menunggu_review': return 'Menunggu Review';
      case 'dalam_review': return 'Dalam Review';
      case 'perlu_revisi': return 'Perlu Revisi';
      case 'disetujui': return 'Disetujui';
      case 'selesai_review': return 'Selesai Review';
      case 'ditolak': return 'Ditolak';
      default: return status;
    }
  }

  /// Helper untuk label prioritas
  String get prioritasLabel {
    switch (prioritas.toLowerCase()) {
      case 'tinggi': return 'Prioritas Tinggi';
      case 'normal': return 'Prioritas Normal';
      case 'rendah': return 'Prioritas Rendah';
      default: return prioritas;
    }
  }

  /// Helper untuk warna status
  int get statusColor {
    switch (status.toLowerCase()) {
      case 'diajukan': return 0xFF2196F3; // Blue
      case 'menunggu_review': return 0xFFFF9800; // Orange
      case 'dalam_review': return 0xFF03A9F4; // Light Blue
      case 'perlu_revisi': return 0xFFFFC107; // Amber
      case 'disetujui': return 0xFF4CAF50; // Green
      case 'selesai_review': return 0xFF4CAF50; // Green
      case 'ditolak': return 0xFFF44336; // Red
      default: return 0xFF9E9E9E; // Grey
    }
  }
}

/// Riwayat Review - untuk tracking aksi review
class RiwayatReview {
  final String id;
  final String aksi;
  final String namaEditor;
  final String? idEditor;
  final DateTime tanggal;
  final String? catatan;
  final String? status;
  final String? rekomendasi;

  RiwayatReview({
    required this.id,
    required this.aksi,
    required this.namaEditor,
    this.idEditor,
    required this.tanggal,
    this.catatan,
    this.status,
    this.rekomendasi,
  });

  factory RiwayatReview.fromJson(Map<String, dynamic> json) {
    // Extract editor name
    String namaEditor = '';
    String? idEditor;
    
    if (json['editor'] is Map) {
      final editorData = json['editor'] as Map<String, dynamic>;
      idEditor = editorData['id'];
      if (editorData['profilPengguna'] is Map) {
        namaEditor = editorData['profilPengguna']['namaLengkap'] ?? 
                     editorData['profilPengguna']['namaTampilan'] ?? 
                     editorData['email'] ?? '';
      } else {
        namaEditor = editorData['email'] ?? '';
      }
    } else {
      namaEditor = json['namaEditor'] ?? json['editor'] ?? '';
      idEditor = json['idEditor'];
    }

    return RiwayatReview(
      id: json['id'] ?? '',
      aksi: json['aksi'] ?? json['tipe'] ?? '',
      namaEditor: namaEditor,
      idEditor: idEditor,
      tanggal: DateTime.tryParse(json['tanggal'] ?? json['dibuatPada'] ?? '') ?? DateTime.now(),
      catatan: json['catatan'] ?? json['keterangan'],
      status: json['status'],
      rekomendasi: json['rekomendasi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aksi': aksi,
      'namaEditor': namaEditor,
      'idEditor': idEditor,
      'tanggal': tanggal.toIso8601String(),
      'catatan': catatan,
      'status': status,
      'rekomendasi': rekomendasi,
    };
  }

  /// Helper untuk label aksi
  String get aksiLabel {
    switch (aksi.toLowerCase()) {
      case 'ditugaskan': return 'Ditugaskan';
      case 'mulai_review': return 'Mulai Review';
      case 'selesai_review': return 'Selesai Review';
      case 'minta_revisi': return 'Minta Revisi';
      case 'setujui': return 'Disetujui';
      case 'tolak': return 'Ditolak';
      case 'dibatalkan': return 'Dibatalkan';
      case 'komentar': return 'Komentar';
      case 'feedback': return 'Feedback';
      default: return aksi;
    }
  }
}

/// Komentar Review - untuk komentar/feedback review
class KomentarReview {
  final String id;
  final String tipe; // saran, koreksi, catatan
  final String komentar;
  final String namaEditor;
  final String? idEditor;
  final DateTime tanggal;
  final String? bab;
  final int? halaman;

  KomentarReview({
    required this.id,
    required this.tipe,
    required this.komentar,
    required this.namaEditor,
    this.idEditor,
    required this.tanggal,
    this.bab,
    this.halaman,
  });

  factory KomentarReview.fromJson(Map<String, dynamic> json) {
    // Extract editor name
    String namaEditor = '';
    String? idEditor;
    
    if (json['editor'] is Map) {
      final editorData = json['editor'] as Map<String, dynamic>;
      idEditor = editorData['id'];
      if (editorData['profilPengguna'] is Map) {
        namaEditor = editorData['profilPengguna']['namaLengkap'] ?? 
                     editorData['profilPengguna']['namaTampilan'] ?? 
                     editorData['email'] ?? '';
      } else {
        namaEditor = editorData['email'] ?? '';
      }
    } else {
      namaEditor = json['namaEditor'] ?? json['editor'] ?? '';
      idEditor = json['idEditor'];
    }

    return KomentarReview(
      id: json['id'] ?? '',
      tipe: json['tipe'] ?? json['kategori'] ?? 'catatan',
      komentar: json['komentar'] ?? json['isiKomentar'] ?? json['isi'] ?? '',
      namaEditor: namaEditor,
      idEditor: idEditor,
      tanggal: DateTime.tryParse(json['tanggal'] ?? json['dibuatPada'] ?? '') ?? DateTime.now(),
      bab: json['bab'],
      halaman: json['halaman'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipe': tipe,
      'komentar': komentar,
      'namaEditor': namaEditor,
      'idEditor': idEditor,
      'tanggal': tanggal.toIso8601String(),
      'bab': bab,
      'halaman': halaman,
    };
  }
}

/// Detail Naskah Submission - untuk halaman detail
class DetailNaskahSubmission {
  final String id;
  final NaskahSubmission naskah;
  final Map<String, dynamic> metadata;
  final List<RiwayatReview> riwayatReview;
  final List<KomentarReview> komentar;
  final List<RiwayatRevisi> riwayatRevisi;
  final List<FeedbackItem> feedbacks;

  DetailNaskahSubmission({
    required this.id,
    required this.naskah,
    this.metadata = const {},
    this.riwayatReview = const [],
    this.komentar = const [],
    this.riwayatRevisi = const [],
    this.feedbacks = const [],
  });

  factory DetailNaskahSubmission.fromJson(Map<String, dynamic> json) {
    // Parse naskah
    final naskah = NaskahSubmission.fromJson(json);
    
    // Parse metadata
    Map<String, dynamic> metadata = {};
    if (json['metadata'] is Map) {
      metadata = Map<String, dynamic>.from(json['metadata']);
    } else {
      // Build metadata from available fields
      metadata = {
        'total_download': json['totalDownload'] ?? 0,
        'rata_rata_rating': json['rataRataRating'] ?? 0,
        'estimasi_review': json['estimasiReview'],
      };
    }

    // Parse riwayat review
    List<RiwayatReview> riwayatReview = [];
    if (json['riwayatReview'] is List) {
      riwayatReview = (json['riwayatReview'] as List)
          .map((e) => RiwayatReview.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse komentar
    List<KomentarReview> komentar = [];
    if (json['komentar'] is List) {
      komentar = (json['komentar'] as List)
          .map((e) => KomentarReview.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['feedback'] is List) {
      komentar = (json['feedback'] as List)
          .map((e) => KomentarReview.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse riwayat revisi
    List<RiwayatRevisi> riwayatRevisi = [];
    if (json['revisi'] is List) {
      riwayatRevisi = (json['revisi'] as List)
          .map((e) => RiwayatRevisi.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['riwayatRevisi'] is List) {
      riwayatRevisi = (json['riwayatRevisi'] as List)
          .map((e) => RiwayatRevisi.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse feedbacks
    List<FeedbackItem> feedbacks = [];
    if (json['feedbacks'] is List) {
      feedbacks = (json['feedbacks'] as List)
          .map((e) => FeedbackItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DetailNaskahSubmission(
      id: json['id'] ?? '',
      naskah: naskah,
      metadata: metadata,
      riwayatReview: riwayatReview,
      komentar: komentar,
      riwayatRevisi: riwayatRevisi,
      feedbacks: feedbacks,
    );
  }

  factory DetailNaskahSubmission.fromReviewNaskah(ReviewNaskah review) {
    final naskah = NaskahSubmission.fromReviewNaskah(review);
    
    return DetailNaskahSubmission(
      id: review.id,
      naskah: naskah,
      metadata: {},
      riwayatReview: [],
      komentar: [],
      feedbacks: review.feedback.map((f) => FeedbackItem.fromFeedbackReview(f)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'naskah': naskah.toJson(),
      'metadata': metadata,
      'riwayatReview': riwayatReview.map((e) => e.toJson()).toList(),
      'komentar': komentar.map((e) => e.toJson()).toList(),
      'riwayatRevisi': riwayatRevisi.map((e) => e.toJson()).toList(),
      'feedbacks': feedbacks.map((e) => e.toJson()).toList(),
    };
  }
}

/// Riwayat Revisi
class RiwayatRevisi {
  final String id;
  final int versi;
  final String catatan;
  final DateTime tanggal;
  final String? urlFile;

  RiwayatRevisi({
    required this.id,
    required this.versi,
    required this.catatan,
    required this.tanggal,
    this.urlFile,
  });

  factory RiwayatRevisi.fromJson(Map<String, dynamic> json) {
    return RiwayatRevisi(
      id: json['id'] ?? '',
      versi: json['versi'] ?? 1,
      catatan: json['catatan'] ?? '',
      tanggal: DateTime.tryParse(json['tanggal'] ?? json['dibuatPada'] ?? '') ?? DateTime.now(),
      urlFile: json['urlFile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'versi': versi,
      'catatan': catatan,
      'tanggal': tanggal.toIso8601String(),
      'urlFile': urlFile,
    };
  }
}

/// Feedback Item
class FeedbackItem {
  final String id;
  final String komentar;
  final String? bab;
  final int? halaman;
  final DateTime tanggal;
  final String editor;

  FeedbackItem({
    required this.id,
    required this.komentar,
    this.bab,
    this.halaman,
    required this.tanggal,
    required this.editor,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    // Extract editor name
    String editor = '';
    if (json['editor'] is Map) {
      final editorData = json['editor'] as Map<String, dynamic>;
      if (editorData['profilPengguna'] is Map) {
        editor = editorData['profilPengguna']['namaLengkap'] ?? 
                 editorData['profilPengguna']['namaTampilan'] ?? 
                 editorData['email'] ?? '';
      } else {
        editor = editorData['email'] ?? '';
      }
    } else {
      editor = json['editor']?.toString() ?? '';
    }

    return FeedbackItem(
      id: json['id'] ?? '',
      komentar: json['isiKomentar'] ?? json['komentar'] ?? '',
      bab: json['bab'],
      halaman: json['halaman'],
      tanggal: DateTime.tryParse(json['dibuatPada'] ?? json['tanggal'] ?? '') ?? DateTime.now(),
      editor: editor,
    );
  }

  factory FeedbackItem.fromFeedbackReview(FeedbackReview feedback) {
    return FeedbackItem(
      id: feedback.id,
      komentar: feedback.komentar,
      bab: feedback.bab,
      halaman: feedback.halaman,
      tanggal: feedback.dibuatPada,
      editor: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'komentar': komentar,
      'bab': bab,
      'halaman': halaman,
      'tanggal': tanggal.toIso8601String(),
      'editor': editor,
    };
  }
}

/// Response untuk service calls
class NaskahSubmissionResponse {
  final bool sukses;
  final String pesan;
  final List<NaskahSubmission>? data;

  NaskahSubmissionResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory NaskahSubmissionResponse.success(List<NaskahSubmission> data, {String pesan = 'Berhasil'}) {
    return NaskahSubmissionResponse(sukses: true, pesan: pesan, data: data);
  }

  factory NaskahSubmissionResponse.error(String pesan) {
    return NaskahSubmissionResponse(sukses: false, pesan: pesan);
  }
}

/// Response untuk detail naskah
class DetailNaskahResponse {
  final bool sukses;
  final String pesan;
  final DetailNaskahSubmission? data;

  DetailNaskahResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory DetailNaskahResponse.success(DetailNaskahSubmission data, {String pesan = 'Berhasil'}) {
    return DetailNaskahResponse(sukses: true, pesan: pesan, data: data);
  }

  factory DetailNaskahResponse.error(String pesan) {
    return DetailNaskahResponse(sukses: false, pesan: pesan);
  }
}

/// Response untuk single action
class ActionResponse {
  final bool sukses;
  final String pesan;

  ActionResponse({
    required this.sukses,
    required this.pesan,
  });

  factory ActionResponse.success(String pesan) {
    return ActionResponse(sukses: true, pesan: pesan);
  }

  factory ActionResponse.error(String pesan) {
    return ActionResponse(sukses: false, pesan: pesan);
  }
}

/// Model untuk Editor Tersedia - digunakan untuk tugaskan ke editor lain
class EditorTersedia {
  final String id;
  final String nama;
  final String email;
  final String? urlFoto;
  final String spesialisasi;
  final double rating;
  final int jumlahTugasAktif;
  final bool tersedia;

  EditorTersedia({
    required this.id,
    required this.nama,
    required this.email,
    this.urlFoto,
    this.spesialisasi = '',
    this.rating = 0.0,
    this.jumlahTugasAktif = 0,
    this.tersedia = true,
  });

  factory EditorTersedia.fromJson(Map<String, dynamic> json) {
    // Extract nama
    String nama = '';
    if (json['profilPengguna'] is Map) {
      final profil = json['profilPengguna'] as Map<String, dynamic>;
      nama = profil['namaLengkap'] ?? profil['namaTampilan'] ?? json['email'] ?? '';
    } else {
      nama = json['nama'] ?? json['email'] ?? '';
    }

    // Extract spesialisasi
    String spesialisasi = '';
    if (json['spesialisasi'] is List) {
      spesialisasi = (json['spesialisasi'] as List).join(', ');
    } else if (json['profilPenulis']?['spesialisasi'] is List) {
      spesialisasi = (json['profilPenulis']['spesialisasi'] as List).join(', ');
    } else {
      spesialisasi = json['spesialisasi']?.toString() ?? '';
    }

    return EditorTersedia(
      id: json['id'] ?? '',
      nama: nama,
      email: json['email'] ?? '',
      urlFoto: json['urlFoto'] ?? json['profilPengguna']?['urlAvatar'],
      spesialisasi: spesialisasi,
      rating: (json['rating'] ?? json['ratingRataRata'] ?? 0.0).toDouble(),
      jumlahTugasAktif: json['jumlahTugasAktif'] ?? json['reviewAktif'] ?? 0,
      tersedia: json['tersedia'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'urlFoto': urlFoto,
      'spesialisasi': spesialisasi,
      'rating': rating,
      'jumlahTugasAktif': jumlahTugasAktif,
      'tersedia': tersedia,
    };
  }
}

/// Response untuk editor tersedia
class EditorTersediaResponse {
  final bool sukses;
  final String pesan;
  final List<EditorTersedia>? data;

  EditorTersediaResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory EditorTersediaResponse.success(List<EditorTersedia> data) {
    return EditorTersediaResponse(sukses: true, pesan: 'Berhasil', data: data);
  }

  factory EditorTersediaResponse.error(String pesan) {
    return EditorTersediaResponse(sukses: false, pesan: pesan);
  }
}
