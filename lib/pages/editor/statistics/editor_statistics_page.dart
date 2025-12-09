import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/services/editor/statistik_service.dart';
import 'package:publishify/models/editor/review_models.dart' show ReviewTerbaru, StatusReview, Rekomendasi;

/// Halaman Statistik Editor - Menggunakan Data Real dari API
class EditorStatisticsPage extends StatefulWidget {
  const EditorStatisticsPage({super.key});

  @override
  State<EditorStatisticsPage> createState() => _EditorStatisticsPageState();
}

class _EditorStatisticsPageState extends State<EditorStatisticsPage> {
  StatistikReviewData? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await EditorStatistikService.ambilStatistikReview();
      
      if (response.sukses && response.data != null) {
        setState(() {
          _stats = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.pesan ?? 'Gagal memuat statistik';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Statistik Review',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStatistics,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _buildStatisticsContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Gagal memuat statistik',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadStatistics,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsContent() {
    if (_stats == null) {
      return const Center(
        child: Text('Tidak ada data statistik'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      color: AppTheme.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan Utama
            _buildOverviewSection(),
            const SizedBox(height: 20),
            
            // Status Review
            _buildStatusSection(),
            const SizedBox(height: 20),
            
            // Rekomendasi Review
            _buildRekomendasiSection(),
            const SizedBox(height: 20),
            
            // Performa
            _buildPerformanceSection(),
            const SizedBox(height: 20),
            
            // Review Terbaru
            _buildRecentReviewsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Review',
                _stats!.totalReview.toString(),
                Icons.assignment_outlined,
                AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Selesai',
                _stats!.perStatus.selesai.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Dalam Proses',
                _stats!.perStatus.dalamProses.toString(),
                Icons.hourglass_empty,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Rata-rata Hari',
                '${_stats!.rataRataHariReview} hari',
                Icons.schedule,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    final total = _stats!.perStatus.total;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressItem(
              'Ditugaskan',
              _stats!.perStatus.ditugaskan,
              total,
              AppTheme.primaryGreen,
              Icons.assignment,
            ),
            _buildProgressItem(
              'Dalam Proses',
              _stats!.perStatus.dalamProses,
              total,
              Colors.orange,
              Icons.pending,
            ),
            _buildProgressItem(
              'Selesai',
              _stats!.perStatus.selesai,
              total,
              Colors.green,
              Icons.done,
            ),
            if (_stats!.perStatus.dibatalkan > 0)
              _buildProgressItem(
                'Dibatalkan',
                _stats!.perStatus.dibatalkan,
                total,
                Colors.red,
                Icons.cancel,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRekomendasiSection() {
    final total = _stats!.perRekomendasi.total;
    
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rekomendasi Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressItem(
              'Disetujui',
              _stats!.perRekomendasi.setujui,
              total,
              Colors.green,
              Icons.thumb_up,
            ),
            _buildProgressItem(
              'Perlu Revisi',
              _stats!.perRekomendasi.revisi,
              total,
              Colors.orange,
              Icons.edit,
            ),
            _buildProgressItem(
              'Ditolak',
              _stats!.perRekomendasi.tolak,
              total,
              Colors.red,
              Icons.thumb_down,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    // Hitung tingkat penyelesaian
    final completionRate = _stats!.totalReview > 0
        ? (_stats!.perStatus.selesai / _stats!.totalReview * 100).toStringAsFixed(1)
        : '0';
    
    // Hitung tingkat approval (dari selesai yang disetujui)
    final approvalRate = _stats!.perRekomendasi.total > 0
        ? (_stats!.perRekomendasi.setujui / _stats!.perRekomendasi.total * 100).toStringAsFixed(1)
        : '0';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceItem(
              'Kecepatan Review',
              '${_stats!.rataRataHariReview} hari rata-rata',
              Icons.speed,
              AppTheme.primaryGreen,
            ),
            _buildPerformanceItem(
              'Tingkat Penyelesaian',
              '$completionRate%',
              Icons.pie_chart,
              Colors.blue,
            ),
            _buildPerformanceItem(
              'Tingkat Approval',
              '$approvalRate%',
              Icons.verified,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReviewsSection() {
    if (_stats!.reviewTerbaru.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Review Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_stats!.reviewTerbaru.length} item',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._stats!.reviewTerbaru.map((review) => _buildReviewItem(review)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(ReviewTerbaru review) {
    Color statusColor = _getStatusColor(review.status);
    String statusLabel = _getStatusLabel(review.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.judulNaskah,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(review.ditugaskanPada),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (review.rekomendasi != null) ...[
                const SizedBox(width: 16),
                Icon(
                  _getRekomendasiIcon(review.rekomendasi!),
                  size: 14,
                  color: _getRekomendasiColor(review.rekomendasi!),
                ),
                const SizedBox(width: 4),
                Text(
                  _getRekomendasiLabel(review.rekomendasi!),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getRekomendasiColor(review.rekomendasi!),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    String title,
    int value,
    int total,
    Color color,
    IconData icon,
  ) {
    final percentage = total > 0 ? (value / total) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(title)),
              Text(
                '$value',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${(percentage * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(StatusReview status) {
    switch (status) {
      case StatusReview.ditugaskan:
        return AppTheme.primaryGreen;
      case StatusReview.dalam_proses:
        return Colors.orange;
      case StatusReview.selesai:
        return Colors.green;
      case StatusReview.dibatalkan:
        return Colors.red;
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

  IconData _getRekomendasiIcon(Rekomendasi rekomendasi) {
    switch (rekomendasi) {
      case Rekomendasi.setujui:
        return Icons.check_circle;
      case Rekomendasi.revisi:
        return Icons.edit;
      case Rekomendasi.tolak:
        return Icons.cancel;
    }
  }

  Color _getRekomendasiColor(Rekomendasi rekomendasi) {
    switch (rekomendasi) {
      case Rekomendasi.setujui:
        return Colors.green;
      case Rekomendasi.revisi:
        return Colors.orange;
      case Rekomendasi.tolak:
        return Colors.red;
    }
  }

  String _getRekomendasiLabel(Rekomendasi rekomendasi) {
    switch (rekomendasi) {
      case Rekomendasi.setujui:
        return 'Disetujui';
      case Rekomendasi.revisi:
        return 'Revisi';
      case Rekomendasi.tolak:
        return 'Ditolak';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
