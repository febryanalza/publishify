import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/editor/editor_models.dart';
import 'package:publishify/services/writer/editor_service.dart';
import 'package:publishify/widgets/cards/status_card.dart';
import 'package:publishify/services/writer/auth_service.dart';
import 'package:publishify/utils/editor_navigation.dart';

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
  EditorStats? _editorStats;
  List<ReviewAssignment> _recentReviews = [];
  List<Map<String, dynamic>> _quickActions = [];
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
      final stats = await EditorService.getEditorStats();
      final reviews = await EditorService.getReviewAssignments(limit: 5);
      final actions = EditorService.getQuickActions();
      final menuItems = EditorService.getEditorMenuItems();

      setState(() {
        _editorStats = stats;
        _recentReviews = reviews;
        _quickActions = actions;
        _menuItems = menuItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
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
                          
                          // Quick Actions
                          _buildQuickActions(),
                          
                          const SizedBox(height: 24),
                          
                          // Statistics Summary
                          _buildStatisticsSummary(),
                          
                          const SizedBox(height: 24),
                          
                          // Recent Reviews
                          _buildRecentReviews(),
                          
                          const SizedBox(height: 24),
                          
                          // Review Naskah Quick Access
                          _buildReviewNaskahSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Menu Items
                          _buildMenuItems(),
                          
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
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi ${_editorName.isNotEmpty ? _editorName : (widget.editorName ?? "Editor")}',
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selamat datang di dashboard editor',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.white.withAlpha(229),
                      fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi Cepat',
            style: AppTheme.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _quickActions.map((action) {
              return _buildActionCard(
                icon: _getIconData(action['icon']),
                label: action['label'],
                count: action['count'],
                color: _getActionColor(action['color']),
                onTap: () => _handleQuickAction(action['action']),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.greyLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSummary() {
    if (_editorStats == null) return Container();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Hari Ini',
            style: AppTheme.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatusCard(
                  title: 'Review\nAktif',
                  count: _editorStats!.reviewDalamProses,
                  onTap: () => _navigateToReviews('sedang_review'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatusCard(
                  title: 'Selesai\nHari Ini',
                  count: _editorStats!.reviewSelesaiHariIni,
                  onTap: () => _navigateToReviews('selesai'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatusCard(
                  title: 'Tertunda',
                  count: _editorStats!.reviewTertunda,
                  onTap: () => _navigateToReviews('ditugaskan'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.greyLight,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress Harian',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_editorStats!.pencapaianHarian}/${_editorStats!.targetHarian}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _editorStats!.persentasePencapaian / 100,
                  backgroundColor: AppTheme.greyDisabled,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _editorStats!.persentasePencapaian >= 100
                        ? Colors.green
                        : AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_editorStats!.persentasePencapaian.toStringAsFixed(1)}% dari target harian',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                    return _buildReviewCard(review);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewAssignment review) {
    Color statusColor = _getStatusColor(review.status);
    Color priorityColor = _getPriorityColor(review.prioritas);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyDisabled),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.judulNaskah,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review.prioritasLabel,
                  style: AppTheme.bodySmall.copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Penulis: ${review.penulis}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  review.statusLabel,
                  style: AppTheme.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatDeadline(review.batasWaktu),
                style: AppTheme.bodySmall.copyWith(
                  color: _isDeadlineNear(review.batasWaktu)
                      ? AppTheme.errorRed
                      : AppTheme.greyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppTheme.greyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada review',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Review yang ditugaskan\nakan muncul di sini',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewNaskahSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kelola Review Naskah',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => EditorNavigation.toReviewNaskah(context),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.1),
                  AppTheme.primaryGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.book_online,
                      color: AppTheme.primaryGreen,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review Naskah Terbaru',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          Text(
                            'Kelola review, tugaskan editor, dan lihat detail naskah',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.greyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAccessButton(
                        'Naskah Menunggu',
                        '5',
                        Icons.schedule,
                        () => EditorNavigation.toReviewNaskah(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAccessButton(
                        'Dalam Review',
                        '3',
                        Icons.rate_review,
                        () => EditorNavigation.toReviewNaskah(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAccessButton(
                        'Selesai Review',
                        '12',
                        Icons.done_all,
                        () => EditorNavigation.toReviewNaskah(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(
    String label,
    String count,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
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
          Column(
            children: _menuItems.map((item) {
              return _buildMenuItem(
                icon: _getIconData(item['icon']),
                title: item['title'],
                subtitle: item['subtitle'],
                badge: item['badge'],
                onTap: () => _navigateToRoute(item['route']),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    int? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.greyDisabled),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.greyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null && badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge.toString(),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.greyMedium,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'assignment':
        return Icons.assignment;
      case 'schedule':
        return Icons.schedule;
      case 'feedback':
        return Icons.feedback;
      case 'done_all':
        return Icons.done_all;
      case 'assignment_turned_in':
        return Icons.assignment_turned_in;
      case 'rate_review':
        return Icons.rate_review;
      case 'analytics':
        return Icons.analytics;
      default:
        return Icons.help_outline;
    }
  }

  Color _getActionColor(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'teal':
        return Colors.teal;
      default:
        return AppTheme.primaryGreen;
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

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
      case 5:
        return AppTheme.greyMedium;
      default:
        return AppTheme.greyMedium;
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    
    if (difference < 0) {
      return 'Terlambat';
    } else if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Besok';
    } else {
      return '$difference hari lagi';
    }
  }

  bool _isDeadlineNear(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference <= 1;
  }

  // Event Handlers
  void _handleQuickAction(String action) {
    switch (action) {
      case 'new_reviews':
        EditorNavigation.toReviewNaskah(context);
        break;
      case 'urgent_reviews':
        EditorNavigation.toReviewNaskah(context);
        break;
      case 'give_feedback':
        EditorNavigation.toFeedback(context);
        break;
      case 'completed_reviews':
        EditorNavigation.toReviewNaskah(context);
        break;
    }
  }

  void _navigateToReviews(String? status) {
    // Navigate to new review naskah page
    EditorNavigation.toReviewNaskah(context);
  }

  void _navigateToRoute(String route) {
    // Navigate to specific route
    Navigator.pushNamed(context, route);
  }
}