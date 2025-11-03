import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/utils/dummy_data.dart';
import 'package:publishify/models/user_profile.dart';
import 'package:publishify/widgets/navigation/bottom_nav_bar.dart';
import 'package:publishify/widgets/profile/profile_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3; // Profile tab
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load data from DummyData - mudah diganti nanti dengan API
    _profile = DummyData.getUserProfile();
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return; // Jika sudah di halaman yang sama, tidak perlu navigate
    
    setState(() {
      _currentIndex = index;
    });
    
    // Navigate to different pages based on index using pushReplacementNamed
    switch (index) {
      case 0:
        // Navigate to Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Navigate to Statistics
        Navigator.pushReplacementNamed(context, '/statistics');
        break;
      case 2:
        // Navigate to Notifications
        Navigator.pushReplacementNamed(context, '/notifications');
        break;
      case 3:
        // Already on Profile
        break;
    }
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
            
            // Main Content - Scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Profile Info Section
                    _buildProfileInfo(),
                    
                    const SizedBox(height: 24),
                    
                    // Bio Section
                    _buildBioSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Portfolio Section
                    _buildPortfolioSection(),
                    
                    const SizedBox(height: 80), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
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
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.yellow,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                _profile.photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGreen,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.greyLight,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.greyMedium,
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Name
          Text(
            _profile.name,
            style: AppTheme.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppTheme.black,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Role
          Text(
            _profile.role,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatItem(
                count: _profile.totalBooks,
                label: 'Buku',
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
                count: _profile.totalViewers,
                label: 'Viewers',
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
            'Bio',
            style: AppTheme.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _profile.bio,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio',
            style: AppTheme.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 16),
          
          // Portfolio List
          ..._profile.portfolios.map((portfolio) {
            return PortfolioItem(
              portfolio: portfolio,
              onTap: () {
                // TODO: Navigate to portfolio detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Membuka ${portfolio.title}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            );
          }),
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
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to edit profile
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur edit profil akan segera hadir'),
                      duration: Duration(seconds: 2),
                    ),
                  );
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
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
