import 'package:flutter/material.dart';
import 'package:publishify/controllers/role_navigation_controller.dart';

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
      case '/home':
        return MaterialPageRoute(
          builder: (_) => HomePage(),
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
          builder: (_) => PenulisDashboardPage(),
          settings: settings,
        );

      case '/dashboard/editor':
        return MaterialPageRoute(
          builder: (_) => EditorDashboardPage(),
          settings: settings,
        );

      case '/dashboard/percetakan':
        return MaterialPageRoute(
          builder: (_) => PercetakanDashboardPage(),
          settings: settings,
        );

      case '/dashboard/admin':
        return MaterialPageRoute(
          builder: (_) => AdminDashboardPage(),
          settings: settings,
        );

      // ====================================
      // PENULIS SPECIFIC ROUTES
      // ====================================
      case '/penulis/manuscripts':
        return MaterialPageRoute(
          builder: (_) => PenulisManuscriptListPage(),
          settings: settings,
        );

      case '/penulis/orders':
        return MaterialPageRoute(
          builder: (_) => PenulisOrderListPage(),
          settings: settings,
        );

      case '/upload':
        return MaterialPageRoute(
          builder: (_) => UploadNaskahPage(),
          settings: settings,
        );

      // ====================================
      // EDITOR SPECIFIC ROUTES
      // ====================================
      case '/editor/reviews':
        return MaterialPageRoute(
          builder: (_) => EditorReviewListPage(),
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
          builder: (_) => ProfilePage(),
          settings: settings,
        );

      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => NotificationsPage(),
          settings: settings,
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => SettingsPage(),
          settings: settings,
        );

      // ====================================
      // 404 NOT FOUND
      // ====================================
      default:
        return MaterialPageRoute(
          builder: (_) => NotFoundPage(routeName: settings.name),
          settings: settings,
        );
    }
  }

  /// Get initial route berdasarkan auth status dan role
  static Future<String> getInitialRoute() async {
    // TODO: Implement auth check logic
    // Untuk sekarang return ke home page
    return '/';
  }
}

// ====================================
// PLACEHOLDER PAGES
// Anda perlu membuat/import file-file page yang sesuai
// ====================================

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