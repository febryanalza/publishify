// Model untuk Statistik
class Statistics {
  final List<ChartData> salesData;
  final List<Comment> comments;
  final List<Rating> ratings;
  final double averageRating;

  Statistics({
    required this.salesData,
    required this.comments,
    required this.ratings,
    required this.averageRating,
  });
}

// Model untuk Chart Data
class ChartData {
  final String label; // Jan, Feb, Mar, etc
  final double value;
  final DateTime date;

  ChartData({
    required this.label,
    required this.value,
    required this.date,
  });
}

// Model untuk Comment/Review
class Comment {
  final String id;
  final String userName;
  final String comment;
  final double rating;
  final DateTime date;
  final String? userAvatar;

  Comment({
    required this.id,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
    this.userAvatar,
  });
}

// Model untuk Rating Distribution
class Rating {
  final int stars; // 1-5
  final int count;
  final double percentage;

  Rating({
    required this.stars,
    required this.count,
    required this.percentage,
  });
}
