class PrintItem {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String status;
  final DateTime lastModified;
  final int? pageCount;
  final String? genre;
  final String? publisher;

  PrintItem({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.status,
    required this.lastModified,
    this.pageCount,
    this.genre,
    this.publisher,
  });

  // Dummy data for testing
  static List<PrintItem> getDummyData() {
    return [
      PrintItem(
        id: '1',
        title: 'Laskar Pelangi',
        author: 'Andrea Hirata',
        imageUrl: 'https://picsum.photos/seed/book1/200/300',
        status: 'Selesai Cetak',
        lastModified: DateTime.now().subtract(const Duration(days: 2)),
        pageCount: 534,
        genre: 'Novel',
        publisher: 'Bentang Pustaka',
      ),
      PrintItem(
        id: '2',
        title: 'Bumi Manusia',
        author: 'Pramoedya Ananta Toer',
        imageUrl: 'https://picsum.photos/seed/book2/200/300',
        status: 'Dalam Proses',
        lastModified: DateTime.now().subtract(const Duration(hours: 5)),
        pageCount: 535,
        genre: 'Novel Sejarah',
        publisher: 'Hasta Mitra',
      ),
      PrintItem(
        id: '3',
        title: 'Negeri 5 Menara',
        author: 'Ahmad Fuadi',
        imageUrl: 'https://picsum.photos/seed/book3/200/300',
        status: 'Menunggu Konfirmasi',
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
        pageCount: 424,
        genre: 'Novel',
        publisher: 'Gramedia Pustaka Utama',
      ),
      PrintItem(
        id: '4',
        title: 'Sang Pemimpi',
        author: 'Andrea Hirata',
        imageUrl: 'https://picsum.photos/seed/book4/200/300',
        status: 'Selesai Cetak',
        lastModified: DateTime.now().subtract(const Duration(days: 7)),
        pageCount: 296,
        genre: 'Novel',
        publisher: 'Bentang Pustaka',
      ),
      PrintItem(
        id: '5',
        title: 'Perahu Kertas',
        author: 'Dee Lestari',
        imageUrl: 'https://picsum.photos/seed/book5/200/300',
        status: 'Dalam Proses',
        lastModified: DateTime.now().subtract(const Duration(hours: 12)),
        pageCount: 444,
        genre: 'Novel Roman',
        publisher: 'Bentang Pustaka',
      ),
      PrintItem(
        id: '6',
        title: 'Cantik Itu Luka',
        author: 'Eka Kurniawan',
        imageUrl: 'https://picsum.photos/seed/book6/200/300',
        status: 'Selesai Cetak',
        lastModified: DateTime.now().subtract(const Duration(days: 14)),
        pageCount: 520,
        genre: 'Novel',
        publisher: 'Gramedia Pustaka Utama',
      ),
    ];
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(lastModified);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${lastModified.day} ${months[lastModified.month - 1]} ${lastModified.year}';
    }
  }
}
