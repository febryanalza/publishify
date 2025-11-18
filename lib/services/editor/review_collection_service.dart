import 'dart:async';
import 'package:publishify/models/editor/review_collection_models.dart';

/// Service untuk mengelola pengumpulan review
/// Menyediakan data dummy yang mudah diubah saat integrasi backend
class ReviewCollectionService {
  
  /// Ambil semua buku yang masuk untuk direview dengan filter
  static Future<ReviewCollectionResponse<List<BukuMasukReview>>> getBukuMasukReview({
    String filter = 'semua',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Simulasi network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // TODO: Replace dengan API call ke backend
      // final response = await http.get('/api/editor/review-collection?filter=$filter&page=$page&limit=$limit');
      
      final allBooks = _getDummyBooks();
      
      // Filter berdasarkan status
      List<BukuMasukReview> filteredBooks;
      if (filter == 'semua') {
        filteredBooks = allBooks;
      } else {
        filteredBooks = allBooks.where((book) => book.status == filter).toList();
      }

      // Sort by priority dan tanggal submit
      filteredBooks.sort((a, b) {
        // Prioritas tinggi dulu
        int priorityComparison = b.prioritas.compareTo(a.prioritas);
        if (priorityComparison != 0) return priorityComparison;
        
        // Kemudian tanggal submit terbaru
        return b.tanggalSubmit.compareTo(a.tanggalSubmit);
      });

      return ReviewCollectionResponse<List<BukuMasukReview>>(
        sukses: true,
        pesan: 'Data berhasil dimuat',
        data: filteredBooks,
        metadata: {
          'total': filteredBooks.length,
          'page': page,
          'limit': limit,
          'filters': _getFilterCounts(allBooks),
        },
      );

    } catch (e) {
      return ReviewCollectionResponse<List<BukuMasukReview>>(
        sukses: false,
        pesan: 'Gagal memuat data: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Ambil detail buku untuk review
  static Future<ReviewCollectionResponse<DetailBukuReview>> getDetailBuku(String idBuku) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Replace dengan API call
      // final response = await http.get('/api/editor/review-collection/$idBuku');
      
      final allBooks = _getDummyBooks();
      final book = allBooks.firstWhere((b) => b.id == idBuku);
      
      final detail = DetailBukuReview(
        bukuInfo: book,
        riwayatReview: _getDummyRiwayatReview(idBuku),
        fileContent: null, // Bisa diisi jika ada preview
        tagKeyword: _getDummyKeywords(book.genre),
        metadata: {
          'readingTime': '${(book.jumlahKata / 200).ceil()} menit',
          'complexity': book.jumlahKata > 50000 ? 'Tinggi' : book.jumlahKata > 20000 ? 'Sedang' : 'Rendah',
          'estimatedReviewTime': '${(book.jumlahHalaman * 2)} menit',
        },
      );

      return ReviewCollectionResponse<DetailBukuReview>(
        sukses: true,
        pesan: 'Detail buku berhasil dimuat',
        data: detail,
      );

    } catch (e) {
      return ReviewCollectionResponse<DetailBukuReview>(
        sukses: false,
        pesan: 'Gagal memuat detail buku: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Terima buku untuk direview
  static Future<ReviewCollectionResponse<bool>> terimaBuku(String idBuku) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // TODO: Replace dengan API call
      // final response = await http.post('/api/editor/review-collection/$idBuku/accept');

      return const ReviewCollectionResponse<bool>(
        sukses: true,
        pesan: 'Buku berhasil diterima untuk direview',
        data: true,
      );

    } catch (e) {
      return ReviewCollectionResponse<bool>(
        sukses: false,
        pesan: 'Gagal menerima buku: ${e.toString()}',
        data: false,
      );
    }
  }

  /// Tugaskan editor lain
  static Future<ReviewCollectionResponse<bool>> tugaskanEditorLain(
    String idBuku, 
    String idEditor, 
    String alasan
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      // TODO: Replace dengan API call
      // final response = await http.post('/api/editor/review-collection/$idBuku/reassign', {
      //   'idEditor': idEditor,
      //   'alasan': alasan,
      // });

      return const ReviewCollectionResponse<bool>(
        sukses: true,
        pesan: 'Buku berhasil ditugaskan ke editor lain',
        data: true,
      );

    } catch (e) {
      return ReviewCollectionResponse<bool>(
        sukses: false,
        pesan: 'Gagal menugaskan editor: ${e.toString()}',
        data: false,
      );
    }
  }

  /// Submit review
  static Future<ReviewCollectionResponse<bool>> submitReview(InputReview review) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      // TODO: Replace dengan API call
      // final response = await http.post('/api/editor/review-collection/submit', review.toJson());

      return const ReviewCollectionResponse<bool>(
        sukses: true,
        pesan: 'Review berhasil disubmit',
        data: true,
      );

    } catch (e) {
      return ReviewCollectionResponse<bool>(
        sukses: false,
        pesan: 'Gagal submit review: ${e.toString()}',
        data: false,
      );
    }
  }

  /// Get available editors for reassignment
  static Future<ReviewCollectionResponse<List<EditorOption>>> getAvailableEditors() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // TODO: Replace dengan API call
      // final response = await http.get('/api/editor/available');

      final editors = [
        const EditorOption(
          id: 'editor_001',
          nama: 'Dr. Sarah Johnson',
          spesialisasi: ['Fiksi', 'Drama'],
          workload: 3,
          rating: 4.8,
        ),
        const EditorOption(
          id: 'editor_002',
          nama: 'Prof. Ahmad Rahman',
          spesialisasi: ['Non-Fiksi', 'Sejarah'],
          workload: 5,
          rating: 4.9,
        ),
        const EditorOption(
          id: 'editor_003',
          nama: 'Maria Santos',
          spesialisasi: ['Romance', 'Young Adult'],
          workload: 2,
          rating: 4.7,
        ),
      ];

      return ReviewCollectionResponse<List<EditorOption>>(
        sukses: true,
        pesan: 'Daftar editor tersedia',
        data: editors,
      );

    } catch (e) {
      return ReviewCollectionResponse<List<EditorOption>>(
        sukses: false,
        pesan: 'Gagal memuat daftar editor: ${e.toString()}',
        data: [],
      );
    }
  }

  // ====================================
  // PRIVATE HELPER METHODS - DUMMY DATA
  // ====================================

  static List<BukuMasukReview> _getDummyBooks() {
    return [
      BukuMasukReview(
        id: 'book_001',
        judul: 'Sang Penjaga Waktu',
        subJudul: 'Petualangan di Dimensi Paralel',
        sinopsis: 'Kisah seorang pemuda yang mendapat kemampuan untuk melintasi waktu dan harus menyelamatkan dunia dari kehancuran. Dengan kekuatan yang besar, datang tanggung jawab yang lebih besar.',
        namaPenulis: 'Rafi Pratama',
        kategori: 'Fiksi',
        genre: 'Fantasy',
        status: 'belum_ditugaskan',
        tanggalSubmit: DateTime.now().subtract(const Duration(days: 2)),
        deadlineReview: DateTime.now().add(const Duration(days: 5)),
        urlSampul: 'https://via.placeholder.com/150x200',
        urlFile: 'manuscript_001.pdf',
        jumlahHalaman: 320,
        jumlahKata: 85000,
        prioritas: 3,
      ),
      BukuMasukReview(
        id: 'book_002',
        judul: 'Bisnis Digital Era Modern',
        subJudul: 'Strategi Sukses di Dunia Maya',
        sinopsis: 'Panduan lengkap memulai dan mengembangkan bisnis digital dari nol hingga sukses. Dilengkapi dengan studi kasus dan tips praktis yang telah terbukti.',
        namaPenulis: 'Sari Indrawati',
        kategori: 'Non-Fiksi',
        genre: 'Bisnis',
        status: 'ditugaskan',
        tanggalSubmit: DateTime.now().subtract(const Duration(days: 5)),
        deadlineReview: DateTime.now().add(const Duration(days: 3)),
        urlSampul: 'https://via.placeholder.com/150x200',
        urlFile: 'manuscript_002.pdf',
        jumlahHalaman: 250,
        jumlahKata: 55000,
        editorYangDitugaskan: 'Dr. Sarah Johnson',
        prioritas: 2,
      ),
      BukuMasukReview(
        id: 'book_003',
        judul: 'Cinta di Ujung Senja',
        subJudul: 'Novel Romance Terbaik Tahun Ini',
        sinopsis: 'Kisah cinta yang mengharukan antara dua jiwa yang saling mencari dalam kegelapan hidup. Sebuah novel yang akan membuat pembaca menangis dan tersenyum bersamaan.',
        namaPenulis: 'Maya Anggraini',
        kategori: 'Fiksi',
        genre: 'Romance',
        status: 'dalam_review',
        tanggalSubmit: DateTime.now().subtract(const Duration(days: 8)),
        deadlineReview: DateTime.now().add(const Duration(days: 1)),
        urlSampul: 'https://via.placeholder.com/150x200',
        urlFile: 'manuscript_003.pdf',
        jumlahHalaman: 280,
        jumlahKata: 72000,
        editorYangDitugaskan: 'Maria Santos',
        prioritas: 1,
      ),
      BukuMasukReview(
        id: 'book_004',
        judul: 'Algoritma Pembelajaran Mesin',
        subJudul: 'Teori dan Implementasi Praktis',
        sinopsis: 'Buku komprehensif tentang machine learning yang cocok untuk pemula hingga expert. Dijelaskan dengan bahasa yang mudah dipahami dan dilengkapi contoh kode.',
        namaPenulis: 'Dr. Budi Santoso',
        kategori: 'Non-Fiksi',
        genre: 'Teknologi',
        status: 'belum_ditugaskan',
        tanggalSubmit: DateTime.now().subtract(const Duration(days: 1)),
        deadlineReview: DateTime.now().add(const Duration(days: 7)),
        urlSampul: 'https://via.placeholder.com/150x200',
        urlFile: 'manuscript_004.pdf',
        jumlahHalaman: 450,
        jumlahKata: 120000,
        prioritas: 3,
      ),
      BukuMasukReview(
        id: 'book_005',
        judul: 'Sejarah Nusantara Modern',
        subJudul: 'Dari Kolonial hingga Digital',
        sinopsis: 'Penelusuran mendalam tentang perjalanan bangsa Indonesia dari masa kolonial hingga era digital. Dilengkapi dengan foto-foto bersejarah dan analisis mendalam.',
        namaPenulis: 'Prof. Indira Sari',
        kategori: 'Non-Fiksi',
        genre: 'Sejarah',
        status: 'selesai',
        tanggalSubmit: DateTime.now().subtract(const Duration(days: 15)),
        deadlineReview: DateTime.now().subtract(const Duration(days: 5)),
        urlSampul: 'https://via.placeholder.com/150x200',
        urlFile: 'manuscript_005.pdf',
        jumlahHalaman: 380,
        jumlahKata: 95000,
        editorYangDitugaskan: 'Prof. Ahmad Rahman',
        prioritas: 2,
      ),
    ];
  }

  static List<RiwayatReview> _getDummyRiwayatReview(String idBuku) {
    // Return different review history based on book ID
    if (idBuku == 'book_002') {
      return [
        RiwayatReview(
          id: 'review_001',
          namaEditor: 'Dr. Sarah Johnson',
          status: 'dalam_review',
          catatan: 'Sedang dalam proses review mendalam. Buku memiliki potensi yang bagus.',
          tanggal: DateTime.now().subtract(const Duration(days: 2)),
          rekomendasi: null,
        ),
      ];
    } else if (idBuku == 'book_003') {
      return [
        RiwayatReview(
          id: 'review_002',
          namaEditor: 'Maria Santos',
          status: 'dalam_review',
          catatan: 'Alur cerita menarik, karakterisasi kuat. Perlu sedikit perbaikan di bagian dialog.',
          tanggal: DateTime.now().subtract(const Duration(days: 3)),
          rekomendasi: null,
        ),
      ];
    } else if (idBuku == 'book_005') {
      return [
        RiwayatReview(
          id: 'review_003',
          namaEditor: 'Prof. Ahmad Rahman',
          status: 'selesai',
          catatan: 'Penelitian sangat solid, referensi lengkap. Siap untuk publikasi dengan revisi minor.',
          tanggal: DateTime.now().subtract(const Duration(days: 5)),
          rekomendasi: 'setujui',
        ),
      ];
    }
    return [];
  }

  static List<String> _getDummyKeywords(String genre) {
    switch (genre.toLowerCase()) {
      case 'fantasy':
        return ['Petualangan', 'Magie', 'Dimensi', 'Pahlawan', 'Quest'];
      case 'romance':
        return ['Cinta', 'Drama', 'Emosional', 'Hubungan', 'Konflik'];
      case 'bisnis':
        return ['Strategi', 'Digital', 'Marketing', 'Entrepreneurship', 'Inovasi'];
      case 'teknologi':
        return ['Algoritma', 'Programming', 'AI', 'Machine Learning', 'Data'];
      case 'sejarah':
        return ['Kronologi', 'Analisis', 'Dokumentasi', 'Budaya', 'Politik'];
      default:
        return ['Umum', 'Informatif', 'Edukatif'];
    }
  }

  static Map<String, int> _getFilterCounts(List<BukuMasukReview> books) {
    return {
      'semua': books.length,
      'belum_ditugaskan': books.where((b) => b.status == 'belum_ditugaskan').length,
      'ditugaskan': books.where((b) => b.status == 'ditugaskan').length,
      'dalam_review': books.where((b) => b.status == 'dalam_review').length,
      'selesai': books.where((b) => b.status == 'selesai').length,
    };
  }
}

/// Model untuk pilihan editor
class EditorOption {
  final String id;
  final String nama;
  final List<String> spesialisasi;
  final int workload; // Jumlah review yang sedang dikerjakan
  final double rating;

  const EditorOption({
    required this.id,
    required this.nama,
    required this.spesialisasi,
    required this.workload,
    required this.rating,
  });

  factory EditorOption.fromJson(Map<String, dynamic> json) {
    return EditorOption(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      spesialisasi: List<String>.from(json['spesialisasi'] ?? []),
      workload: json['workload'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }
}