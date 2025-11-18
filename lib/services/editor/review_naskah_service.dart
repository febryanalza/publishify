/// Service untuk mengelola review naskah editor
/// File ini berisi data dummy dan fungsi-fungsi untuk sistem review naskah
/// TODO: Ganti dengan API call yang sesungguhnya ketika backend sudah siap

import 'package:publishify/models/editor/review_naskah_models.dart';

class ReviewNaskahService {
  /// TODO: Ganti dengan endpoint API yang sesungguhnya
  /// Endpoint: GET /api/editor/submissions?status={status}&page={page}&limit={limit}
  static Future<ReviewNaskahResponse<List<NaskahSubmission>>> getNaskahSubmissions({
    String? status,
    int halaman = 1,
    int limit = 20,
  }) async {
    // Simulasi delay API
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Data dummy - ganti dengan API call
      final List<NaskahSubmission> dummyData = _generateDummySubmissions();
      
      // Filter berdasarkan status jika ada
      List<NaskahSubmission> filteredData = dummyData;
      if (status != null && status != 'semua') {
        filteredData = dummyData.where((item) => item.status == status).toList();
      }

      // Pagination simulation
      final startIndex = (halaman - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedData = filteredData.length > startIndex
          ? filteredData.sublist(
              startIndex, 
              endIndex > filteredData.length ? filteredData.length : endIndex
            )
          : <NaskahSubmission>[];

      return ReviewNaskahResponse<List<NaskahSubmission>>(
        sukses: true,
        pesan: 'Data berhasil diambil',
        data: paginatedData,
        metadata: {
          'total': filteredData.length,
          'halaman': halaman,
          'limit': limit,
          'total_halaman': (filteredData.length / limit).ceil(),
        },
      );
    } catch (e) {
      return ReviewNaskahResponse<List<NaskahSubmission>>(
        sukses: false,
        pesan: 'Gagal mengambil data: ${e.toString()}',
      );
    }
  }

  /// TODO: Ganti dengan endpoint API yang sesungguhnya
  /// Endpoint: GET /api/editor/submissions/{id}
  static Future<ReviewNaskahResponse<DetailNaskahSubmission>> getDetailNaskah(String id) async {
    // Simulasi delay API
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      // Cari naskah berdasarkan ID
      final naskah = _generateDummySubmissions().firstWhere(
        (item) => item.id == id,
        orElse: () => throw Exception('Naskah tidak ditemukan'),
      );

      // Generate detail dengan riwayat dan komentar
      final detail = DetailNaskahSubmission(
        naskah: naskah,
        riwayatReview: _generateDummyRiwayat(id),
        komentar: _generateDummyKomentar(id),
        metadata: {
          'total_download': 15,
          'rata_rata_rating': 4.2,
          'estimasi_review': '3-5 hari kerja',
        },
      );

      return ReviewNaskahResponse<DetailNaskahSubmission>(
        sukses: true,
        pesan: 'Detail naskah berhasil diambil',
        data: detail,
      );
    } catch (e) {
      return ReviewNaskahResponse<DetailNaskahSubmission>(
        sukses: false,
        pesan: 'Gagal mengambil detail: ${e.toString()}',
      );
    }
  }

  /// TODO: Ganti dengan endpoint API yang sesungguhnya
  /// Endpoint: POST /api/editor/submissions/{id}/accept
  static Future<ReviewNaskahResponse<String>> terimaReview(String idNaskah, String idEditor) async {
    // Simulasi delay API
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Simulasi proses terima review
      // Di sini akan ada logic untuk update status naskah dan assign editor
      
      return const ReviewNaskahResponse<String>(
        sukses: true,
        pesan: 'Review berhasil diterima dan Anda telah ditugaskan sebagai editor',
        data: 'accepted',
      );
    } catch (e) {
      return ReviewNaskahResponse<String>(
        sukses: false,
        pesan: 'Gagal menerima review: ${e.toString()}',
      );
    }
  }

  /// TODO: Ganti dengan endpoint API yang sesungguhnya
  /// Endpoint: GET /api/editor/available-editors
  static Future<ReviewNaskahResponse<List<EditorTersedia>>> getEditorTersedia() async {
    // Simulasi delay API
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final List<EditorTersedia> dummyEditors = _generateDummyEditors();

      return ReviewNaskahResponse<List<EditorTersedia>>(
        sukses: true,
        pesan: 'Daftar editor berhasil diambil',
        data: dummyEditors,
      );
    } catch (e) {
      return ReviewNaskahResponse<List<EditorTersedia>>(
        sukses: false,
        pesan: 'Gagal mengambil daftar editor: ${e.toString()}',
      );
    }
  }

  /// TODO: Ganti dengan endpoint API yang sesungguhnya
  /// Endpoint: POST /api/editor/submissions/{id}/assign
  static Future<ReviewNaskahResponse<String>> tugaskanEditor(
    String idNaskah,
    String idEditor,
    String alasan,
  ) async {
    // Simulasi delay API
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      // Simulasi proses penugasan editor
      final editor = _generateDummyEditors().firstWhere(
        (e) => e.id == idEditor,
        orElse: () => throw Exception('Editor tidak ditemukan'),
      );

      return ReviewNaskahResponse<String>(
        sukses: true,
        pesan: 'Naskah berhasil ditugaskan kepada ${editor.nama}',
        data: 'assigned',
      );
    } catch (e) {
      return ReviewNaskahResponse<String>(
        sukses: false,
        pesan: 'Gagal menugaskan editor: ${e.toString()}',
      );
    }
  }

  // ============ DATA DUMMY GENERATORS ============
  // TODO: Hapus semua fungsi _generate* ini ketika sudah menggunakan API

  static List<NaskahSubmission> _generateDummySubmissions() {
    return [
      NaskahSubmission(
        id: 'naskah_001',
        judul: 'Cahaya di Ujung Lorong',
        subJudul: 'Sebuah Perjalanan Spiritual',
        sinopsis: 'Sebuah novel yang mengisahkan perjalanan seorang pemuda dalam mencari makna hidup di tengah hiruk pikuk kehidupan modern. Dengan latar belakang kota besar yang penuh tantangan, protagonist harus menghadapi berbagai konflik internal dan eksternal.',
        namaPenulis: 'Ahmad Fauzi Rahman',
        emailPenulis: 'ahmad.fauzi@email.com',
        kategori: 'Fiksi',
        genre: 'Drama',
        jumlahHalaman: 285,
        jumlahKata: 95000,
        bahasaTulis: 'Indonesia',
        urlSampul: 'https://picsum.photos/300/400?random=1',
        urlFile: 'https://example.com/naskah_001.pdf',
        status: 'menunggu_review',
        prioritas: 'tinggi',
        tanggalSubmit: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NaskahSubmission(
        id: 'naskah_002',
        judul: 'Resep Nenek untuk Dunia Modern',
        sinopsis: 'Kumpulan resep tradisional yang telah dimodifikasi untuk kehidupan modern. Buku ini menghadirkan cita rasa authentik dengan teknik memasak yang lebih praktis dan efisien.',
        namaPenulis: 'Siti Nurhaliza',
        emailPenulis: 'siti.nurhaliza@email.com',
        kategori: 'Non-Fiksi',
        genre: 'Kuliner',
        jumlahHalaman: 150,
        jumlahKata: 45000,
        bahasaTulis: 'Indonesia',
        urlSampul: 'https://picsum.photos/300/400?random=2',
        urlFile: 'https://example.com/naskah_002.pdf',
        status: 'dalam_review',
        idEditorDitugaskan: 'editor_002',
        namaEditorDitugaskan: 'Dr. Maya Kusuma',
        prioritas: 'sedang',
        tanggalSubmit: DateTime.now().subtract(const Duration(days: 5)),
        tanggalDitugaskan: DateTime.now().subtract(const Duration(days: 3)),
      ),
      NaskahSubmission(
        id: 'naskah_003',
        judul: 'Petualangan Digital',
        subJudul: 'Memahami Era Teknologi 4.0',
        sinopsis: 'Panduan komprehensif untuk memahami dan beradaptasi dengan perkembangan teknologi digital. Buku ini cocok untuk pembaca yang ingin memahami impact teknologi dalam kehidupan sehari-hari.',
        namaPenulis: 'Budi Santoso',
        emailPenulis: 'budi.santoso@email.com',
        kategori: 'Non-Fiksi',
        genre: 'Teknologi',
        jumlahHalaman: 320,
        jumlahKata: 110000,
        bahasaTulis: 'Indonesia',
        urlSampul: 'https://picsum.photos/300/400?random=3',
        urlFile: 'https://example.com/naskah_003.pdf',
        status: 'menunggu_review',
        prioritas: 'urgent',
        tanggalSubmit: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      NaskahSubmission(
        id: 'naskah_004',
        judul: 'Jejak Langkah di Nusantara',
        sinopsis: 'Catatan perjalanan seorang backpacker yang menjelajahi keindahan Indonesia dari Sabang sampai Merauke. Dilengkapi dengan foto dan tips traveling untuk budget terbatas.',
        namaPenulis: 'Rina Melati',
        emailPenulis: 'rina.melati@email.com',
        kategori: 'Non-Fiksi',
        genre: 'Travel',
        jumlahHalaman: 200,
        jumlahKata: 68000,
        bahasaTulis: 'Indonesia',
        urlSampul: 'https://picsum.photos/300/400?random=4',
        urlFile: 'https://example.com/naskah_004.pdf',
        status: 'selesai_review',
        idEditorDitugaskan: 'editor_001',
        namaEditorDitugaskan: 'Prof. Indra Wijaya',
        prioritas: 'sedang',
        tanggalSubmit: DateTime.now().subtract(const Duration(days: 12)),
        tanggalDitugaskan: DateTime.now().subtract(const Duration(days: 10)),
      ),
      NaskahSubmission(
        id: 'naskah_005',
        judul: 'Mimpi-Mimpi Kecil',
        sinopsis: 'Kumpulan cerpen tentang kehidupan anak-anak di kampung yang penuh dengan imaginasi dan kepolosan. Setiap cerita mengandung pesan moral yang mendalam.',
        namaPenulis: 'Dewi Lestari',
        emailPenulis: 'dewi.lestari@email.com',
        kategori: 'Fiksi',
        genre: 'Cerpen',
        jumlahHalaman: 180,
        jumlahKata: 52000,
        bahasaTulis: 'Indonesia',
        urlSampul: 'https://picsum.photos/300/400?random=5',
        urlFile: 'https://example.com/naskah_005.pdf',
        status: 'menunggu_review',
        prioritas: 'rendah',
        tanggalSubmit: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<RiwayatReview> _generateDummyRiwayat(String idNaskah) {
    return [
      RiwayatReview(
        id: 'riwayat_001',
        idNaskah: idNaskah,
        idEditor: 'editor_001',
        namaEditor: 'Prof. Indra Wijaya',
        aksi: 'ditugaskan',
        catatan: 'Naskah ditugaskan untuk review awal',
        tanggal: DateTime.now().subtract(const Duration(days: 3)),
      ),
      RiwayatReview(
        id: 'riwayat_002',
        idNaskah: idNaskah,
        idEditor: 'editor_001',
        namaEditor: 'Prof. Indra Wijaya',
        aksi: 'diterima',
        catatan: 'Review diterima, mulai proses evaluasi',
        tanggal: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  static List<KomentarReview> _generateDummyKomentar(String idNaskah) {
    return [
      KomentarReview(
        id: 'komentar_001',
        idNaskah: idNaskah,
        idEditor: 'editor_001',
        namaEditor: 'Prof. Indra Wijaya',
        komentar: 'Naskah memiliki plot yang menarik, namun perlu perbaikan pada struktur kalimat di beberapa paragraf.',
        tipe: 'saran',
        tanggal: DateTime.now().subtract(const Duration(days: 1)),
      ),
      KomentarReview(
        id: 'komentar_002',
        idNaskah: idNaskah,
        idEditor: 'editor_001',
        namaEditor: 'Prof. Indra Wijaya',
        komentar: 'Pengembangan karakter protagonist sudah cukup baik, namun karakter pendukung masih perlu diperdalam.',
        tipe: 'catatan',
        tanggal: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  static List<EditorTersedia> _generateDummyEditors() {
    return [
      const EditorTersedia(
        id: 'editor_001',
        nama: 'Prof. Indra Wijaya',
        email: 'indra.wijaya@publishify.com',
        spesialisasi: 'Fiksi, Sastra',
        jumlahTugasAktif: 3,
        rating: 4.8,
        tersedia: true,
        urlFoto: 'https://i.pravatar.cc/150?img=1',
      ),
      const EditorTersedia(
        id: 'editor_002',
        nama: 'Dr. Maya Kusuma',
        email: 'maya.kusuma@publishify.com',
        spesialisasi: 'Non-Fiksi, Kuliner',
        jumlahTugasAktif: 2,
        rating: 4.9,
        tersedia: true,
        urlFoto: 'https://i.pravatar.cc/150?img=2',
      ),
      const EditorTersedia(
        id: 'editor_003',
        nama: 'Drs. Ahmad Basuki',
        email: 'ahmad.basuki@publishify.com',
        spesialisasi: 'Teknologi, Sains',
        jumlahTugasAktif: 5,
        rating: 4.6,
        tersedia: false,
        urlFoto: 'https://i.pravatar.cc/150?img=3',
      ),
      const EditorTersedia(
        id: 'editor_004',
        nama: 'Dra. Sari Dewanti',
        email: 'sari.dewanti@publishify.com',
        spesialisasi: 'Travel, Lifestyle',
        jumlahTugasAktif: 1,
        rating: 4.7,
        tersedia: true,
        urlFoto: 'https://i.pravatar.cc/150?img=4',
      ),
      const EditorTersedia(
        id: 'editor_005',
        nama: 'Dr. Rudi Hartono',
        email: 'rudi.hartono@publishify.com',
        spesialisasi: 'Sejarah, Budaya',
        jumlahTugasAktif: 2,
        rating: 4.5,
        tersedia: true,
        urlFoto: 'https://i.pravatar.cc/150?img=5',
      ),
    ];
  }

  /// Helper method untuk mendapatkan jumlah naskah berdasarkan status
  static Future<Map<String, int>> getStatusCount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final submissions = _generateDummySubmissions();
    return {
      'semua': submissions.length,
      'menunggu_review': submissions.where((s) => s.status == 'menunggu_review').length,
      'dalam_review': submissions.where((s) => s.status == 'dalam_review').length,
      'selesai_review': submissions.where((s) => s.status == 'selesai_review').length,
    };
  }
}