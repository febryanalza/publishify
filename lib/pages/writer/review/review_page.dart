import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/review_models.dart';
import 'package:publishify/services/writer/review_service.dart';
import 'package:publishify/pages/writer/review/review_detail_page.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<ReviewData> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load data with cache support
  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Gunakan cache kecuali force refresh
      final response = await ReviewService.getAllReviewsForMyManuscripts(
        forceRefresh: forceRefresh,
      );

      if (response.sukses && response.data != null) {
        setState(() {
          _reviews = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.pesan;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Refresh data (clear cache and reload)
  Future<void> _refreshData() async {
    // Clear cache before refresh
    await ReviewService.clearCache();
    await _loadData(forceRefresh: true);
  }

  List<ReviewData> get _filteredReviews {
    if (_selectedFilter == 'semua') {
      return _reviews;
    }
    return _reviews.where((review) => 
      review.status.toLowerCase() == _selectedFilter
    ).toList();
  }

  void _openReviewDetail(ReviewData review) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailPage(review: review),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _reviews.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _refreshData, // Use _refreshData for pull-to-refresh
                              color: AppTheme.primaryGreen,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoCard(),
                                    const SizedBox(height: 20),
                                    _buildFilterChips(),
                                    const SizedBox(height: 16),
                                    ..._filteredReviews.map((review) {
                                      return _buildReviewCard(review);
                                    }),
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
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Review Naskah',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryGreen,
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data review...',
            style: TextStyle(
              color: AppTheme.greyMedium,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: AppTheme.greyMedium.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Review',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Naskah yang sedang direview\nakan muncul di sini',
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppTheme.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review dari Editor',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lihat feedback dan saran dari editor untuk naskah Anda',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'semua', 'label': 'Semua', 'count': _reviews.length},
      {
        'key': 'ditugaskan',
        'label': 'Ditugaskan',
        'count': _reviews.where((r) => r.status.toLowerCase() == 'ditugaskan').length,
      },
      {
        'key': 'dalam_proses',
        'label': 'Dalam Proses',
        'count': _reviews.where((r) => r.status.toLowerCase() == 'dalam_proses').length,
      },
      {
        'key': 'selesai',
        'label': 'Selesai',
        'count': _reviews.where((r) => r.status.toLowerCase() == 'selesai').length,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                '${filter['label']} (${filter['count']})',
                style: TextStyle(
                  color: isSelected ? AppTheme.white : AppTheme.primaryDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['key'] as String;
                });
              },
              backgroundColor: AppTheme.white,
              selectedColor: AppTheme.primaryGreen,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.greyDisabled,
                width: 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewCard(ReviewData review) {
    return GestureDetector(
      onTap: () => _openReviewDetail(review),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.greyDisabled,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDark.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Naskah title & status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.naskah?.judul ?? 'Judul Naskah',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review oleh: ${review.editor?.profilPengguna?.namaTampilan ?? review.editor?.email ?? "Editor"}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(review.status),
              ],
            ),
            const SizedBox(height: 12),

            // Review info
            if (review.catatan != null && review.catatan!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review.catatan!,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Rekomendasi & Feedback count
            Row(
              children: [
                if (review.rekomendasi != null) ...[
                  Icon(
                    _getRekomendasiIcon(review.rekomendasi!),
                    size: 16,
                    color: _getRekomendasiColor(review.rekomendasi!),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      ReviewService.getRekomendasiLabel(review.rekomendasi),
                      style: AppTheme.bodySmall.copyWith(
                        color: _getRekomendasiColor(review.rekomendasi!),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.comment_outlined,
                  size: 16,
                  color: AppTheme.greyMedium,
                ),
                const SizedBox(width: 4),
                Text(
                  '${review.feedback?.length ?? 0} Feedback',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    _formatDate(review.diperbaruiPada),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyMedium,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label = ReviewService.getStatusLabel(status);

    switch (status.toLowerCase()) {
      case 'ditugaskan':
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
      case 'dalam_proses':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case 'selesai':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case 'dibatalkan':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
      default:
        bgColor = AppTheme.greyLight;
        textColor = AppTheme.greyMedium;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  IconData _getRekomendasiIcon(String rekomendasi) {
    switch (rekomendasi.toLowerCase()) {
      case 'setujui':
        return Icons.check_circle;
      case 'revisi':
        return Icons.edit;
      case 'tolak':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getRekomendasiColor(String rekomendasi) {
    switch (rekomendasi.toLowerCase()) {
      case 'setujui':
        return Colors.green;
      case 'revisi':
        return Colors.orange;
      case 'tolak':
        return Colors.red;
      default:
        return AppTheme.greyMedium;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} menit lalu';
        }
        return '${difference.inHours} jam lalu';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
