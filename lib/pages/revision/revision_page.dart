import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/review_models.dart';
import 'package:publishify/services/review_service.dart';
import 'package:publishify/pages/revision/revision_detail_page.dart';

class RevisionPage extends StatefulWidget {
  const RevisionPage({super.key});

  @override
  State<RevisionPage> createState() => _RevisionPageState();
}

class _RevisionPageState extends State<RevisionPage> {
  List<ReviewData> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ReviewService.getAllReviewsForMyManuscripts();

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

  void _openRevisionDetail(ReviewData review) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RevisionDetailPage(review: review),
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
                              onRefresh: _loadData,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _buildInfoCard(),
                                    const SizedBox(height: 20),
                                    ..._reviews.map((review) {
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
            'Revisi',
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
              color: AppTheme.greyMedium.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Review',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Naskah Anda belum ada yang sedang direview',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
              textAlign: TextAlign.center,
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
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.primaryGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Berikut adalah daftar review dan feedback untuk naskah Anda',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryGreen,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewData review) {
    final String naskahJudul = review.naskah?.judul ?? 'Naskah';
    final String editorNama = review.editor?.profilPengguna?.namaLengkap ?? 
                              review.editor?.email ?? 'Editor';
    final int feedbackCount = review.count?.feedback ?? 0;
    final String statusLabel = ReviewService.getStatusLabel(review.status);
    final String rekomendasiLabel = ReviewService.getRekomendasiLabel(review.rekomendasi);

    Color statusColor;
    switch (review.status.toLowerCase()) {
      case 'ditugaskan':
        statusColor = Colors.blue;
        break;
      case 'dalam_proses':
        statusColor = Colors.orange;
        break;
      case 'selesai':
        statusColor = Colors.green;
        break;
      case 'dibatalkan':
        statusColor = Colors.red;
        break;
      default:
        statusColor = AppTheme.greyMedium;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _openRevisionDetail(review),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      naskahJudul,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      statusLabel,
                      style: AppTheme.bodySmall.copyWith(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppTheme.greyMedium,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Editor: $editorNama',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyMedium,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.comment_outlined,
                    size: 16,
                    color: AppTheme.greyMedium,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$feedbackCount Komentar',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyMedium,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (review.status.toLowerCase() == 'selesai' && review.rekomendasi != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: AppTheme.greyMedium,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Rekomendasi: $rekomendasiLabel',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.greyMedium,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Lihat Detail',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppTheme.primaryGreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
