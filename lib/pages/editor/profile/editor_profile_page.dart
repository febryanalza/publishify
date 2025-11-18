import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/services/writer/auth_service.dart';

/// Halaman Profile Editor
class EditorProfilePage extends StatefulWidget {
  const EditorProfilePage({super.key});

  @override
  State<EditorProfilePage> createState() => _EditorProfilePageState();
}

class _EditorProfilePageState extends State<EditorProfilePage> {
  Map<String, dynamic> _profileData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Simulasi loading profile data
    await Future.delayed(const Duration(milliseconds: 800));

    // Dummy profile data
    setState(() {
      _profileData = {
        'nama': 'Dr. Sarah Wijaya',
        'email': 'sarah.wijaya@publishify.com',
        'telepon': '+62 812-3456-7890',
        'spesialisasi': ['Fiksi Sastra', 'Novel Romantis', 'Biografi'],
        'pengalaman': '8 tahun',
        'totalReview': 156,
        'rating': 4.8,
        'bergabung': DateTime(2020, 3, 15),
        'avatar': 'https://via.placeholder.com/150',
        'bio': 'Editor berpengalaman dengan spesialisasi dalam fiksi sastra dan novel romantis. Memiliki gelar doktor dalam Sastra Indonesia dan telah mereview lebih dari 150 naskah.',
        'sertifikasi': [
          'Certified Professional Editor (CPE)',
          'Literary Review Specialist',
          'Creative Writing Mentor',
        ],
        'bahasa': ['Indonesia', 'English', 'Mandarin'],
        'status': 'Aktif',
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile Editor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editProfile,
            tooltip: 'Edit Profile',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Pengaturan'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help),
                  title: Text('Bantuan'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Keluar', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildProfileSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/150'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _profileData['nama'] ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _profileData['email'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Status: ${_profileData['status']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildStatsSection(),
          const SizedBox(height: 20),
          _buildInfoSection(),
          const SizedBox(height: 20),
          _buildSpesialisasiSection(),
          const SizedBox(height: 20),
          _buildSertifikasiSection(),
          const SizedBox(height: 20),
          _buildQuickActionsSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Review',
                    _profileData['totalReview'].toString(),
                    Icons.assignment_outlined,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Rating',
                    _profileData['rating'].toString(),
                    Icons.star,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pengalaman',
                    _profileData['pengalaman'],
                    Icons.work_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(Icons.phone, 'Telepon', _profileData['telepon']),
            _buildInfoItem(Icons.calendar_today, 'Bergabung', 
                '${_profileData['bergabung'].day}/${_profileData['bergabung'].month}/${_profileData['bergabung'].year}'),
            _buildInfoItem(Icons.language, 'Bahasa', _profileData['bahasa'].join(', ')),
            const SizedBox(height: 16),
            const Text(
              'Bio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _profileData['bio'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpesialisasiSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spesialisasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _profileData['spesialisasi']
                  .map<Widget>((spesialisasi) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          spesialisasi,
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSertifikasiSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sertifikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._profileData['sertifikasi']
                .map<Widget>((sertifikasi) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            color: AppTheme.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              sertifikasi,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Edit Profile',
              Icons.edit,
              () => _editProfile(),
            ),
            _buildActionButton(
              'Ganti Password',
              Icons.lock,
              () => _changePassword(),
            ),
            _buildActionButton(
              'Pengaturan Notifikasi',
              Icons.notifications,
              () => _notificationSettings(),
            ),
            _buildActionButton(
              'Bantuan & FAQ',
              Icons.help,
              () => _showHelp(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur edit profile akan segera tersedia')),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ganti password akan segera tersedia')),
    );
  }

  void _notificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur pengaturan notifikasi akan segera tersedia')),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur bantuan akan segera tersedia')),
    );
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur pengaturan akan segera tersedia')),
        );
        break;
      case 'help':
        _showHelp();
        break;
      case 'logout':
        _showLogoutConfirmation();
        break;
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    // TODO: Implement logout logic
    await AuthService.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }
}