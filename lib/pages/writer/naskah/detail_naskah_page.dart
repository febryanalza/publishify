import 'package:flutter/material.dart';
import 'package:publishify/models/writer/naskah_models.dart';
import 'package:publishify/pages/writer/naskah/edit_naskah_page.dart';
import 'package:publishify/services/writer/naskah_service.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/widgets/network_image_widget.dart';

class DetailNaskahPage extends StatefulWidget {
  final String naskahId;

  const DetailNaskahPage({super.key, required this.naskahId});

  @override
  State<DetailNaskahPage> createState() => _DetailNaskahPageState();
}

class _DetailNaskahPageState extends State<DetailNaskahPage> {
  NaskahDetail? naskah;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDetailNaskah();
  }

  Future<void> _loadDetailNaskah() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await NaskahService.ambilDetailNaskah(widget.naskahId);
      
      if (response.sukses && response.data != null) {
        setState(() {
          naskah = response.data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = response.pesan;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppTheme.greyMedium;
      case 'diajukan':
        return AppTheme.googleBlue;
      case 'dalam_review':
        return AppTheme.googleYellow;
      case 'perlu_revisi':
        return AppTheme.googleRed;
      case 'disetujui':
        return AppTheme.googleGreen;
      case 'diterbitkan':
        return AppTheme.primaryGreen;
      case 'ditolak':
        return AppTheme.errorRed;
      default:
        return AppTheme.greyMedium;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'diajukan':
        return 'Diajukan';
      case 'dalam_review':
        return 'Dalam Review';
      case 'perlu_revisi':
        return 'Perlu Revisi';
      case 'disetujui':
        return 'Disetujui';
      case 'diterbitkan':
        return 'Diterbitkan';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryDark),
        ),
        title: const Text(
          'Detail Naskah',
          style: AppTheme.headingMedium,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            )
          : error != null
              ? _buildErrorState()
              : naskah != null
                  ? _buildContent()
                  : const Center(
                      child: Text(
                        'Data tidak ditemukan',
                        style: AppTheme.bodyMedium,
                      ),
                    ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            'Terjadi Kesalahan',
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error ?? 'Gagal memuat detail naskah',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDetailNaskah,
            style: AppTheme.primaryButtonStyle,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (naskah == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan cover dan info dasar
          _buildHeader(),
          const SizedBox(height: 24),
          
          // Tombol Ajukan Review (hanya untuk draft atau perlu_revisi)
          if (_canAjukan()) ...[
            _buildAjukanButton(),
            const SizedBox(height: 24),
          ],

          // Informasi detail
          _buildDetailInfo(),
          const SizedBox(height: 24),

          // Sinopsis
          _buildSinopsis(),
          const SizedBox(height: 24),

          // Informasi penulis
          _buildPenulisInfo(),
          const SizedBox(height: 24),

          // Riwayat revisi
          if (naskah!.revisi.isNotEmpty) ...[
            _buildRevisiSection(),
            const SizedBox(height: 24),
          ],

          // Review
          if (naskah!.review.isNotEmpty) ...[
            _buildReviewSection(),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
  
  /// Cek apakah naskah bisa diajukan
  bool _canAjukan() {
    if (naskah == null) return false;
    final status = naskah!.status.toLowerCase();
    return status == 'draft' || status == 'perlu_revisi';
  }
  
  /// Tombol untuk mengajukan naskah ke editor
  Widget _buildAjukanButton() {
    return Card(
      elevation: 2,
      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.send_outlined,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajukan untuk Review',
                        style: AppTheme.headingSmall.copyWith(
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kirim naskah Anda ke editor untuk direview',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyText,
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
                  child: OutlinedButton.icon(
                    onPressed: _editNaskah,
                    icon: const Icon(Icons.edit, color: AppTheme.googleBlue),
                    label: const Text(
                      'Edit Data',
                      style: TextStyle(
                        color: AppTheme.googleBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.googleBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _ajukanNaskah,
                    icon: const Icon(Icons.send, color: AppTheme.white),
                    label: const Text(
                      'Ajukan',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Method untuk navigasi ke halaman edit naskah
  Future<void> _editNaskah() async {
    if (naskah == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNaskahPage(naskah: naskah!),
      ),
    );

    // Jika edit berhasil, reload data
    if (result == true) {
      _loadDetailNaskah();
    }
  }

  /// Method untuk mengajukan naskah
  Future<void> _ajukanNaskah() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajukan Naskah'),
        content: const Text(
          'Apakah Anda yakin ingin mengajukan naskah ini untuk direview oleh editor?\n\n'
          'Setelah diajukan, naskah akan masuk ke antrian review.',
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
            child: const Text('Ajukan', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    if (!mounted) return;
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      ),
    );
    
    try {
      final response = await NaskahService.ajukanNaskah(widget.naskahId);
      
      // Hide loading
      if (mounted) Navigator.pop(context);
      
      if (response.sukses) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Naskah berhasil diajukan untuk review'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          // Reload detail to refresh status
          _loadDetailNaskah();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      color: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover naskah
            Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.greyLight,
              ),
              child: naskah!.urlSampul != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: NetworkImageWidget(
                        imageUrl: naskah!.urlSampul!,
                        width: 100,
                        height: 140,
                      ),
                    )
                  : const Icon(
                      Icons.book,
                      size: 40,
                      color: AppTheme.greyMedium,
                    ),
            ),
            const SizedBox(width: 16),
            
            // Info dasar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    naskah!.judul,
                    style: AppTheme.headingSmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (naskah!.subJudul != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      naskah!.subJudul!,
                      style: AppTheme.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(naskah!.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusLabel(naskah!.status),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Kategori dan genre
                  Text(
                    '${naskah!.kategori.nama} • ${naskah!.genre.nama}',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailInfo() {
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
            const Text(
              'Informasi Detail',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 16),
            
            if (naskah!.isbn != null)
              _buildInfoRow('ISBN', naskah!.isbn!),
            
            if (naskah!.jumlahHalaman != null)
              _buildInfoRow('Jumlah Halaman', '${naskah!.jumlahHalaman} halaman'),
            
            if (naskah!.jumlahKata != null)
              _buildInfoRow('Jumlah Kata', '${naskah!.jumlahKata} kata'),
            
            _buildInfoRow('Bahasa', naskah!.bahasaTulis == 'id' ? 'Bahasa Indonesia' : naskah!.bahasaTulis),
            _buildInfoRow('Visibilitas', naskah!.publik ? 'Publik' : 'Pribadi'),
            _buildInfoRow('Dibuat', _formatDate(naskah!.dibuatPada)),
            
            if (naskah!.diperbaruiPada != naskah!.dibuatPada)
              _buildInfoRow('Terakhir Diperbarui', _formatDate(naskah!.diperbaruiPada)),
          ],
        ),
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
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinopsis() {
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
            const Text(
              'Sinopsis',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Text(
              naskah!.sinopsis,
              style: AppTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenulisInfo() {
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
            const Text(
              'Informasi Penulis',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                // Avatar penulis
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.greyLight,
                  ),
                  child: naskah!.penulis.profilPengguna?.urlAvatar != null
                      ? ClipOval(
                          child: NetworkImageWidget(
                            imageUrl: naskah!.penulis.profilPengguna!.urlAvatar!,
                            width: 50,
                            height: 50,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: AppTheme.greyMedium,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 12),
                
                // Nama dan email penulis
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        naskah!.penulis.profilPengguna?.namaLengkap ?? 'Penulis Anonim',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        naskah!.penulis.email,
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevisiSection() {
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
              'Riwayat Revisi (${naskah!.revisi.length})',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 16),
            
            ...naskah!.revisi.map((revisi) => _buildRevisiItem(revisi)),
          ],
        ),
      ),
    );
  }

  Widget _buildRevisiItem(RevisiNaskah revisi) {
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
                'Versi ${revisi.versi}',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDate(revisi.dibuatPada),
                style: AppTheme.bodySmall,
              ),
            ],
          ),
          if (revisi.catatan.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              revisi.catatan,
              style: AppTheme.bodyMedium,
            ),
          ],
          if (revisi.urlFile != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.attach_file,
                  size: 16,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  'File tersedia',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
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
              'Riwayat Review (${naskah!.review.length})',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 16),
            
            ...naskah!.review.map((review) => _buildReviewItem(review)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(ReviewNaskah review) {
    Color statusColor = AppTheme.greyMedium;
    switch (review.status.toLowerCase()) {
      case 'ditugaskan':
        statusColor = AppTheme.googleBlue;
        break;
      case 'dalam_proses':
        statusColor = AppTheme.googleYellow;
        break;
      case 'selesai':
        statusColor = AppTheme.googleGreen;
        break;
      case 'dibatalkan':
        statusColor = AppTheme.errorRed;
        break;
    }

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  review.status.replaceAll('_', ' ').toUpperCase(),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatDate(review.dibuatPada),
                style: AppTheme.bodySmall,
              ),
            ],
          ),
          
          if (review.editor != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: AppTheme.primaryDark,
                ),
                const SizedBox(width: 4),
                Text(
                  'Editor: ${review.editor!.profilPengguna?.namaLengkap ?? review.editor!.email}',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ],
          
          if (review.rekomendasi != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.recommend,
                  size: 16,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  'Rekomendasi: ${review.rekomendasi}',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          
          if (review.catatan != null) ...[
            const SizedBox(height: 8),
            Text(
              review.catatan!,
              style: AppTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}