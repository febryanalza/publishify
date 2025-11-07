import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/review_models.dart';
import 'package:publishify/services/review_service.dart';

class RevisionDetailPage extends StatefulWidget {
  final ReviewData review;

  const RevisionDetailPage({
    super.key,
    required this.review,
  });

  @override
  State<RevisionDetailPage> createState() => _RevisionDetailPageState();
}

class _RevisionDetailPageState extends State<RevisionDetailPage> {
  ReviewData? _reviewDetail;
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
      final response = await ReviewService.getReviewById(widget.review.id);

      if (response.sukses && response.data != null) {
        setState(() {
          _reviewDetail = response.data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _reviewDetail == null
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Review Info Card
                                    _buildReviewInfoCard(),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Title Section
                                    Text(
                                      'Feedback Editor',
                                      style: AppTheme.headingMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Feedback List
                                    if (_reviewDetail!.feedback != null && _reviewDetail!.feedback!.isNotEmpty)
                                      ..._reviewDetail!.feedback!.map((feedback) {
                                        return _buildFeedbackCard(feedback);
                                      })
                                    else
                                      _buildNoFeedbackCard(),
                                    
                                    const SizedBox(height: 20),
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
          Expanded(
            child: Text(
              'Detail Revisi',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
            'Memuat detail review...',
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: AppTheme.greyMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Data review tidak ditemukan',
              style: TextStyle(
                color: AppTheme.greyMedium,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewInfoCard() {
    final String statusLabel = ReviewService.getStatusLabel(_reviewDetail!.status);
    final String naskahJudul = _reviewDetail!.naskah?.judul ?? 'Naskah';
    final String editorNama = _reviewDetail!.editor?.profilPengguna?.namaLengkap ?? 
                              _reviewDetail!.editor?.email ?? 'Editor';
    final String? rekomendasiLabel = _reviewDetail!.rekomendasi != null 
        ? ReviewService.getRekomendasiLabel(_reviewDetail!.rekomendasi!)
        : null;

    Color statusColor;
    switch (_reviewDetail!.status.toLowerCase()) {
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Naskah Title
            Text(
              naskahJudul,
              style: AppTheme.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            
            // Status
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppTheme.greyMedium,
                ),
                const SizedBox(width: 6),
                Text(
                  'Status: ',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
            
            const SizedBox(height: 8),
            
            // Editor
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
            
            // Rekomendasi (if selesai)
            if (rekomendasiLabel != null) ...[
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
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackData feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.greyLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with chapter/page
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (feedback.bab != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Bab ${feedback.bab}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (feedback.bab != null && feedback.halaman != null)
                      const SizedBox(width: 8),
                    if (feedback.halaman != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Hal. ${feedback.halaman}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Feedback text
            Text(
              feedback.komentar,
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Date
            Text(
              feedback.dibuatPada,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFeedbackCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.greyLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.comment_outlined,
                size: 48,
                color: AppTheme.greyMedium.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Belum ada feedback',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.greyMedium,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
