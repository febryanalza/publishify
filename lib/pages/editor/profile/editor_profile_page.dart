import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/utils/dummy_data.dart';
import 'package:publishify/models/writer/user_profile.dart';
import 'package:publishify/widgets/profile/profile_widgets.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/services/editor/profile_service.dart';
import 'package:publishify/pages/editor/profile/edit_profile_page.dart';
import 'package:publishify/widgets/network_image_widget.dart';

/// Halaman Profile Editor
class EditorProfilePage extends StatefulWidget {
  const EditorProfilePage({super.key});

  @override
  State<EditorProfilePage> createState() => _EditorProfilePageState();
}

class _EditorProfilePageState extends State<EditorProfilePage> {
  late UserProfile _profile;
  String _userName = '';
  String _userBio = 'Belum dilengkapi';
  String _userRole = '';
  String _userAvatar = '';
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Load data from DummyData for stats only
    _profile = DummyData.getUserProfile();
    
    // Load user data from API (with cache)
    await _loadUserDataFromAPI();
  }

  Future<void> _loadUserDataFromAPI() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      // Get profile from API (will use cache if not expired)
      final response = await EditorProfileService.getProfile();
      
      if (response.sukses && response.data != null && mounted) {
        final profileData = response.data!;
        
        setState(() {
          // Get nama tampilan from profile
          if (profileData.profilPengguna != null) {
            _userName = profileData.profilPengguna!.namaTampilan ?? '';
            _userBio = profileData.profilPengguna!.bio ?? 'Belum dilengkapi';
            _userAvatar = profileData.profilPengguna!.urlAvatar ?? '';
          } else {
            _userName = 'User';
            _userBio = 'Belum dilengkapi';
            _userAvatar = '';
          }
          
          // Get role/peran (join multiple active roles with comma)
          if (profileData.peranPengguna.isNotEmpty) {
            final activeRoles = profileData.peranPengguna
                .where((role) => role.aktif)
                .map((role) {
                  // Capitalize first letter of each role
                  final jenisPeran = role.jenisPeran;
                  return jenisPeran[0].toUpperCase() + jenisPeran.substring(1);
                })
                .toList();
            
            _userRole = activeRoles.isNotEmpty ? activeRoles.join(', ') : 'User';
          } else {
            _userRole = 'User';
          }
          
          _isLoadingProfile = false;
        });
      } else {
        // If API fails, try to load from old cache
        await _loadFromOldCache();
      }
    } catch (e) {
      // If error, try to load from old cache
      await _loadFromOldCache();
    }
  }

  /// Fallback: Load from old cache format (for backward compatibility)
  Future<void> _loadFromOldCache() async {
    try {
      final loginData = await AuthService.getLoginData();
      
      if (loginData != null && mounted) {
        setState(() {
          if (loginData.pengguna.profilPengguna != null) {
            _userName = loginData.pengguna.profilPengguna!.namaTampilan;
            _userBio = loginData.pengguna.profilPengguna!.bio ?? 'Belum dilengkapi';
          } else {
            _userName = 'User';
            _userBio = 'Belum dilengkapi';
          }
          
          if (loginData.pengguna.peran.isNotEmpty) {
            _userRole = loginData.pengguna.peran.map((role) {
              return role[0].toUpperCase() + role.substring(1);
            }).join(', ');
          } else {
            _userRole = 'User';
          }
          
          _isLoadingProfile = false;
        });
      } else {
        setState(() {
          _userName = 'User';
          _userBio = 'Belum dilengkapi';
          _userRole = 'User';
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = 'User';
          _userBio = 'Belum dilengkapi';
          _userRole = 'User';
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _refreshProfile() async {
    // Clear cache and reload from API
    await EditorProfileService.clearProfileCache();
    await _loadUserDataFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            _buildHeader(),
            
            // Main Content - Scrollable with RefreshIndicator
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProfile,
                color: AppTheme.primaryGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Profile Info Section
                      _buildProfileInfo(),
                      
                      const SizedBox(height: 24),
                      
                      // Bio Section
                      _buildBioSection(),
                      
                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Profil',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: AppTheme.white,
            ),
            onPressed: () {
              _showMoreMenu();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isLoadingProfile
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                ),
              ),
            )
          : Column(
        children: [
          // Profile Picture
          AvatarImage(
            urlAvatar: _userAvatar.isNotEmpty ? _userAvatar : _profile.photoUrl,
            size: 100,
            fallbackText: _userName,
          ),
          
          const SizedBox(height: 16),
          
          // Name (from cache)
          Text(
            _userName.isEmpty ? _profile.name : _userName,
            style: AppTheme.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppTheme.black,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Role (from cache)
          Text(
            _userRole.isEmpty ? _profile.role : _userRole,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Stats Row (khusus untuk editor)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatItem(
                count: _profile.totalBooks, // Total reviews
                label: 'Review',
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.greyLight,
              ),
              StatItem(
                count: _profile.totalRating,
                label: 'Rating',
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.greyLight,
              ),
              StatItem(
                count: _profile.totalViewers, // Naskah processed
                label: 'Naskah',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biografi Singkat',
            style: AppTheme.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Text(
              _userBio,
              style: AppTheme.bodyMedium.copyWith(
                color: _userBio == 'Belum dilengkapi' 
                  ? AppTheme.greyMedium.withValues(alpha: 0.6)
                  : AppTheme.greyMedium,
                height: 1.6,
                fontSize: 14,
                fontStyle: _userBio == 'Belum dilengkapi' 
                  ? FontStyle.italic 
                  : FontStyle.normal,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit, color: AppTheme.primaryGreen),
                title: const Text('Edit Profil'),
                onTap: () async {
                  Navigator.pop(context);
                  // Navigate to edit profile page
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditorEditProfilePage(),
                    ),
                  );
                  
                  // If profile was updated, reload data from API
                  if (result == true && mounted) {
                    await EditorProfileService.clearProfileCache();
                    await _loadUserDataFromAPI();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: AppTheme.primaryGreen),
                title: const Text('Pengaturan'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur pengaturan akan segera hadir'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.errorRed),
                title: const Text(
                  'Keluar',
                  style: TextStyle(color: AppTheme.errorRed),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutConfirmation();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: AppTheme.errorRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Keluar'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(
                color: AppTheme.greyMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleLogout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    // Close confirmation dialog
    Navigator.pop(context);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Logging out...',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mohon tunggu sebentar',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      // Call logout API and clear all data
      final success = await AuthService.logout();
      
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Navigate to splash screen and clear all routes
      if (mounted) {
        // Navigate to splash screen which will redirect to login
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
      
      // Show success message
      if (mounted && success) {
        // Wait a bit then show success on splash
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Berhasil logout'),
                backgroundColor: AppTheme.primaryGreen,
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // Still navigate to splash even on error
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    }
  }
}
