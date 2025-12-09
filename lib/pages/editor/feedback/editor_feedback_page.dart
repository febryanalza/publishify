import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';

/// Halaman Feedback Editor
/// Untuk memberikan feedback kepada penulis
class EditorFeedbackPage extends StatefulWidget {
  const EditorFeedbackPage({Key? key}) : super(key: key);

  @override
  State<EditorFeedbackPage> createState() => _EditorFeedbackPageState();
}

class _EditorFeedbackPageState extends State<EditorFeedbackPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<FeedbackItem> _feedbackList = [];

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

  Future<void> _loadFeedbackData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _feedbackList = [
        FeedbackItem(
          id: 'fb001',
          judulNaskah: 'Petualangan di Nusantara',
          penulis: 'Ahmad Subhan',
          tanggalFeedback: DateTime.now().subtract(const Duration(hours: 2)),
          status: 'menunggu_respon',
          rating: 4,
          feedback: 'Naskah sangat menarik dengan plot yang baik. Namun perlu perbaikan di beberapa bagian dialog.',
          kategori: 'konstruktif',
        ),
        FeedbackItem(
          id: 'fb002',
          judulNaskah: 'Manajemen Keuangan untuk Pemula',
          penulis: 'Siti Nurhaliza',
          tanggalFeedback: DateTime.now().subtract(const Duration(days: 1)),
          status: 'direspon',
          rating: 5,
          feedback: 'Konten sangat informatif dan mudah dipahami. Siap untuk publikasi.',
          kategori: 'positif',
        ),
        FeedbackItem(
          id: 'fb003',
          judulNaskah: 'Kisah Cinta di Masa Pandemi',
          penulis: 'Diana Wijaya',
          tanggalFeedback: DateTime.now().subtract(const Duration(days: 2)),
          status: 'perlu_revisi',
          rating: 3,
          feedback: 'Cerita menarik namun perlu pengembangan karakter yang lebih mendalam.',
          kategori: 'membutuhkan_perbaikan',
        ),
      ];
      _isLoading = false;
    });
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
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _createNewFeedback,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFeedbackList(_feedbackList),
                _buildFeedbackList(_feedbackList.where((f) => f.status == 'menunggu_respon').toList()),
                _buildFeedbackList(_feedbackList.where((f) => f.status == 'direspon').toList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewFeedback,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFeedbackList(List<FeedbackItem> feedbacks) {
    if (feedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feedback_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Feedback yang Anda berikan akan muncul di sini',
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
        itemCount: feedbacks.length,
        itemBuilder: (context, index) {
          return _buildFeedbackCard(feedbacks[index]);
        },
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackItem feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showFeedbackDetail(feedback),
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
                          feedback.judulNaskah,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Penulis: ${feedback.penulis}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(feedback.status),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Rating
              Row(
                children: [
                  ...List.generate(5, (index) => 
                    Icon(
                      index < feedback.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${feedback.rating}/5)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  _buildKategoriBadge(feedback.kategori),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Feedback preview
              Text(
                feedback.feedback,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              
              // Footer
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDateTime(feedback.tanggalFeedback),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showFeedbackDetail(feedback),
                    child: Text(
                      'Lihat Detail',
                      style: TextStyle(color: AppTheme.primaryGreen),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'menunggu_respon':
        color = Colors.orange;
        label = 'Menunggu Respon';
        break;
      case 'direspon':
        color = Colors.green;
        label = 'Sudah Direspon';
        break;
      case 'perlu_revisi':
        color = Colors.red;
        label = 'Perlu Revisi';
        break;
      default:
        color = Colors.grey;
        label = status;
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

  Widget _buildKategoriBadge(String kategori) {
    Color color;
    IconData icon;
    
    switch (kategori) {
      case 'positif':
        color = Colors.green;
        icon = Icons.thumb_up;
        break;
      case 'konstruktif':
        color = Colors.blue;
        icon = Icons.lightbulb;
        break;
      case 'membutuhkan_perbaikan':
        color = Colors.orange;
        icon = Icons.edit;
        break;
      default:
        color = Colors.grey;
        icon = Icons.feedback;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            _getKategoriLabel(kategori),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getKategoriLabel(String kategori) {
    switch (kategori) {
      case 'positif': return 'Positif';
      case 'konstruktif': return 'Konstruktif';
      case 'membutuhkan_perbaikan': return 'Perlu Perbaikan';
      default: return kategori;
    }
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

  void _createNewFeedback() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FeedbackFormSheet(),
    );
  }

  void _showFeedbackDetail(FeedbackItem feedback) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDetailDialog(feedback: feedback),
    );
  }
}

/// Model untuk item feedback
class FeedbackItem {
  final String id;
  final String judulNaskah;
  final String penulis;
  final DateTime tanggalFeedback;
  final String status;
  final int rating;
  final String feedback;
  final String kategori;

  FeedbackItem({
    required this.id,
    required this.judulNaskah,
    required this.penulis,
    required this.tanggalFeedback,
    required this.status,
    required this.rating,
    required this.feedback,
    required this.kategori,
  });
}

/// Dialog untuk detail feedback
class FeedbackDetailDialog extends StatelessWidget {
  final FeedbackItem feedback;

  const FeedbackDetailDialog({Key? key, required this.feedback}) : super(key: key);

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
                Expanded(
                  child: Text(
                    'Detail Feedback',
                    style: const TextStyle(
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
            
            Text(
              feedback.judulNaskah,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Penulis: ${feedback.penulis}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                ...List.generate(5, (index) => 
                  Icon(
                    index < feedback.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text('(${feedback.rating}/5)'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Feedback:',
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
              child: Text(feedback.feedback),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Edit feedback
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet untuk form feedback baru
class FeedbackFormSheet extends StatefulWidget {
  const FeedbackFormSheet({Key? key}) : super(key: key);

  @override
  State<FeedbackFormSheet> createState() => _FeedbackFormSheetState();
}

class _FeedbackFormSheetState extends State<FeedbackFormSheet> {
  final _feedbackController = TextEditingController();
  int _rating = 5;
  String _kategori = 'konstruktif';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Buat Feedback Baru',
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
          
          const SizedBox(height: 24),
          
          const Text(
            'Rating:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) => 
              GestureDetector(
                onTap: () => setState(() => _rating = index + 1),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Kategori:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _kategori,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'positif', child: Text('Positif')),
              DropdownMenuItem(value: 'konstruktif', child: Text('Konstruktif')),
              DropdownMenuItem(value: 'membutuhkan_perbaikan', child: Text('Perlu Perbaikan')),
            ],
            onChanged: (value) => setState(() => _kategori = value!),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Feedback:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Tulis feedback untuk penulis...',
              contentPadding: EdgeInsets.all(12),
            ),
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
                  onPressed: _saveFeedback,
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
    );
  }

  void _saveFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tulis feedback terlebih dahulu')),
      );
      return;
    }
    
    // TODO: Save feedback via API
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback berhasil dikirim')),
    );
  }
}