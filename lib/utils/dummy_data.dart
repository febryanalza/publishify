import 'package:publishify/models/writer/book.dart';
import 'package:publishify/models/writer/statistics.dart';
import 'package:publishify/models/writer/notification_model.dart';
import 'package:publishify/models/writer/user_profile.dart';
import 'package:publishify/models/writer/revision.dart';

/// Dummy Data Manager
/// 
/// File ini berisi semua dummy data yang digunakan di aplikasi.
/// Ganti data di sini saat sudah memiliki data real dari API.
class DummyData {
  // User Data
  static const String defaultUserName = 'Salsabila';
  static const String defaultUserEmail = 'salsabila@publishify.com';
  static const String defaultUserRole = 'writer';

  // Books Data
  static List<Book> getBooks() {
    return [
      Book(
        id: '1',
        title: 'Buku 1',
        author: 'Penulis A',
        status: 'draft',
        lastModified: DateTime.now().subtract(const Duration(days: 2)),
        pageCount: 120,
        description: 'Deskripsi singkat tentang buku 1',
      ),
      Book(
        id: '2',
        title: 'Buku 2',
        author: 'Penulis B',
        status: 'revisi',
        lastModified: DateTime.now().subtract(const Duration(days: 5)),
        pageCount: 85,
        description: 'Deskripsi singkat tentang buku 2',
      ),
      Book(
        id: '3',
        title: 'Buku 3',
        author: 'Penulis C',
        status: 'cetak',
        lastModified: DateTime.now().subtract(const Duration(days: 10)),
        pageCount: 200,
        description: 'Deskripsi singkat tentang buku 3',
      ),
      Book(
        id: '4',
        title: 'Buku 4',
        author: 'Penulis D',
        status: 'publish',
        lastModified: DateTime.now().subtract(const Duration(days: 15)),
        pageCount: 150,
        description: 'Deskripsi singkat tentang buku 4',
      ),
      Book(
        id: '5',
        title: 'Buku 5',
        author: 'Penulis E',
        status: 'draft',
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
        pageCount: 45,
        description: 'Deskripsi singkat tentang buku 5',
      ),
      Book(
        id: '6',
        title: 'Buku 6',
        author: 'Penulis F',
        status: 'revisi',
        lastModified: DateTime.now().subtract(const Duration(days: 3)),
        pageCount: 95,
        description: 'Deskripsi singkat tentang buku 6',
      ),
    ];
  }

  // Statistics
  static Map<String, int> getStatusCount() {
    final books = getBooks();
    return {
      'draft': books.where((b) => b.status == 'draft').length,
      'revisi': books.where((b) => b.status == 'revisi').length,
      'cetak': books.where((b) => b.status == 'cetak').length,
      'publish': books.where((b) => b.status == 'publish').length,
    };
  }

  // Notification count
  static int getNotificationCount() {
    return 1; // Dummy notification count
  }

  // Statistics Data
  static Statistics getStatistics() {
    return Statistics(
      salesData: _getSalesData(),
      comments: _getComments(),
      ratings: _getRatings(),
      averageRating: 4.2,
    );
  }

  static List<ChartData> _getSalesData() {
    final now = DateTime.now();
    return [
      ChartData(
        label: 'Jan',
        value: 15,
        date: DateTime(now.year, 1),
      ),
      ChartData(
        label: 'Feb',
        value: 25,
        date: DateTime(now.year, 2),
      ),
      ChartData(
        label: 'Mar',
        value: 20,
        date: DateTime(now.year, 3),
      ),
      ChartData(
        label: 'Apr',
        value: 30,
        date: DateTime(now.year, 4),
      ),
      ChartData(
        label: 'May',
        value: 35,
        date: DateTime(now.year, 5),
      ),
      ChartData(
        label: 'Jun',
        value: 45,
        date: DateTime(now.year, 6),
      ),
    ];
  }

  static List<Comment> _getComments() {
    return [
      Comment(
        id: '1',
        userName: 'User A',
        comment: 'Buku yang sangat bagus dan inspiratif!',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Comment(
        id: '2',
        userName: 'User B',
        comment: 'Ceritanya menarik, tapi ada beberapa typo.',
        rating: 4.0,
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Comment(
        id: '3',
        userName: 'User C',
        comment: 'Recommended untuk dibaca!',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Comment(
        id: '4',
        userName: 'User D',
        comment: 'Bagus, tapi ending kurang memuaskan.',
        rating: 3.0,
        date: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Comment(
        id: '5',
        userName: 'User E',
        comment: 'Luar biasa! Tidak sabar untuk sekuelnya.',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  static List<Rating> _getRatings() {
    return [
      Rating(stars: 5, count: 120, percentage: 0.6),
      Rating(stars: 4, count: 50, percentage: 0.25),
      Rating(stars: 3, count: 20, percentage: 0.1),
      Rating(stars: 2, count: 8, percentage: 0.04),
      Rating(stars: 1, count: 2, percentage: 0.01),
    ];
  }

  // Notifications Data
  static List<NotificationModel> getNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        sender: 'Editor A',
        subject: 'Revisi Buku Tersedia',
        message: 'Revisi untuk buku "Petualangan Seru" telah selesai. Silakan periksa hasil revisi dan berikan feedback.',
        date: now.subtract(const Duration(hours: 2)),
        isRead: false,
        type: NotificationType.sms,
      ),
      NotificationModel(
        id: '2',
        sender: 'System',
        subject: 'Update Aplikasi',
        message: 'Aplikasi Publishify telah diupdate ke versi 2.0. Nikmati fitur-fitur baru yang telah ditambahkan.',
        date: now.subtract(const Duration(hours: 5)),
        isRead: false,
        type: NotificationType.system,
      ),
      NotificationModel(
        id: '3',
        sender: 'User B',
        subject: 'Komentar Baru',
        message: 'User B memberikan komentar pada buku "Cerita Inspiratif": Buku yang sangat bagus dan menginspirasi!',
        date: now.subtract(const Duration(days: 1)),
        isRead: true,
        type: NotificationType.comment,
      ),
      NotificationModel(
        id: '4',
        sender: 'Editor C',
        subject: 'Undangan Kolaborasi',
        message: 'Editor C mengundang Anda untuk berkolaborasi dalam proyek buku antologi. Tertarik untuk bergabung?',
        date: now.subtract(const Duration(days: 2)),
        isRead: true,
        type: NotificationType.email,
      ),
      NotificationModel(
        id: '5',
        sender: 'Admin',
        subject: 'Verifikasi Akun',
        message: 'Selamat! Akun Anda telah terverifikasi. Sekarang Anda dapat mengakses semua fitur premium Publishify.',
        date: now.subtract(const Duration(days: 3)),
        isRead: true,
        type: NotificationType.system,
      ),
      NotificationModel(
        id: '6',
        sender: 'User D',
        subject: 'Review Baru',
        message: 'User D memberikan rating 5 bintang untuk buku "Novel Fantasi". Lihat review lengkapnya sekarang.',
        date: now.subtract(const Duration(days: 5)),
        isRead: true,
        type: NotificationType.review,
      ),
    ];
  }

  // Get unread notification count
  static int getUnreadNotificationCount() {
    final notifications = getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  // User Profile Data
  static UserProfile getUserProfile() {
    return UserProfile(
      id: '1',
      name: 'Salsabila Maulidia',
      role: 'Penulis',
      totalBooks: 49,
      totalRating: 49,
      totalViewers: 49,
      bio: 'Lorem Ipsum\nis simply dummy text of the printing and typesetting industry\nLinkedIn.com/SalsabilaM',
      linkedInUrl: 'https://linkedin.com/in/salsabilam',
      photoUrl: 'https://i.pravatar.cc/200?img=32', // Placeholder image
      portfolios: [
        Portfolio(
          id: '1',
          title: 'Buku 1',
          imageUrl: 'https://picsum.photos/200/300?random=1',
        ),
        Portfolio(
          id: '2',
          title: 'Buku 2',
          imageUrl: 'https://picsum.photos/200/300?random=2',
        ),
        Portfolio(
          id: '3',
          title: 'Buku 3',
          imageUrl: 'https://picsum.photos/200/300?random=3',
        ),
        Portfolio(
          id: '4',
          title: 'Buku 4',
          imageUrl: 'https://picsum.photos/200/300?random=4',
        ),
      ],
    );
  }

  // Revisions Data
  static List<Revision> getRevisions() {
    return [
      Revision(
        id: '1',
        bookTitle: 'Revisi 1',
        bookId: '1',
        revisionDate: DateTime.now().subtract(const Duration(days: 2)),
        status: RevisionStatus.completed,
        commentCount: 5,
      ),
      Revision(
        id: '2',
        bookTitle: 'Revisi 2',
        bookId: '2',
        revisionDate: DateTime.now().subtract(const Duration(days: 5)),
        status: RevisionStatus.completed,
        commentCount: 3,
      ),
      Revision(
        id: '3',
        bookTitle: 'Revisi 3',
        bookId: '3',
        revisionDate: DateTime.now().subtract(const Duration(days: 10)),
        status: RevisionStatus.completed,
        commentCount: 2,
      ),
      Revision(
        id: '4',
        bookTitle: 'Revisi 4',
        bookId: '4',
        revisionDate: DateTime.now().subtract(const Duration(days: 15)),
        status: RevisionStatus.inProgress,
        commentCount: 1,
      ),
    ];
  }

  // Revision Comments Data
  static List<RevisionComment> getRevisionComments(String revisionId) {
    return [
      RevisionComment(
        id: '1',
        file: 'File',
        description: 'Deskripsi',
        comment: 'Komentar',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      RevisionComment(
        id: '2',
        file: 'Bab 1 - Pendahuluan',
        description: 'Perlu diperbaiki struktur kalimat di paragraf pembuka',
        comment: 'Kalimat terlalu panjang dan sulit dipahami',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RevisionComment(
        id: '3',
        file: 'Bab 2 - Isi',
        description: 'Tambahkan referensi untuk data statistik',
        comment: 'Data perlu didukung dengan sumber yang valid',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  // TODO: Saat sudah ada API, ganti dengan:
  // 
  // Future<List<Book>> fetchBooks() async {
  //   final response = await http.get(Uri.parse('$baseUrl/books'));
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     return data.map((json) => Book.fromJson(json)).toList();
  //   }
  //   throw Exception('Failed to load books');
  // }
}
