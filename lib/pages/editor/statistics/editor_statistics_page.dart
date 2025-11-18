import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/editor/editor_models.dart';
import 'package:publishify/services/writer/editor_service.dart';

/// Halaman Statistik Editor
class EditorStatisticsPage extends StatefulWidget {
  const EditorStatisticsPage({super.key});

  @override
  State<EditorStatisticsPage> createState() => _EditorStatisticsPageState();
}

class _EditorStatisticsPageState extends State<EditorStatisticsPage> {
  EditorStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await EditorService.getEditorStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
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
          'Statistik Editor',
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
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildStatisticsContent(),
    );
  }

  Widget _buildStatisticsContent() {
    if (_stats == null) {
      return const Center(
        child: Text('Gagal memuat statistik'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewSection(),
            const SizedBox(height: 20),
            _buildReviewStatsSection(),
            const SizedBox(height: 20),
            _buildPerformanceSection(),
            const SizedBox(height: 20),
            _buildMonthlyChartSection(),
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
                _stats!.totalReviewDitugaskan.toString(),
                Icons.assignment_outlined,
                AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Review Selesai',
                _stats!.totalNaskahDireview.toString(),
                Icons.done_all,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Dalam Progress',
                _stats!.reviewDalamProses.toString(),
                Icons.schedule,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Rating Rata-rata',
                '4.5', // Fixed rating untuk sementara
                Icons.star,
                Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressItem(
              'Review Tepat Waktu',
              _stats!.naskahDisetujui,
              _stats!.totalNaskahDireview,
              Colors.green,
            ),
            _buildProgressItem(
              'Review Terlambat',
              _stats!.naskahPerluRevisi,
              _stats!.totalNaskahDireview,
              Colors.red,
            ),
            _buildProgressItem(
              'Review Tertunda',
              _stats!.reviewTertunda,
              _stats!.totalReviewDitugaskan,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return Card(
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
              '${_stats!.rataRataWaktuReview.toStringAsFixed(1)} hari',
              Icons.speed,
            ),
            _buildPerformanceItem(
              'Tingkat Kepuasan',
              '90%', // Fixed percentage untuk sementara
              Icons.thumb_up,
            ),
            _buildPerformanceItem(
              'Total Feedback',
              '${_stats!.totalNaskahDireview}',
              Icons.feedback,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChartSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review Bulanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: const Center(
                child: Text(
                  'Chart akan ditampilkan di sini\n(Implementasi dengan fl_chart)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
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
  ) {
    final percentage = total > 0 ? (value / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(
                '$value/${total}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}