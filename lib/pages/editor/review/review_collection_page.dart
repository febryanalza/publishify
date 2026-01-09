import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/editor/review_collection_models.dart';
import 'package:publishify/services/editor/review_collection_service.dart';
import 'package:publishify/pages/editor/review/review_detail_page.dart';

/// Halaman utama untuk pengumpulan review editor
/// Fitur: Filter dropdown, list buku masuk, aksi terima/tugaskan/lihat detail
class ReviewCollectionPage extends StatefulWidget {
  const ReviewCollectionPage({super.key});

  @override
  State<ReviewCollectionPage> createState() => _ReviewCollectionPageState();
}

class _ReviewCollectionPageState extends State<ReviewCollectionPage> {
  List<BukuMasukReview> _books = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'semua';
  Map<String, int> _filterCounts = {};

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
      final response = await ReviewCollectionService.getBukuMasukReview(
        filter: _selectedFilter,
      );

      if (response.sukses && response.data != null) {
        setState(() {
          _books = response.data!;
          _filterCounts = Map<String, int>.from(response.metadata?['filters'] ?? {});
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

  void _onFilterChanged(String? newFilter) {
    if (newFilter != null && newFilter != _selectedFilter) {
      setState(() {
        _selectedFilter = newFilter;
      });
      _loadData();
    }
  }

  void _onTerimaBuku(BukuMasukReview book) async {
    // Simpan navigator dan scaffoldMessenger sebelum masuk async gap
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryGreen,
        ),
      ),
    );

    try {
      final response = await ReviewCollectionService.terimaBuku(book.id);
      
      if (!mounted) return;
      navigator.pop(); // Close loading dialog

      if (response.sukses) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(response.pesan),
            backgroundColor: AppTheme.googleGreen,
          ),
        );
        _loadData(); // Reload data
      } else {
        _showErrorDialog(response.pesan);
      }
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      _showErrorDialog('Gagal menerima buku: ${e.toString()}');
    }
  }

  void _onTugaskanEditor(BukuMasukReview book) {
    // Simpan navigator dan scaffoldMessenger sebelum masuk async gap
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => _TugaskanEditorDialog(
        book: book,
        onSubmit: (editorId, alasan) async {
          Navigator.pop(dialogContext);
          
          // Show loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (loadingContext) => const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            ),
          );

          try {
            final response = await ReviewCollectionService.tugaskanEditorLain(
              idReview: book.id, 
              idEditorBaru: editorId, 
              alasan: alasan,
            );
            
            if (!mounted) return;
            navigator.pop(); // Close loading

            if (response.sukses) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(response.pesan),
                  backgroundColor: AppTheme.googleGreen,
                ),
              );
              _loadData(); // Reload data
            } else {
              _showErrorDialog(response.pesan);
            }
          } catch (e) {
            if (!mounted) return;
            navigator.pop();
            _showErrorDialog('Gagal menugaskan editor: ${e.toString()}');
          }
        },
      ),
    );
  }

  void _onLihatDetail(BukuMasukReview book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailPage(book: book),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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
                      : _books.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              color: AppTheme.primaryGreen,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFilterDropdown(),
                                    const SizedBox(height: 16),
                                    _buildStatsRow(),
                                    const SizedBox(height: 20),
                                    ..._books.map((book) => _buildBookCard(book)),
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
                  'Pengumpulan Review',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola review buku yang masuk',
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
              Icons.assignment_turned_in,
              color: AppTheme.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildFilterDropdown() {
    final filters = [
      {'key': 'semua', 'label': 'Semua Buku'},
      {'key': 'belum_ditugaskan', 'label': 'Belum Ditugaskan'},
      {'key': 'ditugaskan', 'label': 'Ditugaskan'},
      {'key': 'dalam_review', 'label': 'Dalam Review'},
      {'key': 'selesai', 'label': 'Selesai'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyDisabled),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_list,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Filter: ',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDark,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                onChanged: _onFilterChanged,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppTheme.primaryGreen,
                ),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryDark,
                ),
                items: filters.map((filter) {
                  final count = _filterCounts[filter['key']] ?? 0;
                  return DropdownMenuItem<String>(
                    value: filter['key'],
                    child: Text('${filter['label']} ($count)'),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Ditemukan ${_books.length} buku',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryDark,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Diurutkan: Prioritas & Tanggal',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(BukuMasukReview book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header: Status dan Prioritas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(book.status),
              _buildPriorityBadge(book.prioritas),
            ],
          ),
          const SizedBox(height: 12),

          // Informasi Buku
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover placeholder
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.greyLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.greyDisabled),
                ),
                child: const Icon(
                  Icons.book,
                  color: AppTheme.greyMedium,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              
              // Detail buku
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.judul,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.subJudul?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 2),
                      Text(
                        book.subJudul!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyMedium,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    
                    // Metadata
                    _buildMetadataRow('Penulis', book.namaPenulis),
                    _buildMetadataRow('Genre', '${book.kategori} • ${book.genre}'),
                    _buildMetadataRow('Halaman', '${book.jumlahHalaman} hal • ${(book.jumlahKata / 1000).toStringAsFixed(0)}k kata'),
                    _buildMetadataRow('Submit', _formatDate(book.tanggalSubmit ?? book.tanggalMasuk)),
                    
                    if (book.deadlineReview != null) 
                      _buildMetadataRow(
                        'Deadline', 
                        _formatDate(book.deadlineReview!),
                        isDeadline: true,
                      ),

                    if (book.editorYangDitugaskan != null)
                      _buildMetadataRow('Editor', book.editorYangDitugaskan!),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sinopsis
          Text(
            book.sinopsis,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryDark,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // Action buttons
          _buildActionButtons(book),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'belum_ditugaskan':
        backgroundColor = AppTheme.googleYellow.withValues(alpha: 0.2);
        textColor = AppTheme.googleYellow.withValues(alpha: 0.8);
        label = 'Belum Ditugaskan';
        break;
      case 'ditugaskan':
        backgroundColor = AppTheme.googleBlue.withValues(alpha: 0.2);
        textColor = AppTheme.googleBlue;
        label = 'Ditugaskan';
        break;
      case 'dalam_review':
        backgroundColor = AppTheme.primaryGreen.withValues(alpha: 0.2);
        textColor = AppTheme.primaryGreen;
        label = 'Dalam Review';
        break;
      case 'selesai':
        backgroundColor = AppTheme.googleGreen.withValues(alpha: 0.2);
        textColor = AppTheme.googleGreen;
        label = 'Selesai';
        break;
      default:
        backgroundColor = AppTheme.greyMedium.withValues(alpha: 0.2);
        textColor = AppTheme.greyMedium;
        label = 'Tidak Diketahui';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildPriorityBadge(int prioritas) {
    Color color;
    String label;
    IconData icon;

    switch (prioritas) {
      case 3:
        color = AppTheme.errorRed;
        label = 'Tinggi';
        icon = Icons.keyboard_arrow_up;
        break;
      case 2:
        color = AppTheme.googleYellow.withValues(alpha: 0.8);
        label = 'Sedang';
        icon = Icons.remove;
        break;
      case 1:
        color = AppTheme.googleGreen;
        label = 'Rendah';
        icon = Icons.keyboard_arrow_down;
        break;
      default:
        color = AppTheme.greyMedium;
        label = 'Normal';
        icon = Icons.remove;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, {bool isDeadline = false}) {
    final isUrgent = isDeadline && DateTime.now().isAfter(
      DateTime.now().add(const Duration(days: 1)),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  Widget _buildActionButtons(BukuMasukReview book) {
    return Row(
      children: [
        // Terima Buku button
        if (book.status == 'belum_ditugaskan' || book.status == 'ditugaskan') ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () => _onTerimaBuku(book),
              style: AppTheme.primaryButtonStyle.copyWith(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Terima',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Tugaskan Editor Lain button
        if (book.status == 'belum_ditugaskan' || book.status == 'ditugaskan') ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => _onTugaskanEditor(book),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.googleBlue,
                side: const BorderSide(color: AppTheme.googleBlue),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Tugaskan',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.googleBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Lihat Detail button (always available)
        Expanded(
          child: OutlinedButton(
            onPressed: () => _onLihatDetail(book),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Detail',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
            'Memuat data buku...',
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
              _errorMessage ?? 'Tidak dapat memuat data',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
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
            const Icon(
              Icons.book_outlined,
              size: 64,
              color: AppTheme.greyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Buku',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada buku yang masuk untuk direview dengan filter ini',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: AppTheme.secondaryButtonStyle,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
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
}

/// Dialog untuk menugaskan editor lain
class _TugaskanEditorDialog extends StatefulWidget {
  final BukuMasukReview book;
  final Function(String editorId, String alasan) onSubmit;

  const _TugaskanEditorDialog({
    required this.book,
    required this.onSubmit,
  });

  @override
  State<_TugaskanEditorDialog> createState() => _TugaskanEditorDialogState();
}

class _TugaskanEditorDialogState extends State<_TugaskanEditorDialog> {
  List<EditorOption> _editors = [];
  bool _isLoading = true;
  String? _selectedEditorId;
  final _alasanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEditors();
  }

  Future<void> _loadEditors() async {
    try {
      final response = await ReviewCollectionService.getAvailableEditors();
      if (response.sukses && response.data != null) {
        setState(() {
          _editors = response.data!;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tugaskan ke Editor Lain',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih editor yang sesuai untuk buku "${widget.book.judul}"',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            if (_isLoading) ...[
              const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                ),
              ),
            ] else ...[
              // Editor selection
              Text(
                'Pilih Editor:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              
              ..._editors.map((editor) => _buildEditorOption(editor)),

              const SizedBox(height: 16),

              // Alasan
              Text(
                'Alasan Penugasan:',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _alasanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tuliskan alasan mengapa editor ini cocok...',
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

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Batal',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.greyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectedEditorId != null && _alasanController.text.isNotEmpty
                        ? () => widget.onSubmit(_selectedEditorId!, _alasanController.text)
                        : null,
                    style: AppTheme.primaryButtonStyle,
                    child: const Text('Tugaskan'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditorOption(EditorOption editor) {
    final isSelected = _selectedEditorId == editor.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEditorId = editor.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.greyDisabled,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.greyMedium,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    editor.nama,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Spesialisasi: ${editor.spesialisasi.join(", ")}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyMedium,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Workload: ${editor.workload} buku',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: AppTheme.googleYellow,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            editor.rating.toString(),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.greyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }
}