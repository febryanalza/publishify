import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/editor/editor_models.dart';
import 'package:publishify/models/editor/review_models.dart' show StatusReview;
import 'package:publishify/services/editor/editor_service.dart';
import 'package:publishify/utils/editor_navigation.dart';

/// Halaman Naskah Masuk untuk Editor
/// Menampilkan daftar naskah baru yang perlu direview
class NaskahMasukPage extends StatefulWidget {
  const NaskahMasukPage({Key? key}) : super(key: key);

  @override
  State<NaskahMasukPage> createState() => _NaskahMasukPageState();
}

class _NaskahMasukPageState extends State<NaskahMasukPage> {
  bool _isLoading = true;
  List<ReviewAssignment> _naskahMasuk = [];
  String _selectedFilter = 'semua';

  @override
  void initState() {
    super.initState();
    _loadNaskahMasuk();
  }

  Future<void> _loadNaskahMasuk() async {
    try {
      setState(() => _isLoading = true);
      
      // Parse status filter
      StatusReview? statusFilter;
      if (_selectedFilter != 'semua') {
        try {
          statusFilter = StatusReview.values.firstWhere(
            (e) => e.name == _selectedFilter,
          );
        } catch (_) {
          // Ignore if not found
        }
      }
      
      final assignments = await EditorService.getReviewAssignments(
        status: statusFilter,
      );
      
      setState(() {
        _naskahMasuk = assignments.where((assignment) => 
          assignment.status == 'ditugaskan' || 
          assignment.status == 'sedang_review'
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data naskah')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Naskah Masuk',
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
            onPressed: _loadNaskahMasuk,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildNaskahList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Filter: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('semua', 'Semua'),
                  const SizedBox(width: 8),
                  _buildFilterChip('ditugaskan', 'Baru Ditugaskan'),
                  const SizedBox(width: 8),
                  _buildFilterChip('sedang_review', 'Sedang Review'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _loadNaskahMasuk();
      },
      selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryGreen : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildNaskahList() {
    if (_naskahMasuk.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada naskah masuk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Naskah baru akan muncul di sini',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNaskahMasuk,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _naskahMasuk.length,
        itemBuilder: (context, index) {
          final naskah = _naskahMasuk[index];
          return _buildNaskahCard(naskah);
        },
      ),
    );
  }

  Widget _buildNaskahCard(ReviewAssignment naskah) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openNaskahDetail(naskah),
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
                          naskah.judulNaskah,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Oleh: ${naskah.penulis}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusBadge(naskah.status),
                ],
              ),
              const SizedBox(height: 12),
              
              // Priority and Tags
              Row(
                children: [
                  _buildPriorityBadge(naskah.prioritas),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (naskah.tags ?? []).take(2).map((tag) => 
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Timeline info
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ditugaskan: ${_formatDate(naskah.tanggalDitugaskan)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: _getDeadlineColor(naskah.batasWaktu),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Deadline: ${_formatDate(naskah.batasWaktu)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDeadlineColor(naskah.batasWaktu),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _openNaskahDetail(naskah),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryGreen),
                      ),
                      child: Text(
                        'Lihat Detail',
                        style: TextStyle(color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: naskah.status == 'ditugaskan' 
                        ? () => _startReview(naskah)
                        : () => _continueReview(naskah),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                      child: Text(
                        naskah.status == 'ditugaskan' ? 'Mulai Review' : 'Lanjut Review',
                        style: const TextStyle(color: Colors.white),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'ditugaskan':
        color = Colors.orange;
        label = 'Baru Ditugaskan';
        break;
      case 'sedang_review':
        color = Colors.blue;
        label = 'Sedang Review';
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

  Widget _buildPriorityBadge(int priority) {
    Color color;
    String label;
    
    switch (priority) {
      case 1:
        color = Colors.red;
        label = 'Prioritas Tinggi';
        break;
      case 2:
        color = Colors.orange;
        label = 'Prioritas Sedang';
        break;
      default:
        color = Colors.green;
        label = 'Prioritas Normal';
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
          Icon(
            Icons.flag,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
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

  Color _getDeadlineColor(DateTime deadline) {
    final now = DateTime.now();
    final daysLeft = deadline.difference(now).inDays;
    
    if (daysLeft < 0) return Colors.red;
    if (daysLeft <= 1) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    
    if (diff.inDays == 0) {
      return 'Hari ini';
    } else if (diff.inDays == 1) {
      return 'Besok';
    } else if (diff.inDays == -1) {
      return 'Kemarin';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} hari lagi';
    } else {
      return '${-diff.inDays} hari yang lalu';
    }
  }

  void _openNaskahDetail(ReviewAssignment naskah) {
    if (naskah.idNaskah != null) {
      EditorNavigation.toDetailReviewNaskah(context, naskah.idNaskah!);
    }
  }

  void _startReview(ReviewAssignment naskah) {
    // TODO: Update status to 'sedang_review'
    EditorNavigation.toReviewNaskah(context);
  }

  void _continueReview(ReviewAssignment naskah) {
    EditorNavigation.toReviewNaskah(context);
  }
}