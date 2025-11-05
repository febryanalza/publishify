// Model untuk Submit Buku Baru
class BookSubmission {
  final String title;
  final String authorName;
  final String publishYear;
  final String isbn;
  final String category;
  final String genre;
  final String synopsis;
  final String? filePath;

  BookSubmission({
    required this.title,
    required this.authorName,
    required this.publishYear,
    required this.isbn,
    required this.category,
    required this.genre,
    required this.synopsis,
    this.filePath,
  });

  BookSubmission copyWith({
    String? title,
    String? authorName,
    String? publishYear,
    String? isbn,
    String? category,
    String? genre,
    String? synopsis,
    String? filePath,
  }) {
    return BookSubmission(
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      publishYear: publishYear ?? this.publishYear,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      genre: genre ?? this.genre,
      synopsis: synopsis ?? this.synopsis,
      filePath: filePath ?? this.filePath,
    );
  }
}
