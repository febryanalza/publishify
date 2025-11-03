// Model untuk User Profile
class UserProfile {
  final String id;
  final String name;
  final String role; // "Penulis" or "Editor"
  final int totalBooks;
  final int totalRating;
  final int totalViewers;
  final String bio;
  final String linkedInUrl;
  final String photoUrl;
  final List<Portfolio> portfolios;

  UserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.totalBooks,
    required this.totalRating,
    required this.totalViewers,
    required this.bio,
    required this.linkedInUrl,
    required this.photoUrl,
    required this.portfolios,
  });
}

class Portfolio {
  final String id;
  final String title;
  final String imageUrl;

  Portfolio({
    required this.id,
    required this.title,
    required this.imageUrl,
  });
}
