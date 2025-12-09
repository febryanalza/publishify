import 'package:flutter/material.dart';

// Editor pages imports
import 'package:publishify/pages/editor/editor_main_page.dart';
import 'package:publishify/pages/editor/review/review_collection_page.dart';
import 'package:publishify/pages/editor/review/review_naskah_page.dart';
import 'package:publishify/pages/editor/review/detail_review_naskah_page.dart';
import 'package:publishify/pages/editor/statistics/editor_statistics_page.dart';
import 'package:publishify/pages/editor/notifications/editor_notifications_page.dart';
import 'package:publishify/pages/editor/profile/editor_profile_page.dart';
import 'package:publishify/pages/editor/naskah/naskah_masuk_page.dart';
import 'package:publishify/pages/editor/feedback/editor_feedback_page.dart';
// import 'package:publishify/pages/editor/editor_route_test_page.dart';

// Percetakan pages imports
import 'package:publishify/pages/percetakan/percetakan_main_page.dart';

// Auth pages imports
import 'package:publishify/pages/auth/splash_screen.dart';
import 'package:publishify/pages/auth/login_page.dart';
import 'package:publishify/pages/auth/register_page.dart';
import 'package:publishify/pages/auth/success_page.dart';

// Writer/Common pages imports
import 'package:publishify/pages/main_layout.dart';
import 'package:publishify/pages/writer/home/home_page.dart';
import 'package:publishify/pages/writer/upload/upload_book_page.dart';
import 'package:publishify/pages/writer/review/review_page.dart';
import 'package:publishify/pages/writer/print/print_page.dart';
import 'package:publishify/pages/writer/percetakan/pilih_percetakan_page.dart';
import 'package:publishify/pages/writer/naskah/naskah_list_page.dart';
import 'package:publishify/pages/writer/naskah/detail_naskah_page.dart';

/// Route Configuration untuk Role-Based Navigation
/// Mengatur routing berdasarkan role pengguna
class AppRoutes {
  
  /// Generate routes berdasarkan route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ====================================
      // AUTH ROUTES
      // ====================================
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case '/home':
        return MaterialPageRoute(
          builder: (_) => const MainLayout(initialIndex: 0),
          settings: settings,
        );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => LoginPage(),
          settings: settings,
        );

      case '/register':
        return MaterialPageRoute(
          builder: (_) => RegisterPage(),
          settings: settings,
        );

      // ====================================
      // ROLE-BASED DASHBOARD ROUTES
      // ====================================
      case '/dashboard/penulis':
        return MaterialPageRoute(
          builder: (_) => const MainLayout(initialIndex: 0), // MainLayout dengan bottom nav untuk penulis
          settings: settings,
        );

      case '/dashboard/editor':
        return MaterialPageRoute(
          builder: (_) => const EditorMainPage(),
          settings: settings,
        );

      case '/dashboard/percetakan':
        return MaterialPageRoute(
          builder: (_) => const PercetakanMainPage(),
          settings: settings,
        );

      case '/dashboard/admin':
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderPage('Admin Dashboard', 'Dashboard untuk role admin belum tersedia'),
          settings: settings,
        );

      // ====================================
      // PENULIS SPECIFIC ROUTES
      // ====================================
      case '/penulis/manuscripts':
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderPage('Daftar Naskah', 'Halaman daftar naskah penulis'),
          settings: settings,
        );

      case '/penulis/orders':
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderPage('Pesanan Penulis', 'Halaman pesanan untuk penulis'),
          settings: settings,
        );

      case '/upload':
        return MaterialPageRoute(
          builder: (_) => UploadBookPage(),
          settings: settings,
        );

      // ====================================
      // EDITOR SPECIFIC ROUTES
      // ====================================
      case '/editor/reviews':
        return MaterialPageRoute(
          builder: (_) => const ReviewCollectionPage(),
          settings: settings,
        );

      case '/editor/review-naskah':
        return MaterialPageRoute(
          builder: (_) => const ReviewNaskahPage(),
          settings: settings,
        );

      case '/editor/detail-review-naskah':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DetailReviewNaskahPage(
            naskahId: args?['naskahId'] ?? '',
          ),
          settings: settings,
        );

      case '/editor/statistics':
        return MaterialPageRoute(
          builder: (_) => const EditorStatisticsPage(),
          settings: settings,
        );

      case '/editor/notifications':
        return MaterialPageRoute(
          builder: (_) => const EditorNotificationsPage(),
          settings: settings,
        );

      case '/editor/profile':
        return MaterialPageRoute(
          builder: (_) => const EditorProfilePage(),
          settings: settings,
        );

      case '/editor/naskah-masuk':
        return MaterialPageRoute(
          builder: (_) => const NaskahMasukPage(),
          settings: settings,
        );

      case '/editor/feedback':
        return MaterialPageRoute(
          builder: (_) => EditorFeedbackPage(),
          settings: settings,
        );

      
      // ====================================
      // PERCETAKAN SPECIFIC ROUTES
      // ====================================
      case '/percetakan/orders':
        return MaterialPageRoute(
          builder: (_) => PercetakanOrderListPage(),
          settings: settings,
        );

      case '/percetakan/production':
        return MaterialPageRoute(
          builder: (_) => PercetakanProductionPage(),
          settings: settings,
        );

      // ====================================
      // ADMIN SPECIFIC ROUTES
      // ====================================
      case '/admin/users':
        return MaterialPageRoute(
          builder: (_) => AdminUserManagementPage(),
          settings: settings,
        );

      case '/admin/reviews':
        return MaterialPageRoute(
          builder: (_) => AdminReviewManagementPage(),
          settings: settings,
        );

      // ====================================
      // SHARED ROUTES
      // ====================================
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderPage('Profil', 'Halaman profil pengguna'),
          settings: settings,
        );

      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderPage('Notifikasi', 'Halaman notifikasi pengguna'),
          settings: settings,
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderPage('Pengaturan', 'Halaman pengaturan aplikasi'),
          settings: settings,
        );

      // ====================================
      // WRITER/PENULIS SPECIFIC ROUTES
      // ====================================
      case '/success':
        return MaterialPageRoute(
          builder: (_) => const SuccessPage(),
          settings: settings,
        );

      case '/upload-book':
        return MaterialPageRoute(
          builder: (_) => const UploadBookPage(),
          settings: settings,
        );

      case '/review':
        return MaterialPageRoute(
          builder: (_) => const ReviewPage(),
          settings: settings,
        );

      case '/print':
        return MaterialPageRoute(
          builder: (_) => const PrintPage(),
          settings: settings,
        );

      case '/pilih-percetakan':
        return MaterialPageRoute(
          builder: (_) => const PilihPercetakanPage(),
          settings: settings,
        );

      case '/naskah-list':
        return MaterialPageRoute(
          builder: (_) => const NaskahListPage(),
          settings: settings,
        );

      case '/detail-naskah':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DetailNaskahPage(
            naskahId: args?['naskahId'] ?? '',
          ),
          settings: settings,
        );

      // ====================================
      // 404 NOT FOUND
      // ====================================
      default:
        return MaterialPageRoute(
          builder: (_) => _build404Page(settings.name),
          settings: settings,
        );
    }
  }

  /// Helper method untuk membuat placeholder page
  static Widget _buildPlaceholderPage(String title, String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text(
                'Segera Hadir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method untuk 404 page
  static Widget _build404Page(String? routeName) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Tidak Ditemukan'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '404 - Halaman Tidak Ditemukan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Route "$routeName" tidak tersedia',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
              ),
              child: const Text(
                'Kembali ke Beranda',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get initial route berdasarkan auth status dan role
  static Future<String> getInitialRoute() async {
    // TODO: Implement auth check logic
    // Untuk sekarang return ke splash screen
    return '/';
  }
}

// ====================================
// PLACEHOLDER PAGES
// Anda perlu membuat/import file-file page yang sesuai
// ====================================

/// Dashboard untuk Percetakan
class PercetakanDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Percetakan')),
      body: Center(
        child: Text('Percetakan Dashboard - TODO: Implement'),
      ),
    );
  }
}

/// Dashboard untuk Admin
class AdminDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Admin')),
      body: Center(
        child: Text('Admin Dashboard - TODO: Implement'),
      ),
    );
  }
}

/// Home Page (Landing Page)
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Publishify')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selamat Datang di Publishify',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Login Page Placeholder
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Text('Login Page - TODO: Implement'),
      ),
    );
  }
}

/// Register Page Placeholder
class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: Text('Register Page - TODO: Implement'),
      ),
    );
  }
}

/// Profile Page Placeholder
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: Text('Profile Page - TODO: Implement'),
      ),
    );
  }
}

/// Notifications Page Placeholder
class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: Center(
        child: Text('Notifications Page - TODO: Implement'),
      ),
    );
  }
}

/// Settings Page Placeholder
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: Text('Settings Page - TODO: Implement'),
      ),
    );
  }
}

// ====================================
// PENULIS SPECIFIC PAGES
// ====================================

/// Penulis Manuscript List Page
class PenulisManuscriptListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Naskah Saya')),
      body: Center(
        child: Text('Penulis Manuscript List - TODO: Implement'),
      ),
    );
  }
}

/// Penulis Order List Page
class PenulisOrderListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pesanan Cetak Saya')),
      body: Center(
        child: Text('Penulis Order List - TODO: Implement'),
      ),
    );
  }
}

/// Upload Naskah Page
class UploadNaskahPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Naskah')),
      body: Center(
        child: Text('Upload Naskah Page - TODO: Implement'),
      ),
    );
  }
}

// ====================================
// EDITOR SPECIFIC PAGES
// ====================================

/// Editor Review List Page
class EditorReviewListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Naskah')),
      body: Center(
        child: Text('Editor Review List - TODO: Implement'),
      ),
    );
  }
}

/// Editor Feedback Page
class EditorFeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Berikan Feedback')),
      body: Center(
        child: Text('Editor Feedback Page - TODO: Implement'),
      ),
    );
  }
}

// ====================================
// PERCETAKAN SPECIFIC PAGES
// ====================================

/// Percetakan Order List Page
class PercetakanOrderListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pesanan Cetak')),
      body: Center(
        child: Text('Percetakan Order List - TODO: Implement'),
      ),
    );
  }
}

/// Percetakan Production Page
class PercetakanProductionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Status Produksi')),
      body: Center(
        child: Text('Percetakan Production Page - TODO: Implement'),
      ),
    );
  }
}

// ====================================
// ADMIN SPECIFIC PAGES
// ====================================

/// Admin User Management Page
class AdminUserManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Pengguna')),
      body: Center(
        child: Text('Admin User Management - TODO: Implement'),
      ),
    );
  }
}

/// Admin Review Management Page
class AdminReviewManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Review')),
      body: Center(
        child: Text('Admin Review Management - TODO: Implement'),
      ),
    );
  }
}

// ====================================
// 404 NOT FOUND PAGE
// ====================================

/// Not Found Page
class NotFoundPage extends StatelessWidget {
  final String? routeName;

  const NotFoundPage({Key? key, this.routeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Halaman Tidak Ditemukan')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text(
              '404 - Halaman Tidak Ditemukan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Route: ${routeName ?? 'Unknown'}'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              child: Text('Kembali ke Home'),
            ),
          ],
        ),
      ),
    );
  }
}