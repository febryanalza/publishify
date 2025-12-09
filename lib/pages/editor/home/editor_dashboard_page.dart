import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/editor/editor_models.dart';
import 'package:publishify/services/editor/editor_service.dart';
import 'package:publishify/services/general/auth_service.dart';

class EditorDashboardPage extends StatefulWidget {
  final String? editorName;

  const EditorDashboardPage({
    super.key,
    this.editorName,
  });

  @override
  State<EditorDashboardPage> createState() => _EditorDashboardPageState();
}

class _EditorDashboardPageState extends State<EditorDashboardPage> {

  List<ReviewAssignment> _recentReviews = [];
  List<Map<String, dynamic>> _menuItems = [];
  bool _isLoading = true;
  String _editorName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load editor name from cache
    final namaTampilan = await AuthService.getNamaTampilan();
    if (namaTampilan != null) {
      _editorName = namaTampilan;
    }

    // Load data dari service
    try {

      final reviews = await EditorService.getReviewAssignments(limit: 5);
      final menuItems = EditorService.getEditorMenuItems();

      setState(() {
        _recentReviews = reviews;
        _menuItems = menuItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Main Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryGreen,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Menu Editor (Kotak-kotak)
                          _buildEditorMenu(),
                          
                          const SizedBox(height: 24),
                          
                          // Recent Reviews
                          _buildRecentReviews(),
                          
                          const SizedBox(height: 24),
                          
                          // Review Naskah Quick Access
                          _buildReviewNaskahSection(),
                          
                          const SizedBox(height: 80), // Space for bottom nav
                        ],
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
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Greeting
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi $_editorName 👋',
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selamat datang di dashboard editor',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                // Profile Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primaryGreen,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Editor',
            style: AppTheme.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: _menuItems.map((item) {
              return _buildMenuCard(
                icon: _getIconData(item['icon']),
                title: item['title'],
                subtitle: item['subtitle'],
                count: item['badge'] ?? 0,
                color: _getMenuColor('green'), // Default color since service doesn't provide color
                onTap: () => _navigateToMenu(item['route']),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.greyLight.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Review Terkini',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToReviews(null),
                child: Text(
                  'Lihat Semua',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _recentReviews.isEmpty
              ? _buildEmptyReviews()
              : Column(
                  children: _recentReviews.take(3).map((review) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.greyLight.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildReviewCard(review),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.greyLight.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: AppTheme.greyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada review',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review baru akan muncul di sini',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewAssignment review) {
    final priorityColor = _getPriorityColor(review.prioritasLabel);
    final statusColor = _getStatusColor(review.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.judulNaskah,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Oleh ${review.penulis}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyMedium,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    review.prioritasLabel.toUpperCase(),
                    style: AppTheme.bodySmall.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    review.statusLabel,
                    style: AppTheme.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: AppTheme.greyMedium,
            ),
            const SizedBox(width: 4),
            Text(
              'Deadline: ${_formatDate(review.batasWaktu)}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
                fontSize: 11,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _navigateToReviewDetail(review.id),
              child: Text(
                'Lihat Detail',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewNaskahSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryGreen.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kelola Review Naskah',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Akses cepat untuk mengelola semua review naskah yang ditugaskan kepada Anda',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToReviews(null),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Buka Review Naskah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'assignment':
        return Icons.assignment;
      case 'assignment_turned_in':
        return Icons.assignment_turned_in;
      case 'book_online':
        return Icons.book_online;
      case 'rate_review':
        return Icons.rate_review;
      case 'feedback':
        return Icons.feedback;
      case 'inbox':
        return Icons.inbox;
      case 'analytics':
        return Icons.analytics;
      case 'schedule':
        return Icons.schedule;
      case 'done_all':
        return Icons.done_all;
      case 'star':
        return Icons.star;
      default:
        return Icons.help;
    }
  }

  Color _getMenuColor(String colorName) {
    switch (colorName) {
      case 'green':
        return AppTheme.primaryGreen;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      default:
        return AppTheme.greyMedium;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'sangat tinggi':
        return Colors.red;
      case 'tinggi':
        return Colors.orange;
      case 'sedang':
        return Colors.yellow[700]!;
      case 'rendah':
        return Colors.green;
      default:
        return AppTheme.greyMedium;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ditugaskan':
        return Colors.blue;
      case 'sedang_review':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return AppTheme.greyMedium;
    }
  }



  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Besok';
    } else if (difference > 0) {
      return '$difference hari lagi';
    } else {
      return '${difference.abs()} hari lalu';
    }
  }

  // Navigation methods
  void _navigateToMenu(String route) {
    // TODO: Implement navigation berdasarkan route
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $route'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _navigateToReviews(String? status) {
    // TODO: Navigate to review page with optional status filter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to reviews${status != null ? ' with status: $status' : ''}'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _navigateToReviewDetail(String reviewId) {
    // TODO: Navigate to review detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to review detail: $reviewId'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
}