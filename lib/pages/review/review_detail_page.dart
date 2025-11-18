import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/review_models.dart';
import 'package:publishify/services/review_service.dart';

class ReviewDetailPage extends StatefulWidget {
  final ReviewData review;

  const ReviewDetailPage({
    super.key,
    required this.review,
  });

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  late ReviewData _review;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _review = widget.review;
    _loadDetailData();
  }

  Future<void> _loadDetailData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ReviewService.getReviewById(_review.id);

      if (response.sukses && response.data != null) {
        setState(() {
          _review = response.data!;
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
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : RefreshIndicator(
                          onRefresh: _loadDetailData,
                          color: AppTheme.primaryGreen,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNaskahInfo(),
                                const SizedBox(height: 20),
                                _buildReviewInfo(),
                                const SizedBox(height: 20),
                                if (_review.feedback != null && _review.feedback!.isNotEmpty)
                                  _buildFeedbackSection(),
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
              'Detail Review',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryGreen,
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
              onPressed: _loadDetailData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNaskahInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.greyDisabled,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.book,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Naskah',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.greyMedium,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _review.naskah?.judul ?? 'Judul Naskah',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_review.naskah?.kategori?.nama != null || _review.naskah?.genre?.nama != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_review.naskah?.kategori?.nama != null) ...[
                  const Icon(
                    Icons.category_outlined,
                    size: 16,
                    color: AppTheme.greyMedium,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _review.naskah!.kategori!.nama,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyMedium,
                    ),
                  ),
                ],
                if (_review.naskah?.kategori?.nama != null && _review.naskah?.genre?.nama != null)
                  const SizedBox(width: 16),
                if (_review.naskah?.genre?.nama != null) ...[
                  const Icon(
                    Icons.style_outlined,
                    size: 16,
                    color: AppTheme.greyMedium,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _review.naskah!.genre!.nama,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyMedium,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.greyDisabled,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Status Review',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(_review.status),
            ],
          ),
          const SizedBox(height: 16),
          
          // Editor info
          _buildInfoRow(
            Icons.person_outline,
            'Editor',
            _review.editor?.profilPengguna?.namaTampilan ?? _review.editor?.email ?? 'Tidak diketahui',
          ),
          const SizedBox(height: 12),
          
          // Rekomendasi
          if (_review.rekomendasi != null)
            _buildInfoRow(
              _getRekomendasiIcon(_review.rekomendasi!),
              'Rekomendasi',
              ReviewService.getRekomendasiLabel(_review.rekomendasi),
              valueColor: _getRekomendasiColor(_review.rekomendasi!),
            ),
          
          if (_review.rekomendasi != null)
            const SizedBox(height: 12),
          
          // Tanggal
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Ditugaskan',
            _formatFullDate(_review.ditugaskanPada),
          ),
          
          if (_review.dimulaiPada != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.play_circle_outline,
              'Dimulai',
              _formatFullDate(_review.dimulaiPada!),
            ),
          ],
          
          if (_review.selesaiPada != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.check_circle_outline,
              'Selesai',
              _formatFullDate(_review.selesaiPada!),
            ),
          ],
          
          // Catatan
          if (_review.catatan != null && _review.catatan!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Catatan Review',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _review.catatan!,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryDark,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback dari Editor',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        ..._review.feedback!.map((feedback) {
          return _buildFeedbackCard(feedback);
        }),
      ],
    );
  }

  Widget _buildFeedbackCard(FeedbackData feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.greyDisabled,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryGreen,
                child: Text(
                  (feedback.editor?.profilPengguna?.namaTampilan?.substring(0, 1).toUpperCase() ?? 'E'),
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.editor?.profilPengguna?.namaTampilan ?? 'Editor',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    Text(
                      _formatFullDate(feedback.dibuatPada),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.greyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback.isi,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.greyMedium,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyMedium,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  color: valueColor ?? AppTheme.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
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

  String _formatFullDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
