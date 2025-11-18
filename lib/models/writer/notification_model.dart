// Model untuk Notifikasi
class NotificationModel {
  final String id;
  final String sender;
  final String subject;
  final String message;
  final DateTime date;
  final bool isRead;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.sender,
    required this.subject,
    required this.message,
    required this.date,
    this.isRead = false,
    required this.type,
  });

  // Copy with untuk mark as read
  NotificationModel copyWith({
    String? id,
    String? sender,
    String? subject,
    String? message,
    DateTime? date,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

// Tipe notifikasi
enum NotificationType {
  sms,        // SMS/Message
  email,      // Email
  system,     // System notification
  comment,    // New comment
  review,     // New review
  update,     // Update/News
}
