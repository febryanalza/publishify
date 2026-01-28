import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/editor/review_naskah_models.dart';
import 'package:publishify/services/editor/unified_review_service.dart';
import 'package:publishify/widgets/naskah_action_dialogs.dart';

/// Halaman detail naskah yang akan direview
class DetailReviewNaskahPage extends StatefulWidget {
  final String naskahId;

  const DetailReviewNaskahPage({
    super.key,
    required this.naskahId,
  });

  @override
  State<DetailReviewNaskahPage> createState() => _DetailReviewNaskahPageState();
}

class _DetailReviewNaskahPageState extends State<DetailReviewNaskahPage> {
  DetailNaskahSubmission? _detailNaskah;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await UnifiedReviewService.getDetailNaskah(widget.naskahId);
      
      if (response.sukses && response.data != null) {
        setState(() {
          _detailNaskah = response.data!;
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

  Future<void> _downloadNaskah() async {
    // TODO: Implementasi download file naskah
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur download akan segera tersedia'),
      ),
    );
  }

  Future<void> _previewNaskah() async {
    // TODO: Implementasi preview naskah dalam app
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur preview akan segera tersedia'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Detail Naskah'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _detailNaskah != null
                  ? _buildDetailContent()
                  : _buildEmptyState(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryGreen),
          SizedBox(height: 16),
          Text('Memuat detail naskah...', style: TextStyle(color: AppTheme.greyMedium)),
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
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadDetail,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('Detail naskah tidak ditemukan'),
    );
  }

  Widget _buildDetailContent() {
    final naskah = _detailNaskah!.naskah;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan sampul dan info dasar
          _buildHeaderSection(naskah),
          
          // Info detail naskah
          _buildInfoSection(naskah),
          
          // Sinopsis
          _buildSinopsisSection(naskah),
          
          // Metadata tambahan
          _buildMetadataSection(),
          
          // Riwayat review
          _buildRiwayatSection(),
          
          // Komentar review
          _buildKomentarSection(),
          
          // Action buttons
          _buildActionButtons(naskah),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(NaskahSubmission naskah) {
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sampul buku
              Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    naskah.urlSampul ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.greyLight,
                        child: const Icon(
                          Icons.book,
                          size: 48,
                          color: AppTheme.greyMedium,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Info dasar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      naskah.judul,
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    if (naskah.subJudul?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(
                        naskah.subJudul ?? '',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.white.withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'oleh ${naskah.namaPenulis}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Status dan prioritas
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            naskah.statusLabel,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            naskah.prioritasLabel,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(NaskahSubmission naskah) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Naskah',
            style: AppTheme.headingSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow('Kategori', '${naskah.kategori} • ${naskah.genre}'),
          _buildInfoRow('Jumlah Halaman', '${naskah.jumlahHalaman} halaman'),
          _buildInfoRow('Jumlah Kata', '${_formatNumber(naskah.jumlahKata)} kata'),
          _buildInfoRow('Bahasa', naskah.bahasaTulis),
          _buildInfoRow('Email Penulis', naskah.emailPenulis),
          _buildInfoRow('Tanggal Submit', _formatTanggalLengkap(naskah.tanggalSubmit)),
          
          if (naskah.namaEditorDitugaskan != null) ...[
            _buildInfoRow('Editor Ditugaskan', naskah.namaEditorDitugaskan!),
            if (naskah.tanggalDitugaskan != null)
              _buildInfoRow('Tanggal Ditugaskan', _formatTanggalLengkap(naskah.tanggalDitugaskan!)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinopsisSection(NaskahSubmission naskah) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sinopsis',
            style: AppTheme.headingSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            naskah.sinopsis,
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
    if (_detailNaskah!.metadata.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metadata Tambahan',
            style: AppTheme.headingSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildMetadataItem(
                  Icons.download,
                  'Total Download',
                  '${_detailNaskah!.metadata['total_download'] ?? 0}',
                ),
              ),
              Expanded(
                child: _buildMetadataItem(
                  Icons.star,
                  'Rating',
                  '${_detailNaskah!.metadata['rata_rata_rating'] ?? 0}',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          _buildMetadataItem(
            Icons.schedule,
            'Estimasi Review',
            _detailNaskah!.metadata['estimasi_review'] ?? 'Belum ditentukan',
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(IconData icon, String label, String value, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.greyMedium),
          const SizedBox(width: 8),
          if (!fullWidth) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
                  ),
                  Text(
                    value,
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiwayatSection() {
    if (_detailNaskah!.riwayatReview.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Review',
            style: AppTheme.headingSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          ..._detailNaskah!.riwayatReview.map((riwayat) => _buildRiwayatItem(riwayat)),
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(RiwayatReview riwayat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.greyLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  riwayat.aksiLabel,
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                _formatTanggalLengkap(riwayat.tanggal),
                style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'oleh ${riwayat.namaEditor}',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
          ),
          if (riwayat.catatan != null && riwayat.catatan!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              riwayat.catatan!,
              style: AppTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKomentarSection() {
    if (_detailNaskah!.komentar.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komentar Review',
            style: AppTheme.headingSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          ..._detailNaskah!.komentar.map((komentar) => _buildKomentarItem(komentar)),
        ],
      ),
    );
  }

  Widget _buildKomentarItem(KomentarReview komentar) {
    Color tipeColor;
    IconData tipeIcon;
    
    switch (komentar.tipe.toLowerCase()) {
      case 'saran':
        tipeColor = Colors.blue;
        tipeIcon = Icons.lightbulb_outline;
        break;
      case 'koreksi':
        tipeColor = Colors.orange;
        tipeIcon = Icons.edit;
        break;
      case 'catatan':
      default:
        tipeColor = AppTheme.primaryGreen;
        tipeIcon = Icons.note;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tipeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tipeColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tipeIcon, size: 16, color: tipeColor),
              const SizedBox(width: 6),
              Text(
                komentar.tipe.toUpperCase(),
                style: AppTheme.bodySmall.copyWith(
                  color: tipeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                _formatTanggalLengkap(komentar.tanggal),
                style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            komentar.komentar,
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'oleh ${komentar.namaEditor}',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(NaskahSubmission naskah) {
    final isSiapTerbit = naskah.status == 'siap_terbit';
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _previewNaskah,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Preview'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _downloadNaskah,
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          if (naskah.status == 'menunggu_review') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _terimaReview(naskah),
                icon: const Icon(Icons.check),
                label: const Text('Terima Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          
          // Tombol Ubah Status (untuk semua status kecuali diterbitkan)
          if (naskah.status != 'diterbitkan') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _ubahStatusNaskah(naskah),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Ubah Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          
          // Tombol Terbitkan (hanya untuk status siap_terbit)
          if (isSiapTerbit) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _terbitkanNaskah(naskah),
                icon: const Icon(Icons.publish),
                label: const Text('Terbitkan Naskah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Method untuk menampilkan dialog ubah status naskah
  void _ubahStatusNaskah(NaskahSubmission naskah) {
    showUbahStatusNaskahDialog(
      context,
      naskahId: naskah.id,
      judulNaskah: naskah.judul,
      statusSaatIni: naskah.status,
      onResult: (sukses, pesan, statusBaru) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pesan),
            backgroundColor: sukses ? AppTheme.primaryGreen : AppTheme.errorRed,
          ),
        );
        if (sukses) {
          _loadDetail(); // Reload detail untuk refresh data
        }
      },
    );
  }
  
  /// Method untuk menampilkan dialog terbitkan naskah
  void _terbitkanNaskah(NaskahSubmission naskah) {
    showTerbitkanNaskahDialog(
      context,
      naskahId: naskah.id,
      judulNaskah: naskah.judul,
      jumlahHalamanSaatIni: naskah.jumlahHalaman,
      onResult: (sukses, pesan) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pesan),
            backgroundColor: sukses ? AppTheme.primaryGreen : AppTheme.errorRed,
          ),
        );
        if (sukses) {
          _loadDetail(); // Reload detail untuk refresh data
        }
      },
    );
  }

  Future<void> _terimaReview(NaskahSubmission naskah) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin menerima review naskah "${naskah.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Ya, Terima'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await UnifiedReviewService.terimaReview(
          naskah.id,
          'current_editor_id', // TODO: Ambil dari auth
        );

        if (!mounted) return;

        if (response.sukses) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.pesan)),
          );
          _loadDetail(); // Reload detail
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  String _formatTanggalLengkap(DateTime tanggal) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${tanggal.day} ${months[tanggal.month - 1]} ${tanggal.year}';
  }
}