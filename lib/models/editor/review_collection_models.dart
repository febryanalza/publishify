/// Review Collection Models - Model untuk Review Collection Page
/// Digunakan pada halaman review_collection_page.dart dan review_detail_page.dart

import 'package:publishify/models/editor/review_models.dart';
import 'package:publishify/models/editor/review_naskah_models.dart' as naskah_models;

/// Model untuk Buku Masuk Review
class BukuMasukReview {
  final String id;
  final String judul;
  final String? subJudul;
  final String penulis;
  final String namaPenulis;
  final String idPenulis;
  final String emailPenulis;
  final String kategori;
  final String genre;
  final String status;
  final int jumlahHalaman;
  final int jumlahKata;
  final DateTime tanggalMasuk;
  final DateTime? tanggalSubmit;
  final DateTime? deadlineReview;
  final String? urlSampul;
  final String sinopsis;
  final String? editorDitugaskan;
  final String? editorYangDitugaskan;
  final int prioritas;

  BukuMasukReview({
    required this.id,
    required this.judul,
    this.subJudul,
    required this.penulis,
    required this.namaPenulis,
    required this.idPenulis,
    required this.emailPenulis,
    required this.kategori,
    required this.genre,
    required this.status,
    required this.jumlahHalaman,
    required this.jumlahKata,
    required this.tanggalMasuk,
    this.tanggalSubmit,
    this.deadlineReview,
    this.urlSampul,
    required this.sinopsis,
    this.editorDitugaskan,
    this.editorYangDitugaskan,
    this.prioritas = 3,
  });

  factory BukuMasukReview.fromJson(Map<String, dynamic> json) {
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
    String? editorYangDitugaskan;
    if (json['editor'] is Map) {
      final editorData = json['editor'] as Map<String, dynamic>;
      editorDitugaskan = editorData['id'];
      if (editorData['profilPengguna'] is Map) {
        editorYangDitugaskan = editorData['profilPengguna']['namaLengkap'] ?? 
                               editorData['profilPengguna']['namaTampilan'] ?? 
                               editorData['email'];
      } else {
        editorYangDitugaskan = editorData['email'];
      }
    } else {
      editorDitugaskan = json['editorDitugaskan'];
      editorYangDitugaskan = json['editorYangDitugaskan'] ?? json['namaEditor'];
    }

    return BukuMasukReview(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      subJudul: json['subJudul'],
      penulis: penulis,
      namaPenulis: namaPenulis,
      idPenulis: idPenulis,
      emailPenulis: emailPenulis,
      kategori: kategori,
      genre: genre,
      status: json['status'] ?? 'menunggu',
      jumlahHalaman: json['jumlahHalaman'] ?? 0,
      jumlahKata: json['jumlahKata'] ?? 0,
      tanggalMasuk: DateTime.tryParse(json['tanggalMasuk'] ?? json['dibuatPada'] ?? '') ?? DateTime.now(),
      tanggalSubmit: json['tanggalSubmit'] != null 
          ? DateTime.tryParse(json['tanggalSubmit']) 
          : DateTime.tryParse(json['dibuatPada'] ?? ''),
      deadlineReview: json['deadlineReview'] != null 
          ? DateTime.tryParse(json['deadlineReview']) 
          : null,
      urlSampul: json['urlSampul'],
      sinopsis: json['sinopsis'] ?? '',
      editorDitugaskan: editorDitugaskan,
      editorYangDitugaskan: editorYangDitugaskan,
      prioritas: json['prioritas'] ?? 3,
    );
  }

  /// Create from ReviewNaskah model
  factory BukuMasukReview.fromReviewNaskah(ReviewNaskah review) {
    final penulisData = review.naskah.penulis;
    final namaLengkap = penulisData?.profilPengguna?.namaLengkap ?? penulisData?.email ?? 'Tidak diketahui';
    final editorNama = review.editor.profilPengguna?.namaLengkap ?? review.editor.email;
    
    return BukuMasukReview(
      id: review.id,
      judul: review.naskah.judul,
      subJudul: review.naskah.subJudul,
      penulis: namaLengkap,
      namaPenulis: namaLengkap,
      idPenulis: penulisData?.id ?? '',
      emailPenulis: penulisData?.email ?? '',
      kategori: review.naskah.kategori?.nama ?? '',
      genre: review.naskah.genre?.nama ?? '',
      status: _mapStatus(review.status),
      jumlahHalaman: review.naskah.jumlahHalaman ?? 0,
      jumlahKata: review.naskah.jumlahKata ?? 0,
      tanggalMasuk: review.ditugaskanPada,
      tanggalSubmit: review.ditugaskanPada,
      urlSampul: review.naskah.urlSampul,
      sinopsis: review.naskah.sinopsis ?? '',
      editorDitugaskan: review.idEditor,
      editorYangDitugaskan: editorNama,
    );
  }

  static String _mapStatus(StatusReview status) {
    switch (status) {
      case StatusReview.ditugaskan:
        return 'menunggu';
      case StatusReview.dalam_proses:
        return 'sedang_review';
      case StatusReview.selesai:
        return 'selesai';
      case StatusReview.dibatalkan:
        return 'dibatalkan';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'subJudul': subJudul,
      'penulis': penulis,
      'namaPenulis': namaPenulis,
      'idPenulis': idPenulis,
      'emailPenulis': emailPenulis,
      'kategori': kategori,
      'genre': genre,
      'status': status,
      'jumlahHalaman': jumlahHalaman,
      'jumlahKata': jumlahKata,
      'tanggalMasuk': tanggalMasuk.toIso8601String(),
      'tanggalSubmit': tanggalSubmit?.toIso8601String(),
      'deadlineReview': deadlineReview?.toIso8601String(),
      'urlSampul': urlSampul,
      'sinopsis': sinopsis,
      'editorDitugaskan': editorDitugaskan,
      'editorYangDitugaskan': editorYangDitugaskan,
      'prioritas': prioritas,
    };
  }

  /// Helper untuk label status
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'menunggu': return 'Menunggu';
      case 'diterima': return 'Diterima';
      case 'sedang_review': return 'Sedang Review';
      case 'selesai': return 'Selesai';
      case 'dibatalkan': return 'Dibatalkan';
      default: return status;
    }
  }

  /// Helper untuk warna status
  int get statusColor {
    switch (status.toLowerCase()) {
      case 'menunggu': return 0xFF2196F3; // Blue
      case 'diterima': return 0xFF9C27B0; // Purple
      case 'sedang_review': return 0xFFFF9800; // Orange
      case 'selesai': return 0xFF4CAF50; // Green
      case 'dibatalkan': return 0xFFF44336; // Red
      default: return 0xFF9E9E9E; // Grey
    }
  }
}

/// EditorOption - untuk pilihan editor yang tersedia
class EditorOption {
  final String id;
  final String nama;
  final String email;
  final int totalReview;
  final int reviewAktif;
  final bool tersedia;
  final List<String> spesialisasi;
  final int workload;
  final double rating;

  EditorOption({
    required this.id,
    required this.nama,
    required this.email,
    this.totalReview = 0,
    this.reviewAktif = 0,
    this.tersedia = true,
    this.spesialisasi = const [],
    this.workload = 0,
    this.rating = 0.0,
  });

  factory EditorOption.fromJson(Map<String, dynamic> json) {
    String nama = '';
    if (json['profilPengguna'] is Map) {
      final profil = json['profilPengguna'] as Map<String, dynamic>;
      nama = profil['namaLengkap'] ?? profil['namaTampilan'] ?? json['email'] ?? '';
    } else {
      nama = json['nama'] ?? json['email'] ?? '';
    }

    // Parse spesialisasi
    List<String> spesialisasi = [];
    if (json['spesialisasi'] is List) {
      spesialisasi = (json['spesialisasi'] as List).map((e) => e.toString()).toList();
    } else if (json['profilPenulis']?['spesialisasi'] is List) {
      spesialisasi = (json['profilPenulis']['spesialisasi'] as List).map((e) => e.toString()).toList();
    }

    return EditorOption(
      id: json['id'] ?? '',
      nama: nama,
      email: json['email'] ?? '',
      totalReview: json['totalReview'] ?? json['_count']?['reviewEditor'] ?? 0,
      reviewAktif: json['reviewAktif'] ?? 0,
      tersedia: json['tersedia'] ?? true,
      spesialisasi: spesialisasi,
      workload: json['workload'] ?? json['reviewAktif'] ?? 0,
      rating: (json['rating'] ?? json['ratingRataRata'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'totalReview': totalReview,
      'reviewAktif': reviewAktif,
      'tersedia': tersedia,
      'spesialisasi': spesialisasi,
      'workload': workload,
      'rating': rating,
    };
  }
}

/// Model untuk Detail Buku Review
class DetailBukuReview {
  final String id;
  final String judul;
  final String subJudul;
  final String penulis;
  final String emailPenulis;
  final String kategori;
  final String genre;
  final String status;
  final String sinopsis;
  final int jumlahHalaman;
  final int jumlahKata;
  final DateTime tanggalMasuk;
  final String? urlSampul;
  final String? urlFile;
  final String? isbn;
  final BukuInfo? bukuInfo;
  final Map<String, dynamic> metadata;
  final List<String> tagKeyword;
  final List<BabBuku> daftarBab;
  final List<ReviewFeedback> feedbacks;
  final List<naskah_models.RiwayatReview>? riwayatReview;

  DetailBukuReview({
    required this.id,
    required this.judul,
    this.subJudul = '',
    required this.penulis,
    required this.emailPenulis,
    required this.kategori,
    required this.genre,
    required this.status,
    required this.sinopsis,
    required this.jumlahHalaman,
    required this.jumlahKata,
    required this.tanggalMasuk,
    this.urlSampul,
    this.urlFile,
    this.isbn,
    this.bukuInfo,
    this.metadata = const {},
    this.tagKeyword = const [],
    this.daftarBab = const [],
    this.feedbacks = const [],
    this.riwayatReview,
  });

  factory DetailBukuReview.fromJson(Map<String, dynamic> json) {
    // Extract penulis info
    String penulis = '';
    String emailPenulis = '';
    
    if (json['penulis'] is Map) {
      final penulisData = json['penulis'] as Map<String, dynamic>;
      emailPenulis = penulisData['email'] ?? '';
      
      if (penulisData['profilPengguna'] is Map) {
        final profil = penulisData['profilPengguna'] as Map<String, dynamic>;
        penulis = profil['namaLengkap'] ?? profil['namaTampilan'] ?? emailPenulis;
      } else {
        penulis = emailPenulis;
      }
    } else {
      penulis = json['penulis']?.toString() ?? '';
      emailPenulis = json['emailPenulis'] ?? '';
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

    // Build bukuInfo
    BukuInfo? bukuInfo;
    if (json['bukuInfo'] is Map) {
      bukuInfo = BukuInfo.fromJson(json['bukuInfo']);
    } else {
      bukuInfo = BukuInfo(
        judul: json['judul'] ?? '',
        penulis: penulis,
        kategori: kategori,
        genre: genre,
      );
    }

    // Parse metadata
    Map<String, dynamic> metadata = {};
    if (json['metadata'] is Map) {
      metadata = Map<String, dynamic>.from(json['metadata']);
    }

    // Parse tagKeyword
    List<String> tagKeyword = [];
    if (json['tagKeyword'] is List) {
      tagKeyword = (json['tagKeyword'] as List).map((e) => e.toString()).toList();
    } else if (json['tags'] is List) {
      tagKeyword = (json['tags'] as List).map((e) => e.toString()).toList();
    }

    // Parse riwayat review
    List<naskah_models.RiwayatReview>? riwayatReview;
    if (json['riwayatReview'] is List) {
      riwayatReview = (json['riwayatReview'] as List)
          .map((e) => naskah_models.RiwayatReview.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DetailBukuReview(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      subJudul: json['subJudul'] ?? '',
      penulis: penulis,
      emailPenulis: emailPenulis,
      kategori: kategori,
      genre: genre,
      status: json['status'] ?? '',
      sinopsis: json['sinopsis'] ?? '',
      jumlahHalaman: json['jumlahHalaman'] ?? 0,
      jumlahKata: json['jumlahKata'] ?? 0,
      tanggalMasuk: DateTime.tryParse(json['dibuatPada'] ?? json['tanggalMasuk'] ?? '') ?? DateTime.now(),
      urlSampul: json['urlSampul'],
      urlFile: json['urlFile'],
      isbn: json['isbn'],
      bukuInfo: bukuInfo,
      metadata: metadata,
      tagKeyword: tagKeyword,
      daftarBab: (json['daftarBab'] as List<dynamic>?)
          ?.map((e) => BabBuku.fromJson(e))
          .toList() ?? [],
      feedbacks: (json['feedbacks'] as List<dynamic>?)
          ?.map((e) => ReviewFeedback.fromJson(e))
          .toList() ?? [],
      riwayatReview: riwayatReview,
    );
  }

  factory DetailBukuReview.fromReviewNaskah(ReviewNaskah review) {
    final penulisData = review.naskah.penulis;
    final namaLengkap = penulisData?.profilPengguna?.namaLengkap ?? penulisData?.email ?? 'Tidak diketahui';
    
    return DetailBukuReview(
      id: review.id,
      judul: review.naskah.judul,
      subJudul: review.naskah.subJudul ?? '',
      penulis: namaLengkap,
      emailPenulis: penulisData?.email ?? '',
      kategori: review.naskah.kategori?.nama ?? '',
      genre: review.naskah.genre?.nama ?? '',
      status: review.status.name,
      sinopsis: review.naskah.sinopsis ?? '',
      jumlahHalaman: review.naskah.jumlahHalaman ?? 0,
      jumlahKata: review.naskah.jumlahKata ?? 0,
      tanggalMasuk: review.ditugaskanPada,
      urlSampul: review.naskah.urlSampul,
      urlFile: review.naskah.urlFile,
      isbn: review.naskah.isbn,
      bukuInfo: BukuInfo(
        judul: review.naskah.judul,
        penulis: namaLengkap,
        kategori: review.naskah.kategori?.nama ?? '',
        genre: review.naskah.genre?.nama ?? '',
      ),
      feedbacks: review.feedback.map((f) => ReviewFeedback.fromFeedbackReview(f)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'subJudul': subJudul,
      'penulis': penulis,
      'emailPenulis': emailPenulis,
      'kategori': kategori,
      'genre': genre,
      'status': status,
      'sinopsis': sinopsis,
      'jumlahHalaman': jumlahHalaman,
      'jumlahKata': jumlahKata,
      'tanggalMasuk': tanggalMasuk.toIso8601String(),
      'urlSampul': urlSampul,
      'urlFile': urlFile,
      'isbn': isbn,
      'bukuInfo': bukuInfo?.toJson(),
      'metadata': metadata,
      'tagKeyword': tagKeyword,
      'daftarBab': daftarBab.map((e) => e.toJson()).toList(),
      'feedbacks': feedbacks.map((e) => e.toJson()).toList(),
      'riwayatReview': riwayatReview?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model untuk Info Buku
class BukuInfo {
  final String judul;
  final String penulis;
  final String kategori;
  final String genre;
  final String? subJudul;
  final String? urlSampul;

  BukuInfo({
    required this.judul,
    required this.penulis,
    required this.kategori,
    required this.genre,
    this.subJudul,
    this.urlSampul,
  });

  factory BukuInfo.fromJson(Map<String, dynamic> json) {
    return BukuInfo(
      judul: json['judul'] ?? '',
      penulis: json['penulis'] ?? '',
      kategori: json['kategori'] ?? '',
      genre: json['genre'] ?? '',
      subJudul: json['subJudul'],
      urlSampul: json['urlSampul'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'penulis': penulis,
      'kategori': kategori,
      'genre': genre,
      'subJudul': subJudul,
      'urlSampul': urlSampul,
    };
  }
}

/// Model untuk Bab Buku
class BabBuku {
  final String id;
  final String judul;
  final int nomor;
  final int jumlahHalaman;

  BabBuku({
    required this.id,
    required this.judul,
    required this.nomor,
    required this.jumlahHalaman,
  });

  factory BabBuku.fromJson(Map<String, dynamic> json) {
    return BabBuku(
      id: json['id'] ?? '',
      judul: json['judul'] ?? '',
      nomor: json['nomor'] ?? 0,
      jumlahHalaman: json['jumlahHalaman'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'nomor': nomor,
      'jumlahHalaman': jumlahHalaman,
    };
  }
}

/// Model untuk Review Feedback
class ReviewFeedback {
  final String id;
  final String komentar;
  final String? bab;
  final int? halaman;
  final int? skor;
  final DateTime tanggal;

  ReviewFeedback({
    required this.id,
    required this.komentar,
    this.bab,
    this.halaman,
    this.skor,
    required this.tanggal,
  });

  factory ReviewFeedback.fromJson(Map<String, dynamic> json) {
    return ReviewFeedback(
      id: json['id'] ?? '',
      komentar: json['komentar'] ?? json['isiKomentar'] ?? '',
      bab: json['bab'],
      halaman: json['halaman'],
      skor: json['skor'], // skor tidak ada di backend, untuk UI compatibility
      tanggal: DateTime.tryParse(json['dibuatPada'] ?? json['tanggal'] ?? '') ?? DateTime.now(),
    );
  }

  factory ReviewFeedback.fromFeedbackReview(FeedbackReview feedback) {
    return ReviewFeedback(
      id: feedback.id,
      komentar: feedback.komentar,
      bab: feedback.bab,
      halaman: feedback.halaman,
      skor: null, // Backend tidak support skor
      tanggal: feedback.dibuatPada,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'komentar': komentar,
      'bab': bab,
      'halaman': halaman,
      'skor': skor,
      'tanggal': tanggal.toIso8601String(),
    };
  }
}

/// Response untuk buku masuk
class BukuMasukResponse {
  final bool sukses;
  final String pesan;
  final List<BukuMasukReview>? data;
  final Map<String, dynamic>? metadata;

  BukuMasukResponse({
    required this.sukses,
    required this.pesan,
    this.data,
    this.metadata,
  });

  factory BukuMasukResponse.success(List<BukuMasukReview> data, {Map<String, dynamic>? metadata}) {
    return BukuMasukResponse(
      sukses: true, 
      pesan: 'Berhasil', 
      data: data,
      metadata: metadata,
    );
  }

  factory BukuMasukResponse.error(String pesan) {
    return BukuMasukResponse(sukses: false, pesan: pesan);
  }
}

/// Response untuk detail buku
class DetailBukuResponse {
  final bool sukses;
  final String pesan;
  final DetailBukuReview? data;

  DetailBukuResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory DetailBukuResponse.success(DetailBukuReview data) {
    return DetailBukuResponse(sukses: true, pesan: 'Berhasil', data: data);
  }

  factory DetailBukuResponse.error(String pesan) {
    return DetailBukuResponse(sukses: false, pesan: pesan);
  }
}

/// Response untuk action sederhana
class SimpleResponse {
  final bool sukses;
  final String pesan;

  SimpleResponse({
    required this.sukses,
    required this.pesan,
  });

  factory SimpleResponse.success(String pesan) {
    return SimpleResponse(sukses: true, pesan: pesan);
  }

  factory SimpleResponse.error(String pesan) {
    return SimpleResponse(sukses: false, pesan: pesan);
  }
}

/// Response untuk list editor
class EditorListResponse {
  final bool sukses;
  final String pesan;
  final List<EditorOption>? data;

  EditorListResponse({
    required this.sukses,
    required this.pesan,
    this.data,
  });

  factory EditorListResponse.success(List<EditorOption> data) {
    return EditorListResponse(sukses: true, pesan: 'Berhasil', data: data);
  }

  factory EditorListResponse.error(String pesan) {
    return EditorListResponse(sukses: false, pesan: pesan);
  }
}

/// Model untuk Input Review dari halaman
class InputReview {
  final String idBuku;
  final String catatan;
  final String rekomendasi;
  final List<String> feedback;
  final int rating;

  InputReview({
    required this.idBuku,
    required this.catatan,
    required this.rekomendasi,
    this.feedback = const [],
    this.rating = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      'idBuku': idBuku,
      'catatan': catatan,
      'rekomendasi': rekomendasi,
      'feedback': feedback,
      'rating': rating,
    };
  }
}

/// DTO untuk Submit Review
class SubmitReviewDto {
  final String idReview;
  final String rekomendasi;
  final String catatan;
  final int? rating;
  final String? feedback;

  SubmitReviewDto({
    required this.idReview,
    required this.rekomendasi,
    required this.catatan,
    this.rating,
    this.feedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'idReview': idReview,
      'rekomendasi': rekomendasi,
      'catatan': catatan,
      'rating': rating,
      'feedback': feedback,
    };
  }
}
