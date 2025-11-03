// Model untuk Revisi Buku
class Revision {
  final String id;
  final String bookTitle;
  final String bookId;
  final DateTime revisionDate;
  final RevisionStatus status;
  final int commentCount;

  Revision({
    required this.id,
    required this.bookTitle,
    required this.bookId,
    required this.revisionDate,
    required this.status,
    this.commentCount = 0,
  });
}

enum RevisionStatus {
  pending,    // Menunggu revisi
  inProgress, // Sedang direvisi
  completed,  // Revisi selesai
}

// Model untuk Detail Revisi (Komentar)
class RevisionComment {
  final String id;
  final String file;
  final String description;
  final String? attachmentPath;
  final String comment;
  final DateTime createdAt;

  RevisionComment({
    required this.id,
    required this.file,
    required this.description,
    this.attachmentPath,
    required this.comment,
    required this.createdAt,
  });
}
