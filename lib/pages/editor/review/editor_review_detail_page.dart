import 'package:flutter/material.dart';
import '../../../models/editor/review_models.dart';
import '../../../services/editor/review_service.dart';
import '../../../utils/theme.dart';

class EditorReviewDetailPage extends StatefulWidget {
  final String reviewId;

  const EditorReviewDetailPage({
    super.key,
    required this.reviewId,
  });

  @override
  State<EditorReviewDetailPage> createState() => _EditorReviewDetailPageState();
}

class _EditorReviewDetailPageState extends State<EditorReviewDetailPage> {
  bool _isLoading = true;
  bool _isUpdating = false;
  ReviewNaskah? _review;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReviewDetail();
  }

  Future<void> _loadReviewDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await EditorReviewService.getReviewById(widget.reviewId);
      
      if (response.sukses && response.data != null) {
        setState(() {
          _review = response.data;
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

  Future<void> _terimaReview() async {
    // Tampilkan dialog konfirmasi
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Terima Naskah',
          style: AppTheme.headingSmall,
        ),
        content: const Text(
          'Apakah Anda yakin ingin menerima naskah ini untuk direview?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Ya, Terima'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final response = await EditorReviewService.mulaiReview(
        idReview: widget.reviewId,
        catatan: 'Naskah diterima untuk direview',
      );

      if (response.sukses && response.data != null) {
        if (mounted) {
          // Update UI dengan data terbaru
          setState(() {
            _review = response.data;
            _isUpdating = false;
          });

          // Tampilkan snackbar sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Naskah berhasil diterima'),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Kembali ke halaman sebelumnya setelah 1 detik
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context, true); // Return true untuk refresh list
            }
          });
        }
      } else {
        setState(() {
          _isUpdating = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    
    // Format manual tanpa package intl
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  Color _getStatusColor(StatusReview status) {
    switch (status) {
      case StatusReview.ditugaskan:
        return AppTheme.yellow;
      case StatusReview.dalam_proses:
        return Colors.blue;
      case StatusReview.selesai:
        return AppTheme.primaryGreen;
      case StatusReview.dibatalkan:
        return AppTheme.errorRed;
    }
  }

  String _getStatusLabel(StatusReview status) {
    switch (status) {
      case StatusReview.ditugaskan:
        return 'Ditugaskan';
      case StatusReview.dalam_proses:
        return 'Dalam Proses';
      case StatusReview.selesai:
        return 'Selesai';
      case StatusReview.dibatalkan:
        return 'Dibatalkan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        title: Text(
          'Detail Review Naskah',
          style: AppTheme.headingMedium.copyWith(
            color: AppTheme.white,
            fontSize: 20,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.errorRed,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadReviewDetail,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _review == null
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_review!.status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatusLabel(_review!.status),
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Informasi Naskah
                              _buildSectionCard(
                                title: 'Informasi Naskah',
                                children: [
                                  _buildInfoRow(
                                    'Judul',
                                    _review!.naskah.judul,
                                  ),
                                  if (_review!.naskah.subJudul != null)
                                    _buildInfoRow(
                                      'Sub Judul',
                                      _review!.naskah.subJudul!,
                                    ),
                                  if (_review!.naskah.penulis != null)
                                    _buildInfoRow(
                                      'Penulis',
                                      _review!.naskah.penulis!.profilPengguna?.namaLengkap ?? 
                                      _review!.naskah.penulis!.email,
                                    ),
                                  if (_review!.naskah.kategori != null)
                                    _buildInfoRow(
                                      'Kategori',
                                      _review!.naskah.kategori!.nama,
                                    ),
                                  if (_review!.naskah.genre != null)
                                    _buildInfoRow(
                                      'Genre',
                                      _review!.naskah.genre!.nama,
                                    ),
                                  if (_review!.naskah.jumlahHalaman != null)
                                    _buildInfoRow(
                                      'Jumlah Halaman',
                                      '${_review!.naskah.jumlahHalaman} halaman',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Sinopsis
                              _buildSectionCard(
                                title: 'Sinopsis',
                                children: [
                                  Text(
                                    _review!.naskah.sinopsis ?? 'Tidak ada sinopsis',
                                    style: AppTheme.bodyLarge.copyWith(
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Informasi Review
                              _buildSectionCard(
                                title: 'Informasi Review',
                                children: [
                                  _buildInfoRow(
                                    'Ditugaskan Pada',
                                    _formatDate(_review!.ditugaskanPada),
                                  ),
                                  if (_review!.dimulaiPada != null)
                                    _buildInfoRow(
                                      'Dimulai Pada',
                                      _formatDate(_review!.dimulaiPada),
                                    ),
                                  if (_review!.selesaiPada != null)
                                    _buildInfoRow(
                                      'Selesai Pada',
                                      _formatDate(_review!.selesaiPada),
                                    ),
                                  if (_review!.catatan != null)
                                    _buildInfoRow(
                                      'Catatan',
                                      _review!.catatan!,
                                    ),
                                  if (_review!.rekomendasi != null)
                                    _buildInfoRow(
                                      'Rekomendasi',
                                      _formatRekomendasi(_review!.rekomendasi!),
                                    ),
                                ],
                              ),

                              // Feedback List (if any)
                              if (_review!.feedback.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildSectionCard(
                                  title: 'Feedback Review',
                                  children: [
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _review!.feedback.length,
                                      separatorBuilder: (context, index) => 
                                          const Divider(height: 24),
                                      itemBuilder: (context, index) {
                                        final fb = _review!.feedback[index];
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (fb.bab != null)
                                              Text(
                                                'Bab: ${fb.bab}',
                                                style: AppTheme.headingSmall.copyWith(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            if (fb.halaman != null)
                                              Text(
                                                'Halaman: ${fb.halaman}',
                                                style: AppTheme.bodyLarge.copyWith(
                                                  fontSize: 14,
                                                  color: AppTheme.greyText,
                                                ),
                                              ),
                                            const SizedBox(height: 8),
                                            Text(
                                              fb.komentar,
                                              style: AppTheme.bodyLarge.copyWith(
                                                color: AppTheme.greyText,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _formatDate(fb.dibuatPada),
                                              style: AppTheme.bodyLarge.copyWith(
                                                fontSize: 12,
                                                color: AppTheme.greyText,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],

                              // Spacing untuk tombol
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),

                        // Fixed Button at Bottom
                        if (_review!.status == StatusReview.ditugaskan)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isUpdating ? null : _terimaReview,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: AppTheme.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isUpdating
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check_circle),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Terima Naskah',
                                            style: AppTheme.headingSmall.copyWith(
                                              color: AppTheme.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.greyText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRekomendasi(Rekomendasi rekomendasi) {
    switch (rekomendasi) {
      case Rekomendasi.setujui:
        return 'Setujui';
      case Rekomendasi.revisi:
        return 'Perlu Revisi';
      case Rekomendasi.tolak:
        return 'Tolak';
    }
  }
}
