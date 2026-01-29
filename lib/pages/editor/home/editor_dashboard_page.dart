import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/editor/editor_models.dart';
import 'package:publishify/services/editor/editor_service.dart';
import 'package:publishify/services/general/auth_service.dart';
import 'package:publishify/widgets/cards/action_button.dart';
import 'package:publishify/pages/editor/review/review_collection_page.dart';
import 'package:publishify/pages/editor/feedback/editor_feedback_page.dart';
import 'package:publishify/pages/editor/naskah/naskah_masuk_page.dart';
import 'package:publishify/pages/editor/statistics/editor_statistics_page.dart';
import 'package:publishify/pages/editor/penerbitan/editor_pesanan_terbit_page.dart';

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
  bool _isLoading = true;
  String _editorName = '';
  
  // Statistik
  int _reviewMenunggu = 0;
  int _reviewDalamProses = 0;
  int _reviewSelesai = 0;
  int _totalReview = 0;

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
      final stats = await EditorService.getEditorStats();

      setState(() {
        _recentReviews = reviews;
        if (stats != null) {
          _reviewMenunggu = stats.reviewMenunggu;
          _reviewDalamProses = stats.reviewDalamProses;
          _reviewSelesai = stats.reviewSelesai;
          _totalReview = stats.totalReview;
        }
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
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppTheme.primaryGreen,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            
                            // Status Summary
                            _buildStatusSummary(),
                            
                            const SizedBox(height: 24),
                            
                            // Action Buttons (Menu Editor - sederhana)
                            _buildActionButtons(),
                            
                            const SizedBox(height: 24),
                            
                            // Recent Reviews
                            _buildRecentReviews(),
                            
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
                    'Hi ${_editorName.isNotEmpty ? _editorName : (widget.editorName ?? "Editor")} 👋',
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Apa yang mau kamu review hari ini?',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Review Kamu',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusCard(
                title: 'Menunggu',
                count: _reviewMenunggu,
                color: Colors.orange,
                onTap: () => _navigateToReviews('ditugaskan'),
              ),
              const SizedBox(width: 12),
              _buildStatusCard(
                title: 'Proses',
                count: _reviewDalamProses,
                color: Colors.blue,
                onTap: () => _navigateToReviews('sedang_review'),
              ),
              const SizedBox(width: 12),
              _buildStatusCard(
                title: 'Selesai',
                count: _reviewSelesai,
                color: Colors.green,
                onTap: () => _navigateToReviews('selesai'),
              ),
              const SizedBox(width: 12),
              _buildStatusCard(
                title: 'Total',
                count: _totalReview,
                color: AppTheme.primaryGreen,
                onTap: () => _navigateToReviews(null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: AppTheme.headingSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTheme.bodySmall.copyWith(
                  color: color,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ActionButton(
            icon: Icons.assignment_turned_in,
            label: 'Review',
            onTap: () => _handleAction('review'),
          ),
          ActionButton(
            icon: Icons.rate_review,
            label: 'Feedback',
            onTap: () => _handleAction('feedback'),
          ),
          ActionButton(
            icon: Icons.inbox,
            label: 'Naskah',
            onTap: () => _handleAction('naskah'),
            hasNotification: _reviewMenunggu > 0,
          ),
          ActionButton(
            icon: Icons.publish,
            label: 'Terbit',
            onTap: () => _handleAction('penerbitan'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
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
        ),
        const SizedBox(height: 16),
        _recentReviews.isEmpty
            ? _buildEmptyReviews()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: _recentReviews.take(3).map((review) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _buildReviewCard(review),
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
              'Review naskah yang ditugaskan\nakan muncul di sini',
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

  Widget _buildReviewCard(ReviewAssignment review) {
    final priorityColor = _getPriorityColor(review.prioritasLabel);
    final statusColor = _getStatusColor(review.status);

    return GestureDetector(
      onTap: () => _navigateToReviews(null),
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
                Text(
                  'Lihat Detail',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: AppTheme.primaryGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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
  void _handleAction(String action) {
    switch (action) {
      case 'review':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReviewCollectionPage()),
        );
        break;
      case 'feedback':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditorFeedbackPage()),
        );
        break;
      case 'naskah':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NaskahMasukPage()),
        );
        break;
      case 'statistik':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditorStatisticsPage()),
        );
        break;
      case 'penerbitan':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditorPesananTerbitPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action: $action'),
            duration: const Duration(seconds: 1),
          ),
        );
    }
  }

  void _navigateToReviews(String? status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReviewCollectionPage(),
      ),
    );
  }
}