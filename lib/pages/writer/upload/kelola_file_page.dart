import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/upload_models.dart';
import 'package:publishify/services/writer/upload_service.dart';
import 'package:publishify/pages/writer/upload/detail_file_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Halaman untuk mengelola file yang sudah diupload
class KelolaFilePage extends StatefulWidget {
  const KelolaFilePage({super.key});

  @override
  State<KelolaFilePage> createState() => _KelolaFilePageState();
}

class _KelolaFilePageState extends State<KelolaFilePage> {
  // State
  List<FileInfo> _files = [];
  bool _isLoading = true;
  String? _errorMessage;
  PaginationMetadata? _metadata;
  
  // Filter & Pagination
  int _currentPage = 1;
  String? _selectedTujuan;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  
  // Tujuan filter options
  final List<Map<String, String>> _tujuanOptions = [
    {'value': '', 'label': 'Semua'},
    {'value': 'naskah', 'label': 'Naskah'},
    {'value': 'sampul', 'label': 'Sampul'},
    {'value': 'gambar', 'label': 'Gambar'},
    {'value': 'dokumen', 'label': 'Dokumen'},
  ];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await UploadService.getDaftarFile(
      halaman: _currentPage,
      limit: 20,
      tujuan: _selectedTujuan,
      cari: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.sukses) {
          _files = response.data;
          _metadata = response.metadata;
        } else {
          _errorMessage = response.pesan;
        }
      });
    }
  }

  Future<void> _deleteFile(FileInfo file) async {
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
            Text('Apakah Anda yakin ingin menghapus file ini?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(file),
                    color: AppTheme.primaryGreen,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.namaFileAsli,
                          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          file.ukuranFormatted,
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
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

      final response = await UploadService.deleteFile(file.id);

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
          _loadFiles(); // Reload data
        }
      }
    }
  }

  Future<void> _downloadFile(FileInfo file) async {
    final url = UploadService.buildFileUrl(file.url);
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

  void _viewFileDetail(FileInfo file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailFilePage(fileId: file.id),
      ),
    ).then((_) => _loadFiles()); // Reload when returning
  }

  void _onSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _currentPage = 1;
    });
    _loadFiles();
  }

  void _onFilterChanged(String? value) {
    setState(() {
      _selectedTujuan = value?.isEmpty == true ? null : value;
      _currentPage = 1;
    });
    _loadFiles();
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _loadFiles();
  }

  IconData _getFileIcon(FileInfo file) {
    if (file.isImage) return Icons.image;
    if (file.isPdf) return Icons.picture_as_pdf;
    if (file.isWord) return Icons.description;
    
    switch (file.tujuan) {
      case 'naskah':
        return Icons.menu_book;
      case 'sampul':
        return Icons.photo_library;
      case 'gambar':
        return Icons.image;
      case 'dokumen':
        return Icons.insert_drive_file;
      default:
        return Icons.attach_file;
    }
  }

  Color _getTujuanColor(String tujuan) {
    switch (tujuan) {
      case 'naskah':
        return AppTheme.googleBlue;
      case 'sampul':
        return AppTheme.googleGreen;
      case 'gambar':
        return AppTheme.googleYellow;
      case 'dokumen':
        return AppTheme.googleRed;
      default:
        return AppTheme.greyMedium;
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
          'Kelola File',
          style: AppTheme.headingMedium,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search & Filter Section
          _buildSearchFilterSection(),
          
          // Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _files.isEmpty
                        ? _buildEmptyState()
                        : _buildFileList(),
          ),
          
          // Pagination
          if (_metadata != null && _metadata!.totalHalaman > 1)
            _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: AppTheme.inputDecoration(
                    hintText: 'Cari file...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.greyMedium),
                  ),
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _onSearch,
                style: AppTheme.primaryButtonStyle.copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                child: const Text('Cari'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tujuanOptions.map((option) {
                final isSelected = (_selectedTujuan ?? '') == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(option['label']!),
                    selected: isSelected,
                    onSelected: (_) => _onFilterChanged(option['value']),
                    selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.greyText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
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
          CircularProgressIndicator(color: AppTheme.primaryGreen),
          SizedBox(height: 16),
          Text('Memuat file...', style: TextStyle(color: AppTheme.greyMedium)),
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
              onPressed: _loadFiles,
              style: AppTheme.primaryButtonStyle,
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
              Icons.folder_open,
              size: 80,
              color: AppTheme.greyMedium.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada file',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.greyMedium),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedTujuan != null
                  ? 'Tidak ada file yang cocok dengan filter'
                  : 'File yang Anda upload akan muncul di sini',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList() {
    return RefreshIndicator(
      onRefresh: _loadFiles,
      color: AppTheme.primaryGreen,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _files.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildFileCard(_files[index]),
      ),
    );
  }

  Widget _buildFileCard(FileInfo file) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewFileDetail(file),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // File icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getTujuanColor(file.tujuan).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: file.isImage && file.url.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          UploadService.buildFileUrl(file.url),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            _getFileIcon(file),
                            color: _getTujuanColor(file.tujuan),
                            size: 28,
                          ),
                        ),
                      )
                    : Icon(
                        _getFileIcon(file),
                        color: _getTujuanColor(file.tujuan),
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              
              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.namaFileAsli,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTujuanColor(file.tujuan).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            file.tujuanEnum.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: _getTujuanColor(file.tujuan),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          file.ukuranFormatted,
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(file.diuploadPada),
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.greyMedium),
                    ),
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'detail':
                      _viewFileDetail(file);
                      break;
                    case 'download':
                      _downloadFile(file);
                      break;
                    case 'delete':
                      _deleteFile(file);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Lihat Detail'),
                      ],
                    ),
                  ),
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
                icon: const Icon(Icons.more_vert, color: AppTheme.greyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final totalPages = _metadata!.totalHalaman;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            color: AppTheme.primaryGreen,
            disabledColor: AppTheme.greyDisabled,
          ),
          const SizedBox(width: 8),
          Text(
            'Halaman $_currentPage dari $totalPages',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _currentPage < totalPages ? () => _goToPage(_currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            color: AppTheme.primaryGreen,
            disabledColor: AppTheme.greyDisabled,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
