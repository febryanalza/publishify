import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/editor/review_collection_models.dart';
import 'package:publishify/services/editor/review_collection_service.dart';

/// Halaman detail buku untuk review
/// Menampilkan informasi lengkap buku dan form untuk input review
class ReviewDetailPage extends StatefulWidget {
  final BukuMasukReview book;

  const ReviewDetailPage({
    super.key,
    required this.book,
  });

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  DetailBukuReview? _detailBuku;
  bool _isLoading = true;
  String? _errorMessage;

  // Form controllers
  final _catatanController = TextEditingController();
  final _feedbackController = TextEditingController();
  String _selectedRekomendasi = 'revisi';
  int _selectedRating = 3;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDetailBuku();
  }

  Future<void> _loadDetailBuku() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ReviewCollectionService.getDetailBuku(widget.book.id);
      
      if (response.sukses && response.data != null) {
        setState(() {
          _detailBuku = response.data!;
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

  Future<void> _submitReview() async {
    if (_catatanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan review tidak boleh kosong'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final feedbackList = _feedbackController.text.trim().isNotEmpty
          ? _feedbackController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
          : <String>[];

      final review = InputReview(
        idBuku: widget.book.id,
        catatan: _catatanController.text.trim(),
        rekomendasi: _selectedRekomendasi,
        feedback: feedbackList,
        rating: _selectedRating,
      );

      final response = await ReviewCollectionService.submitReview(review);

      if (response.sukses) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.pesan),
            backgroundColor: AppTheme.googleGreen,
          ),
        );
        
        // Navigate back to collection page
        Navigator.pop(context, true); // Pass true to indicate review was submitted
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.pesan),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal submit review: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
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
                      : _buildContent(),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Buku Review',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review dan berikan feedback',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.rate_review,
              color: AppTheme.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_detailBuku == null) return Container();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookInfo(),
          const SizedBox(height: 20),
          _buildMetadataInfo(),
          const SizedBox(height: 20),
          _buildRiwayatReview(),
          const SizedBox(height: 20),
          _buildReviewForm(),
        ],
      ),
    );
  }

  Widget _buildBookInfo() {
    final book = _detailBuku!.bukuInfo;
    
    return Card(
      elevation: 2,
      color: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover buku
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.greyLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.greyDisabled),
                  ),
                  child: book.urlSampul != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book.urlSampul!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.book,
                              color: AppTheme.greyMedium,
                              size: 40,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.book,
                          color: AppTheme.greyMedium,
                          size: 40,
                        ),
                ),
                const SizedBox(width: 16),
                
                // Info buku
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.judul,
                        style: AppTheme.headingSmall.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      if (book.subJudul.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          book.subJudul,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.greyMedium,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      
                      _buildInfoRow(Icons.person, 'Penulis', book.namaPenulis),
                      _buildInfoRow(Icons.category, 'Kategori', book.kategori),
                      _buildInfoRow(Icons.local_offer, 'Genre', book.genre),
                      _buildInfoRow(Icons.description, 'Halaman', '${book.jumlahHalaman} hal'),
                      _buildInfoRow(Icons.text_fields, 'Kata', '${(book.jumlahKata / 1000).toStringAsFixed(1)}k kata'),
                      _buildInfoRow(Icons.schedule, 'Submit', _formatDate(book.tanggalSubmit)),
                      
                      if (book.deadlineReview != null)
                        _buildInfoRow(
                          Icons.alarm, 
                          'Deadline', 
                          _formatDate(book.deadlineReview!),
                          isUrgent: DateTime.now().isAfter(book.deadlineReview!.subtract(const Duration(days: 1))),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Sinopsis
            Text(
              'Sinopsis:',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.sinopsis,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryDark,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isUrgent = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isUrgent ? AppTheme.errorRed : AppTheme.greyMedium,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodySmall.copyWith(
                color: isUrgent ? AppTheme.errorRed : AppTheme.primaryDark,
                fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataInfo() {
    final metadata = _detailBuku!.metadata;
    final keywords = _detailBuku!.tagKeyword;

    return Card(
      elevation: 2,
      color: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Tambahan',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            
            // Metadata grid
            Row(
              children: [
                Expanded(
                  child: _buildMetadataCard(
                    'Waktu Baca',
                    metadata['readingTime'] ?? '-',
                    Icons.schedule,
                    AppTheme.googleBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetadataCard(
                    'Kompleksitas',
                    metadata['complexity'] ?? '-',
                    Icons.analytics,
                    AppTheme.googleYellow.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetadataCard(
                    'Estimasi Review',
                    metadata['estimatedReviewTime'] ?? '-',
                    Icons.timer,
                    AppTheme.googleGreen,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Keywords
            if (keywords.isNotEmpty) ...[
              Text(
                'Kata Kunci:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: keywords.map((keyword) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    keyword,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyMedium,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatReview() {
    final riwayat = _detailBuku!.riwayatReview;
    
    if (riwayat.isEmpty) return Container();

    return Card(
      elevation: 2,
      color: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Review (${riwayat.length})',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            
            ...riwayat.map((review) => _buildRiwayatItem(review)),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatItem(RiwayatReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.namaEditor,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryDark,
                ),
              ),
              Text(
                _formatDate(review.tanggal),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyMedium,
                ),
              ),
            ],
          ),
          
          if (review.catatan != null) ...[
            const SizedBox(height: 8),
            Text(
              review.catatan!,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryDark,
                height: 1.4,
              ),
            ),
          ],
          
          if (review.rekomendasi != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRekomendasiColor(review.rekomendasi!).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRekomendasiIcon(review.rekomendasi!),
                    size: 16,
                    color: _getRekomendasiColor(review.rekomendasi!),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getRekomendasiLabel(review.rekomendasi!),
                    style: AppTheme.bodySmall.copyWith(
                      color: _getRekomendasiColor(review.rekomendasi!),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewForm() {
    final canSubmitReview = widget.book.status == 'belum_ditugaskan' || 
                           widget.book.status == 'ditugaskan' || 
                           widget.book.status == 'dalam_review';
                           
    return Card(
      elevation: 2,
      color: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan Review',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 16),

            if (!canSubmitReview) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.greyMedium.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.greyMedium.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.greyMedium,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Review untuk buku ini sudah selesai',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Rekomendasi
              Text(
                'Rekomendasi:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildRekomendasiOption('setujui', 'Setujui', Icons.check_circle, AppTheme.googleGreen),
                  const SizedBox(width: 8),
                  _buildRekomendasiOption('revisi', 'Perlu Revisi', Icons.edit, AppTheme.googleYellow.withValues(alpha: 0.8)),
                  const SizedBox(width: 8),
                  _buildRekomendasiOption('tolak', 'Tolak', Icons.cancel, AppTheme.errorRed),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Rating
              Text(
                'Rating (1-5):',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                    },
                    child: Icon(
                      index < _selectedRating ? Icons.star : Icons.star_border,
                      color: AppTheme.googleYellow.withValues(alpha: 0.8),
                      size: 32,
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 16),
              
              // Catatan Review
              Text(
                'Catatan Review:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _catatanController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tuliskan catatan review Anda...',
                  hintStyle: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.greyDisabled),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.primaryGreen),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Feedback Detail
              Text(
                'Feedback Detail (Opsional):',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pisahkan setiap feedback dengan baris baru',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyMedium,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh:\nBagian dialog perlu diperbaiki\nAlur cerita terlalu cepat di bab 3',
                  hintStyle: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.greyDisabled),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.primaryGreen),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: AppTheme.primaryButtonStyle.copyWith(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.white,
                          ),
                        )
                      : const Text('Submit Review'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRekomendasiOption(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedRekomendasi == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRekomendasi = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : AppTheme.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : AppTheme.greyDisabled,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppTheme.greyMedium,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: isSelected ? color : AppTheme.greyMedium,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
            'Memuat detail buku...',
            style: AppTheme.bodyMedium,
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
              'Terjadi Kesalahan',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.errorRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Tidak dapat memuat detail buku',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDetailBuku,
              style: AppTheme.primaryButtonStyle,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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
        return AppTheme.googleGreen;
      case 'revisi':
        return AppTheme.googleYellow.withValues(alpha: 0.8);
      case 'tolak':
        return AppTheme.errorRed;
      default:
        return AppTheme.greyMedium;
    }
  }

  String _getRekomendasiLabel(String rekomendasi) {
    switch (rekomendasi.toLowerCase()) {
      case 'setujui':
        return 'Disetujui';
      case 'revisi':
        return 'Perlu Revisi';
      case 'tolak':
        return 'Ditolak';
      default:
        return 'Tidak Diketahui';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else {
      final futureDays = date.difference(now).inDays;
      if (futureDays == 1) {
        return 'Besok';
      } else {
        return '${futureDays} hari lagi';
      }
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }
}