// Model untuk Buku
class Book {
  final String id;
  final String title;
  final String author;
  final String? imageUrl;
  final String status; // draft, revisi, cetak, publish
  final DateTime? lastModified;
  final int? pageCount;
  final String? description;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.imageUrl,
    required this.status,
    this.lastModified,
    this.pageCount,
    this.description,
  });

  // Dummy data generator
  static List<Book> getDummyBooks() {
    return [
      Book(
        id: '1',
        title: 'Buku 1',
        author: 'Penulis A',
        status: 'draft',
        lastModified: DateTime.now().subtract(const Duration(days: 2)),
        pageCount: 120,
        description: 'Deskripsi buku 1',
      ),
      Book(
        id: '2',
        title: 'Buku 2',
        author: 'Penulis B',
        status: 'revisi',
        lastModified: DateTime.now().subtract(const Duration(days: 5)),
        pageCount: 85,
        description: 'Deskripsi buku 2',
      ),
      Book(
        id: '3',
        title: 'Buku 3',
        author: 'Penulis C',
        status: 'cetak',
        lastModified: DateTime.now().subtract(const Duration(days: 10)),
        pageCount: 200,
        description: 'Deskripsi buku 3',
      ),
      Book(
        id: '4',
        title: 'Buku 4',
        author: 'Penulis D',
        status: 'publish',
        lastModified: DateTime.now().subtract(const Duration(days: 15)),
        pageCount: 150,
        description: 'Deskripsi buku 4',
      ),
      Book(
        id: '5',
        title: 'Buku 5',
        author: 'Penulis E',
        status: 'draft',
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
        pageCount: 45,
        description: 'Deskripsi buku 5',
      ),
      Book(
        id: '6',
        title: 'Buku 6',
        author: 'Penulis F',
        status: 'revisi',
        lastModified: DateTime.now().subtract(const Duration(days: 3)),
        pageCount: 95,
        description: 'Deskripsi buku 6',
      ),
    ];
  }

  // Get count by status
  static Map<String, int> getStatusCount(List<Book> books) {
    return {
      'draft': books.where((b) => b.status == 'draft').length,
      'revisi': books.where((b) => b.status == 'revisi').length,
      'cetak': books.where((b) => b.status == 'cetak').length,
      'publish': books.where((b) => b.status == 'publish').length,
    };
  }
}
