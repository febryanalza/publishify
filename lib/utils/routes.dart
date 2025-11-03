import 'package:flutter/material.dart';
import 'package:publishify/pages/splash_screen.dart';
import 'package:publishify/pages/login_page.dart';
import 'package:publishify/pages/register_page.dart';
import 'package:publishify/pages/success_page.dart';
import 'package:publishify/pages/home/home_page.dart';
import 'package:publishify/pages/statistics/statistics_page.dart';
import 'package:publishify/pages/notifications/notifications_page.dart';
import 'package:publishify/pages/profile/profile_page.dart';
import 'package:publishify/pages/upload/upload_book_page.dart';
import 'package:publishify/pages/revision/revision_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String success = '/success';
  static const String home = '/home';
  static const String statistics = '/statistics';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String uploadBook = '/upload-book';
  static const String revisi = '/revisi';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      success: (context) => const SuccessPage(),
      home: (context) => const HomePage(),
      statistics: (context) => const StatisticsPage(),
      notifications: (context) => const NotificationsPage(),
      profile: (context) => const ProfilePage(),
      uploadBook: (context) => const UploadBookPage(),
      revisi: (context) => const RevisionPage(),
    };
  }
}

