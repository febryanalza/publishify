import 'package:flutter/material.dart';
import 'package:publishify/models/editor/review_models.dart';
import 'package:publishify/services/editor/editor_api_service.dart';
import 'package:publishify/utils/theme.dart';

/// Halaman Feedback Editor
/// Untuk memberikan feedback kepada penulis - menggunakan data dari server
class EditorFeedbackPage extends StatefulWidget {
  const EditorFeedbackPage({Key? key}) : super(key: key);

  @override
  State<EditorFeedbackPage> createState() => _EditorFeedbackPageState();
}

class _EditorFeedbackPageState extends State<EditorFeedbackPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  
  /// Daftar review dengan feedback
  List<ReviewNaskah> _reviewList = [];
  
  /// Daftar feedback yang sudah diekstrak untuk display
  List<FeedbackDisplayItem> _feedbackList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFeedbackData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Ambil data review dan ekstrak feedback dari server
  Future<void> _loadFeedbackData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Ambil semua review milik editor yang login
      final response = await EditorApiService.ambilReviewSaya();

      if (response.sukses && response.data != null) {
        setState(() {
          _reviewList = response.data!;
          
          // PERBAIKAN: Jika ada feedback di dalam review, ekstrak
          // Jika tidak ada, tampilkan review-nya saja
          _feedbackList = [];
          
          for (final review in _reviewList) {
            if (review.feedback.isNotEmpty) {
              // Ada feedback, ekstrak satu per satu
              for (final feedback in review.feedback) {
                _feedbackList.add(FeedbackDisplayItem(
                  feedback: feedback,
                  review: review,
                ));
              }
            }
            // CATATAN: Jika tidak ada feedback, tidak masalah
            // Review akan ditampilkan di list review
          }
          
          // Urutkan berdasarkan tanggal terbaru (updated review)
          _feedbackList.sort((a, b) => 
            b.feedback.dibuatPada.compareTo(a.feedback.dibuatPada));

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.pesan;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  /// Filter review berdasarkan status
  List<ReviewNaskah> _getFilteredReviews(String? statusFilter) {
    if (statusFilter == null) {
      return _reviewList;
    }
    
    if (statusFilter == 'menunggu') {
      // Review yang masih dalam proses
      return _reviewList.where((review) => 
        review.status == StatusReview.ditugaskan ||
        review.status == StatusReview.dalam_proses
      ).toList();
    } else if (statusFilter == 'selesai') {
      // Review yang sudah selesai
      return _reviewList.where((review) => 
        review.status == StatusReview.selesai
      ).toList();
    }
    
    return _reviewList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Feedback Editor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFeedbackData,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showSelectReviewDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Menunggu'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSelectReviewDialog,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data feedback...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFeedbackData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildReviewList(_getFilteredReviews(null)),
        _buildReviewList(_getFilteredReviews('menunggu')),
        _buildReviewList(_getFilteredReviews('selesai')),
      ],
    );
  }

  Widget _buildReviewList(List<ReviewNaskah> reviews) {
    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada review',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Review yang ditugaskan akan muncul di sini',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeedbackData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          return _buildReviewCard(reviews[index]);
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewNaskah review) {
    // Hitung jumlah feedback
    final feedbackCount = review.feedbackCount ?? 0;
    
    // Format tanggal
    String tanggal = '';
    try {
      if (review.selesaiPada != null) {
        tanggal = _formatDateTime(review.selesaiPada!);
      } else if (review.dimulaiPada != null) {
        tanggal = _formatDateTime(review.dimulaiPada!);
      } else {
        tanggal = _formatDateTime(review.ditugaskanPada);
      }
    } catch (e) {
      tanggal = '-';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate ke halaman detail review atau feedback
          // TODO: Implement navigation
        },
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.naskah.judul,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Penulis: ${_getNamaPenulis(review)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(review.status),
                ],
              ),

              const SizedBox(height: 12),

              // Catatan review jika ada
              if (review.catatan != null && review.catatan!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          review.catatan!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              // Feedback counter
              Row(
                children: [
                  Icon(
                    Icons.feedback_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$feedbackCount Feedback',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tanggal,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (review.status != StatusReview.selesai)
                    TextButton.icon(
                      onPressed: () => _showAddFeedbackDialog(review),
                      icon: const Icon(Icons.add_comment, size: 18),
                      label: const Text('Tambah Feedback'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                      ),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Navigate to detail
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen),
                    ),
                    child: const Text('Lihat Detail'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNamaPenulis(ReviewNaskah review) {
    final penulis = review.naskah.penulis;
    if (penulis == null) return 'Tidak diketahui';
    
    if (penulis.profilPengguna != null) {
      final profil = penulis.profilPengguna!;
      final namaDepan = profil.namaDepan ?? '';
      final namaBelakang = profil.namaBelakang ?? '';
      final namaLengkap = '$namaDepan $namaBelakang'.trim();
      return namaLengkap.isNotEmpty ? namaLengkap : penulis.email;
    }
    return penulis.email;
  }

  void _showAddFeedbackDialog(ReviewNaskah review) {
    // TODO: Implement dialog untuk tambah feedback
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Feedback'),
        content: Text('Untuk naskah: ${review.naskah.judul}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(StatusReview status) {
    Color color;
    String label;

    switch (status) {
      case StatusReview.ditugaskan:
        color = Colors.blue;
        label = 'Ditugaskan';
        break;
      case StatusReview.dalam_proses:
        color = Colors.orange;
        label = 'Dalam Proses';
        break;
      case StatusReview.selesai:
        color = Colors.green;
        label = 'Selesai';
        break;
      case StatusReview.dibatalkan:
        color = Colors.red;
        label = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return '${diff.inDays} hari yang lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Dialog untuk memilih review sebelum menambah feedback
  void _showSelectReviewDialog() {
    // Filter hanya review yang masih aktif (bisa ditambah feedback)
    final activeReviews = _reviewList.where((r) =>
      r.status == StatusReview.ditugaskan ||
      r.status == StatusReview.dalam_proses
    ).toList();

    if (activeReviews.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada review aktif. Feedback hanya bisa ditambahkan ke review yang sedang berjalan.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SelectReviewSheet(
        reviews: activeReviews,
        onSelect: (review) {
          Navigator.pop(context);
          _showFeedbackFormDialog(review);
        },
      ),
    );
  }

  /// Dialog form untuk menambah feedback baru
  void _showFeedbackFormDialog(ReviewNaskah review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FeedbackFormSheet(
        review: review,
        onSubmit: (request) async {
          Navigator.pop(context);
          await _submitFeedback(review.id, request);
        },
      ),
    );
  }

  /// Submit feedback ke server
  Future<void> _submitFeedback(String idReview, TambahFeedbackRequest request) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await EditorApiService.tambahFeedback(idReview, request);
      
      // Hide loading
      if (mounted) Navigator.pop(context);

      if (response.sukses) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Reload data
        await _loadFeedbackData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: Colors.red,
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
            content: Text('Gagal mengirim feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // NOTE: Method ini di-comment karena sekarang kita tampilkan review, bukan individual feedback
  // Uncomment nanti ketika backend sudah mengirim array feedback dalam response
  /*
  void _showFeedbackDetail(FeedbackDisplayItem item) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDetailDialog(item: item),
    );
  }
  */
}

/// Model untuk display feedback dengan info review terkait
class FeedbackDisplayItem {
  final FeedbackReview feedback;
  final ReviewNaskah review;

  FeedbackDisplayItem({
    required this.feedback,
    required this.review,
  });

  /// Nama penulis dari profil atau email
  String get namaPenulis {
    final penulis = review.naskah.penulis;
    if (penulis == null) return 'Tidak diketahui';
    
    final profil = penulis.profilPengguna;
    if (profil != null) {
      final namaLengkap = profil.namaLengkap;
      if (namaLengkap.isNotEmpty) return namaLengkap;
    }
    return penulis.email;
  }
}

/// Sheet untuk memilih review
class SelectReviewSheet extends StatelessWidget {
  final List<ReviewNaskah> reviews;
  final void Function(ReviewNaskah) onSelect;

  const SelectReviewSheet({
    Key? key,
    required this.reviews,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pilih Review',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih naskah yang ingin diberi feedback',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.book,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  title: Text(
                    review.naskah.judul,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Feedback: ${review.feedback.length}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                  onTap: () => onSelect(review),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog untuk detail feedback
class FeedbackDetailDialog extends StatelessWidget {
  final FeedbackDisplayItem item;

  const FeedbackDetailDialog({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Detail Feedback',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info Naskah
            Text(
              item.review.naskah.judul,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Penulis: ${item.namaPenulis}',
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            // Info Bab/Halaman
            if (item.feedback.bab != null || item.feedback.halaman != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bookmark, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      _formatBabHalaman(item.feedback.bab, item.feedback.halaman),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const Text(
              'Komentar:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(item.feedback.komentar),
            ),

            const SizedBox(height: 16),

            // Waktu
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatFullDateTime(item.feedback.dibuatPada),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatBabHalaman(String? bab, int? halaman) {
    List<String> parts = [];
    if (bab != null && bab.isNotEmpty) {
      parts.add('Bab: $bab');
    }
    if (halaman != null) {
      parts.add('Halaman: $halaman');
    }
    return parts.join(' • ');
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Sheet untuk form feedback baru
class FeedbackFormSheet extends StatefulWidget {
  final ReviewNaskah review;
  final void Function(TambahFeedbackRequest) onSubmit;

  const FeedbackFormSheet({
    Key? key,
    required this.review,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<FeedbackFormSheet> createState() => _FeedbackFormSheetState();
}

class _FeedbackFormSheetState extends State<FeedbackFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _komentarController = TextEditingController();
  final _babController = TextEditingController();
  final _halamanController = TextEditingController();

  @override
  void dispose() {
    _komentarController.dispose();
    _babController.dispose();
    _halamanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tambah Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              
              // Info naskah
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.book, color: AppTheme.primaryGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.review.naskah.judul,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bab (opsional)
              const Text(
                'Bab (opsional):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _babController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: Bab 3 - Perjalanan',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),

              const SizedBox(height: 16),

              // Halaman (opsional)
              const Text(
                'Halaman (opsional):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _halamanController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: 45',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),

              const SizedBox(height: 16),

              // Komentar (wajib)
              Row(
                children: [
                  const Text(
                    'Komentar:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _komentarController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tulis feedback untuk penulis (minimal 10 karakter)...',
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Komentar wajib diisi';
                  }
                  if (value.trim().length < 10) {
                    return 'Komentar minimal 10 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                      child: const Text(
                        'Kirim Feedback',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitFeedback() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Parse halaman jika ada
    int? halaman;
    if (_halamanController.text.trim().isNotEmpty) {
      halaman = int.tryParse(_halamanController.text.trim());
    }

    final request = TambahFeedbackRequest(
      bab: _babController.text.trim().isEmpty ? null : _babController.text.trim(),
      halaman: halaman,
      komentar: _komentarController.text.trim(),
    );

    widget.onSubmit(request);
  }
}
