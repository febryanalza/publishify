import 'package:flutter/material.dart';
import 'package:publishify/models/general/auth_models.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/utils/routes.dart';
import 'package:logger/logger.dart';

/// Controller untuk mengelola navigasi berdasarkan peran pengguna
/// Mengarahkan user ke dashboard yang sesuai dengan role mereka
class RoleNavigationController {
  static final logger = Logger();
  /// Dapatkan route berdasarkan peran pengguna
  /// 
  /// Returns:
  /// - '/dashboard/penulis' untuk role penulis
  /// - '/dashboard/editor' untuk role editor  
  /// - '/dashboard/percetakan' untuk role percetakan
  /// - '/dashboard/admin' untuk role admin
  /// - '/dashboard/penulis' sebagai default fallback
  static String getRoleBasedRoute(List<String> userRoles) {
    // Prioritas role: admin > editor > percetakan > penulis
    if (userRoles.contains('admin')) {
      return AppRoutes.dashboardAdmin;
    } else if (userRoles.contains('editor')) {
      return AppRoutes.dashboardEditor;
    } else if (userRoles.contains('percetakan')) {
      return AppRoutes.dashboardPercetakan;
    } else {
      // Default ke penulis jika role tidak dikenali atau penulis
      return AppRoutes.dashboardPenulis;
    }
  }

  /// Ekstrak role dari response login/register
  static List<String> extractRolesFromResponse(LoginResponse response) {
    if (response.data?.pengguna != null) {
      // Gunakan helper method dari UserData untuk mendapatkan role aktif
      return response.data!.pengguna.getActiveRoles();
    }
    return ['penulis']; // default fallback
  }

  /// Ekstrak role dari register response
  /// Karena RegisterResponse tidak memiliki info role lengkap, 
  /// kita return default 'penulis' sesuai dengan backend default
  static List<String> extractRolesFromRegisterResponse(RegisterResponse response) {
    // Register response hanya berisi ID, email, dan token verifikasi
    // Role default untuk registrasi adalah 'penulis'
    return ['penulis'];
  }

  /// Navigasi setelah login berhasil
  static Future<void> navigateAfterLogin(
    BuildContext context,
    LoginResponse response,
  ) async {
    try {
      // Extract roles dari response
      List<String> userRoles = extractRolesFromResponse(response);
      
      // Simpan roles ke cache untuk penggunaan selanjutnya
      await AuthService.saveUserRoles(userRoles);
      
      // Dapatkan route berdasarkan role
      String targetRoute = getRoleBasedRoute(userRoles);
      if(!context.mounted) return;
      
      // Navigate to appropriate dashboard
      Navigator.of(context).pushNamedAndRemoveUntil(
        targetRoute,
        (route) => false, // Remove all previous routes
      );
      
      logger.i('🎯 Navigating to: $targetRoute for roles: $userRoles');
    } catch (e) {
      logger.e('❌ Error in role navigation: $e');
      // Fallback ke dashboard penulis jika error
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.dashboardPenulis,
        (route) => false,
      );
    }
  }

  /// Navigasi setelah register berhasil
  static Future<void> navigateAfterRegister(
    BuildContext context,
    RegisterResponse response,
  ) async {
    try {
      // Extract roles dari response
      List<String> userRoles = extractRolesFromRegisterResponse(response);
      
      // Simpan roles ke cache untuk penggunaan selanjutnya
      await AuthService.saveUserRoles(userRoles);
      
      // Dapatkan route berdasarkan role
      String targetRoute = getRoleBasedRoute(userRoles);
      if(!context.mounted) return;
      
      // Navigate to appropriate dashboard
      Navigator.of(context).pushNamedAndRemoveUntil(
        targetRoute,
        (route) => false,
      );
      
      logger.i('🎯 Navigating after register to: $targetRoute for roles: $userRoles');
    } catch (e) {
      logger.e('❌ Error in role navigation after register: $e');
      // Fallback ke dashboard penulis jika error
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.dashboardPenulis,
        (route) => false,
      );
    }
  }

  /// Check role permission untuk akses fitur tertentu
  static bool hasRolePermission(List<String> userRoles, String requiredRole) {
    return userRoles.contains(requiredRole) || userRoles.contains('admin');
  }

  /// Check multiple role permissions (OR logic)
  static bool hasAnyRolePermission(List<String> userRoles, List<String> requiredRoles) {
    return requiredRoles.any((role) => userRoles.contains(role)) || userRoles.contains('admin');
  }

  /// Dapatkan primary role (role dengan prioritas tertinggi)
  static String getPrimaryRole(List<String> userRoles) {
    if (userRoles.contains('admin')) return 'admin';
    if (userRoles.contains('editor')) return 'editor';
    if (userRoles.contains('percetakan')) return 'percetakan';
    return 'penulis';
  }

  /// Dapatkan greeting message berdasarkan role
  static String getRoleGreeting(List<String> userRoles) {
    String primaryRole = getPrimaryRole(userRoles);
    
    switch (primaryRole) {
      case 'admin':
        return 'Selamat datang, Administrator!';
      case 'editor':
        return 'Selamat datang, Editor!';
      case 'percetakan':
        return 'Selamat datang, Tim Percetakan!';
      case 'penulis':
      default:
        return 'Selamat datang, Penulis!';
    }
  }

  /// Dapatkan icon berdasarkan role
  static IconData getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'editor':
        return Icons.edit;
      case 'percetakan':
        return Icons.print;
      case 'penulis':
      default:
        return Icons.create;
    }
  }

  /// Dapatkan color berdasarkan role
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'editor':
        return Colors.blue;
      case 'percetakan':
        return Colors.green;
      case 'penulis':
      default:
        return Colors.orange;
    }
  }
}

// ====================================
// PLACEHOLDER DASHBOARD WIDGETS
// Anda perlu membuat file-file ini
// ====================================

/// Dashboard untuk Admin
class AdminDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin'),
        backgroundColor: RoleNavigationController.getRoleColor('admin'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              RoleNavigationController.getRoleIcon('admin'),
              size: 100,
              color: RoleNavigationController.getRoleColor('admin'),
            ),
            SizedBox(height: 20),
            Text(
              'Dashboard Administrator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Kelola pengguna, naskah, review, dan sistem'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate ke halaman admin yang sesuai
                Navigator.pushNamed(context, '/admin/users');
              },
              child: Text('Kelola Pengguna'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate ke halaman admin review
                Navigator.pushNamed(context, '/admin/reviews');
              },
              child: Text('Kelola Review'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard untuk Editor
class EditorDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Editor'),
        backgroundColor: RoleNavigationController.getRoleColor('editor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              RoleNavigationController.getRoleIcon('editor'),
              size: 100,
              color: RoleNavigationController.getRoleColor('editor'),
            ),
            SizedBox(height: 20),
            Text(
              'Dashboard Editor',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Review dan edit naskah dari penulis'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate ke halaman review yang ditugaskan
                Navigator.pushNamed(context, '/editor/reviews');
              },
              child: Text('Review Naskah'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate ke halaman feedback
                Navigator.pushNamed(context, '/editor/feedback');
              },
              child: Text('Berikan Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard untuk Percetakan
class PercetakanDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Percetakan'),
        backgroundColor: RoleNavigationController.getRoleColor('percetakan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              RoleNavigationController.getRoleIcon('percetakan'),
              size: 100,
              color: RoleNavigationController.getRoleColor('percetakan'),
            ),
            SizedBox(height: 20),
            Text(
              'Dashboard Percetakan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Kelola pesanan cetak dan pengiriman'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate ke halaman pesanan
                Navigator.pushNamed(context, '/percetakan/orders');
              },
              child: Text('Pesanan Cetak'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate ke halaman produksi
                Navigator.pushNamed(context, '/percetakan/production');
              },
              child: Text('Status Produksi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard untuk Penulis
class PenulisDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Penulis'),
        backgroundColor: RoleNavigationController.getRoleColor('penulis'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              RoleNavigationController.getRoleIcon('penulis'),
              size: 100,
              color: RoleNavigationController.getRoleColor('penulis'),
            ),
            SizedBox(height: 20),
            Text(
              'Dashboard Penulis',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Tulis, kelola, dan terbitkan naskah Anda'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate ke halaman naskah
                Navigator.pushNamed(context, '/penulis/manuscripts');
              },
              child: Text('Naskah Saya'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate ke halaman upload
                Navigator.pushNamed(context, '/upload');
              },
              child: Text('Upload Naskah'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate ke halaman pesanan cetak
                Navigator.pushNamed(context, '/penulis/orders');
              },
              child: Text('Pesanan Cetak'),
            ),
          ],
        ),
      ),
    );
  }
}