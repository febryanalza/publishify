// Model untuk Submit Buku Baru
// Sesuai dengan backend DTO: BuatNaskahDto
class BookSubmission {
  final String title;          // judul (wajib, min 3, max 200)
  final String? subTitle;      // subJudul (optional, max 200)
  final String synopsis;       // sinopsis (wajib, min 50, max 2000)
  final String category;       // idKategori (wajib, UUID)
  final String genre;          // idGenre (wajib, UUID)
  final String? isbn;          // isbn (optional)
  final String? filePath;      // urlFile (optional)
  final String? coverPath;     // urlSampul (optional) - BARU
  final String? formatBuku;    // formatBuku (A4, A5, B5) - BARU
  final String? bahasaTulis;   // bahasaTulis (id, en, etc.) - BARU

  BookSubmission({
    required this.title,
    this.subTitle,
    required this.synopsis,
    required this.category,
    required this.genre,
    this.isbn,
    this.filePath,
    this.coverPath,
    this.formatBuku,
    this.bahasaTulis,
  });

  BookSubmission copyWith({
    String? title,
    String? subTitle,
    String? synopsis,
    String? category,
    String? genre,
    String? isbn,
    String? filePath,
    String? coverPath,
    String? formatBuku,
    String? bahasaTulis,
  }) {
    return BookSubmission(
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      synopsis: synopsis ?? this.synopsis,
      category: category ?? this.category,
      genre: genre ?? this.genre,
      isbn: isbn ?? this.isbn,
      filePath: filePath ?? this.filePath,
      coverPath: coverPath ?? this.coverPath,
      formatBuku: formatBuku ?? this.formatBuku,
      bahasaTulis: bahasaTulis ?? this.bahasaTulis,
    );
  }
}

