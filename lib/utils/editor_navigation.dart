import 'package:flutter/material.dart';

/// Konfigurasi navigasi untuk Editor
/// Mengatur routing dan navigasi antar halaman editor
class EditorNavigation {
  
  /// Navigate ke halaman review naskah
  static void toReviewNaskah(BuildContext context) {
    Navigator.pushNamed(context, '/editor/review-naskah');
  }

  /// Navigate ke detail review naskah dengan ID
  static void toDetailReviewNaskah(BuildContext context, String naskahId) {
    Navigator.pushNamed(
      context,
      '/editor/detail-review-naskah',
      arguments: {'naskahId': naskahId},
    );
  }

  /// Navigate ke halaman review collection (existing)
  static void toReviewCollection(BuildContext context) {
    Navigator.pushNamed(context, '/editor/reviews');
  }

  /// Navigate ke halaman naskah masuk
  static void toNaskahMasuk(BuildContext context) {
    Navigator.pushNamed(context, '/editor/naskah-masuk');
  }

  /// Navigate ke halaman feedback editor
  static void toFeedback(BuildContext context) {
    Navigator.pushNamed(context, '/editor/feedback');
  }

  /// Navigate ke halaman statistik editor
  static void toStatistics(BuildContext context) {
    Navigator.pushNamed(context, '/editor/statistics');
  }

  /// Navigate ke halaman notifikasi editor
  static void toNotifications(BuildContext context) {
    Navigator.pushNamed(context, '/editor/notifications');
  }

  /// Navigate ke halaman profile editor
  static void toProfile(BuildContext context) {
    Navigator.pushNamed(context, '/editor/profile');
  }

  /// Navigate dengan bottom navigation index
  static void toEditorMainPage(BuildContext context, {int initialIndex = 0}) {
    Navigator.pushReplacementNamed(
      context,
      '/dashboard/editor',
    );
  }
}

/// Konstanta untuk Editor Navigation
class EditorRoutes {
  static const String main = '/dashboard/editor';
  static const String reviewNaskah = '/editor/review-naskah';
  static const String detailReviewNaskah = '/editor/detail-review-naskah';
  static const String reviewCollection = '/editor/reviews';
  static const String feedback = '/editor/feedback';
  static const String statistics = '/editor/statistics';
  static const String notifications = '/editor/notifications';
  static const String profile = '/editor/profile';
}

/// Helper untuk mendapatkan badge counts
class EditorBadges {
  
  /// Get notification badge count
  static Future<int> getNotificationBadge() async {
    // TODO: Implement real notification count from API
    return 3;
  }

  /// Get review badge count
  static Future<int> getReviewBadge() async {
    // TODO: Implement real review count from API
    return 5;
  }

  /// Get pending review count
  static Future<int> getPendingReviewCount() async {
    // TODO: Implement real pending review count from API
    return 2;
  }
}