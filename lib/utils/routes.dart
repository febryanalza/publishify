import 'package:flutter/material.dart';
import 'package:publishify/pages/auth/splash_screen.dart';
import 'package:publishify/pages/auth/login_page.dart';
import 'package:publishify/pages/auth/register_page.dart';
import 'package:publishify/pages/auth/success_page.dart';
import 'package:publishify/pages/main_layout.dart';
import 'package:publishify/pages/upload/upload_book_page.dart';
import 'package:publishify/pages/review/review_page.dart';
import 'package:publishify/pages/print/print_page.dart';
import 'package:publishify/pages/percetakan/pilih_percetakan_page.dart';
import 'package:publishify/pages/naskah/naskah_list_page.dart';

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
  static const String review = '/review';
  static const String print = '/print';
  static const String pilihPercetakan = '/pilih-percetakan';
  static const String naskahList = '/naskah-list';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      success: (context) => const SuccessPage(),
      home: (context) => const MainLayout(initialIndex: 0),
      uploadBook: (context) => const UploadBookPage(),
      review: (context) => const ReviewPage(),
      print: (context) => const PrintPage(),
      pilihPercetakan: (context) => const PilihPercetakanPage(),
      naskahList: (context) => const NaskahListPage(),
    };
  }
}

