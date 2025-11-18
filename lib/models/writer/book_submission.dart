// Model untuk Submit Buku Baru
// Sesuai dengan backend DTO: BuatNaskahDto
class BookSubmission {
  final String title;          // judul (wajib, min 3, max 200)
  final String synopsis;       // sinopsis (wajib, min 50, max 2000)
  final String category;       // idKategori (wajib, UUID)
  final String genre;          // idGenre (wajib, UUID)
  final String? isbn;          // isbn (optional)
  final String? filePath;      // urlFile (optional)

  BookSubmission({
    required this.title,
    required this.synopsis,
    required this.category,
    required this.genre,
    this.isbn,
    this.filePath,
  });

  BookSubmission copyWith({
    String? title,
    String? synopsis,
    String? category,
    String? genre,
    String? isbn,
    String? filePath,
  }) {
    return BookSubmission(
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      category: category ?? this.category,
      genre: genre ?? this.genre,
      isbn: isbn ?? this.isbn,
      filePath: filePath ?? this.filePath,
    );
  }
}
