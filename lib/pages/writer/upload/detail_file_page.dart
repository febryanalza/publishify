import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/upload_models.dart';
import 'package:publishify/services/writer/upload_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Halaman untuk melihat detail file
class DetailFilePage extends StatefulWidget {
  final String fileId;

  const DetailFilePage({super.key, required this.fileId});

  @override
  State<DetailFilePage> createState() => _DetailFilePageState();
}

class _DetailFilePageState extends State<DetailFilePage> {
  bool _isLoading = true;
  String? _errorMessage;
  FileMetadataResponse? _metadata;
  
  // Image processing state
  bool _isProcessing = false;
  ImagePreset? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _loadFileMetadata();
  }

  Future<void> _loadFileMetadata() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await UploadService.getFileMetadata(widget.fileId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.sukses && response.data != null) {
          _metadata = response;
        } else {
          _errorMessage = response.pesan;
        }
      });
    }
  }

  Future<void> _downloadFile() async {
    if (_metadata?.data == null) return;
    
    final url = UploadService.buildFileUrl(_metadata!.data!.url);
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka file'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _deleteFile() async {
    if (_metadata?.data == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_forever, color: AppTheme.errorRed),
            ),
            const SizedBox(width: 12),
            const Text('Hapus File'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus file ini?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
              ),
              child: Text(
                '⚠️ Tindakan ini tidak dapat dibatalkan.',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.errorRed),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          ),
        );
      }

      final response = await UploadService.deleteFile(widget.fileId);

      // Hide loading
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.pesan),
            backgroundColor: response.sukses ? AppTheme.primaryGreen : AppTheme.errorRed,
          ),
        );

        if (response.sukses) {
          Navigator.pop(context, true); // Return to list with refresh
        }
      }
    }
  }

  Future<void> _processImage(ImagePreset preset) async {
    if (_metadata?.data == null) return;

    setState(() {
      _isProcessing = true;
      _selectedPreset = preset;
    });

    final response = await UploadService.processImageWithPreset(
      fileId: widget.fileId,
      preset: preset,
    );

    if (mounted) {
      setState(() => _isProcessing = false);

      if (response.sukses && response.data != null) {
        _showProcessedImageDialog(response.data!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.pesan),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showProcessedImageDialog(FileInfo processedFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle, color: AppTheme.primaryGreen),
            ),
            const SizedBox(width: 12),
            const Text('Berhasil Diproses'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gambar berhasil diproses dengan preset yang dipilih.'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.greyLight),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  UploadService.buildFileUrl(processedFile.url),
                  fit: BoxFit.contain,
                  height: 200,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppTheme.primaryGreen,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 48, color: AppTheme.greyMedium),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Nama File', processedFile.namaFileAsli),
            _buildInfoRow('Ukuran', processedFile.ukuranFormatted),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final url = UploadService.buildFileUrl(processedFile.url);
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            style: AppTheme.primaryButtonStyle,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _copyUrl() {
    if (_metadata?.data == null) return;
    
    final url = UploadService.buildFileUrl(_metadata!.data!.url);
    Clipboard.setData(ClipboardData(text: url));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL berhasil disalin'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
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
          'Detail File',
          style: AppTheme.headingMedium,
        ),
        centerTitle: true,
        actions: [
          if (_metadata?.data != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'download':
                    _downloadFile();
                    break;
                  case 'copy':
                    _copyUrl();
                    break;
                  case 'delete':
                    _deleteFile();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 20),
                      SizedBox(width: 12),
                      Text('Download'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 20),
                      SizedBox(width: 12),
                      Text('Salin URL'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: AppTheme.errorRed),
                      const SizedBox(width: 12),
                      Text('Hapus', style: TextStyle(color: AppTheme.errorRed)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryGreen),
          SizedBox(height: 16),
          Text('Memuat detail file...', style: TextStyle(color: AppTheme.greyMedium)),
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
              onPressed: _loadFileMetadata,
              style: AppTheme.primaryButtonStyle,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final file = _metadata!.data!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview Section
          _buildPreviewSection(file),
          const SizedBox(height: 24),
          
          // File Info Section
          _buildFileInfoSection(file),
          const SizedBox(height: 24),
          
          // Owner Info Section
          if (file.pengguna != null) ...[
            _buildOwnerInfoSection(file.pengguna!),
            const SizedBox(height: 24),
          ],
          
          // Image Processing Section (if image)
          if (file.isImage) ...[
            _buildImageProcessingSection(),
            const SizedBox(height: 24),
          ],
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(FileInfo file) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: file.isImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  UploadService.buildFileUrl(file.url),
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppTheme.primaryGreen,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _buildFileIconPreview(file),
                ),
              )
            : _buildFileIconPreview(file),
      ),
    );
  }

  Widget _buildFileIconPreview(FileInfo file) {
    IconData icon;
    Color color;
    
    if (file.isPdf) {
      icon = Icons.picture_as_pdf;
      color = AppTheme.googleRed;
    } else if (file.isWord) {
      icon = Icons.description;
      color = AppTheme.googleBlue;
    } else {
      icon = Icons.insert_drive_file;
      color = AppTheme.greyMedium;
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 72, color: color),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            file.namaFileAsli,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFileInfoSection(FileInfo file) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi File',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryDark),
            ),
            const Divider(height: 24),
            _buildInfoRow('Nama File', file.namaFileAsli),
            _buildInfoRow('Tipe', file.tujuanEnum.label),
            _buildInfoRow('Ukuran', file.ukuranFormatted),
            _buildInfoRow('Format', file.mimeType),
            _buildInfoRow('Ekstensi', file.ekstensi.isEmpty ? '-' : file.ekstensi),
            _buildInfoRow('Tanggal Upload', _formatDateTime(file.diuploadPada)),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerInfoSection(PenggunaInfo pengguna) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Pemilik',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryDark),
            ),
            const Divider(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  backgroundImage: pengguna.profilPengguna?.urlAvatar != null
                      ? NetworkImage(pengguna.profilPengguna!.urlAvatar!)
                      : null,
                  child: pengguna.profilPengguna?.urlAvatar == null
                      ? Icon(Icons.person, color: AppTheme.primaryGreen)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pengguna.namaLengkap,
                        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        pengguna.email,
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

  Widget _buildImageProcessingSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proses Gambar',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Ubah ukuran gambar dengan preset yang tersedia',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ImagePreset.values.map((preset) {
                final isSelected = _selectedPreset == preset && _isProcessing;
                return ElevatedButton(
                  onPressed: _isProcessing ? null : () => _processImage(preset),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppTheme.primaryGreen
                        : AppTheme.backgroundLight,
                    foregroundColor: isSelected
                        ? AppTheme.white
                        : AppTheme.primaryDark,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryGreen : AppTheme.greyLight,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(right: 8),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.white,
                          ),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Icon(_getPresetIcon(preset), size: 16),
                        ),
                      Text(preset.label),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPresetIcon(ImagePreset preset) {
    switch (preset) {
      case ImagePreset.thumbnail:
        return Icons.photo_size_select_small;
      case ImagePreset.sampulKecil:
        return Icons.photo_size_select_actual;
      case ImagePreset.sampulBesar:
        return Icons.photo_size_select_large;
      case ImagePreset.banner:
        return Icons.panorama;
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _copyUrl,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Salin URL'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _downloadFile,
            style: AppTheme.primaryButtonStyle.copyWith(
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14)),
            ),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
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

  String _formatDateTime(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
