import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/pages/auth/login_page.dart';
import 'package:publishify/pages/main_layout.dart';
import 'package:publishify/pages/editor/editor_main_page.dart';
import 'package:publishify/pages/percetakan/percetakan_main_page.dart';
import 'package:publishify/services/general/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Show splash screen for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Check if user is logged in
    final isLoggedIn = await AuthService.isLoggedIn();
    
    if (!mounted) return;
    
    if (isLoggedIn) {
      // User sudah login, cek peran untuk routing
      final primaryRole = await AuthService.getPrimaryRole();
      final userName = await AuthService.getNamaTampilan();
      
      if (!mounted) return;
      
      // Route berdasarkan peran utama
      Widget destinationPage;
      
      if (primaryRole == 'penulis') {
        // Arahkan ke halaman penulis dengan bottom navigation (MainLayout)
        destinationPage = MainLayout(
          initialIndex: 0,
          userName: userName,
        );
      } else if (primaryRole == 'editor') {
        // Arahkan ke halaman editor dengan bottom navigation (EditorMainPage)
        destinationPage = const EditorMainPage(
          initialIndex: 0,
        );
      } else if (primaryRole == 'percetakan') {
        // Arahkan ke halaman percetakan dengan bottom navigation (PercetakanMainPage)
        destinationPage = const PercetakanMainPage(
          initialIndex: 0,
        );
      } else {
        // Default: arahkan ke MainLayout (untuk penulis)
        destinationPage = MainLayout(
          initialIndex: 0,
          userName: userName,
        );
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => destinationPage,
        ),
      );
    } else {
      // User belum login atau cache dihapus, navigate ke Login Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Icon - Using a simple icon as placeholder
            Container(
              width: 200,
              height: 200,

              child: Image.asset(
                'assets/images/logo.png',
                height: 160,
                width: 160,
              ),
            ),
            const SizedBox(height: 5),
            
            Text(
              'Connect Writers & Editors',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
