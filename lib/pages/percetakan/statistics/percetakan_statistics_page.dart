import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/percetakan/percetakan_models.dart';
import 'package:publishify/services/percetakan/percetakan_service.dart';

/// Halaman Statistik Percetakan
/// Menampilkan statistik pesanan dan revenue dengan data dari backend
class PercetakanStatisticsPage extends StatefulWidget {
  const PercetakanStatisticsPage({super.key});

  @override
  State<PercetakanStatisticsPage> createState() =>
      _PercetakanStatisticsPageState();
}

class _PercetakanStatisticsPageState extends State<PercetakanStatisticsPage> {
  bool _isLoading = true;
  String? _errorMessage;
  PercetakanStats? _stats;

  @override
  void initState() {
    super.initState();
    _muatStatistik();
  }

  Future<void> _muatStatistik() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await PercetakanService.ambilStatistik();
      
      if (response.sukses && response.data != null) {
        setState(() {
          _stats = response.data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Statistik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryGreen,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorRed),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _muatStatistik,
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
      );
    }

    if (_stats == null) {
      return const Center(
        child: Text(
          'Tidak ada data statistik',
          style: AppTheme.bodyMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _muatStatistik,
      color: AppTheme.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan Utama
            _buildStatsSummary(),
            const SizedBox(height: 24),

            // Breakdown Status
            _buildSectionTitle('Status Pesanan'),
            const SizedBox(height: 12),
            _buildStatusBreakdown(),
            const SizedBox(height: 24),

            // Revenue Card
            _buildSectionTitle('Total Pendapatan'),
            const SizedBox(height: 12),
            _buildRevenueCard(),
            const SizedBox(height: 24),

            // Metrics Detail
            _buildSectionTitle('Detail Metrics'),
            const SizedBox(height: 12),
            _buildMetricsDetail(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryDark,
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Pesanan',
            value: _stats!.totalPesanan.toString(),
            icon: Icons.inventory_2_outlined,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Aktif',
            value: _stats!.pesananAktif.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Selesai',
            value: _stats!.pesananSelesai.toString(),
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackOverlay,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.greyText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    final breakdown = _stats!.statusBreakdown;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackOverlay,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusRow('Tertunda', breakdown.tertunda, Colors.grey),
          _buildStatusRow('Diterima', breakdown.diterima, Colors.blue),
          _buildStatusRow('Dalam Produksi', breakdown.dalamProduksi, Colors.purple),
          _buildStatusRow('Kontrol Kualitas', breakdown.kontrolKualitas, Colors.orange),
          _buildStatusRow('Siap', breakdown.siap, Colors.cyan),
          _buildStatusRow('Dikirim', breakdown.dikirim, Colors.indigo),
          _buildStatusRow('Terkirim', breakdown.terkirim, Colors.green),
          _buildStatusRow('Dibatalkan', breakdown.dibatalkan, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    final total = _stats!.totalPesanan;
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.black,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              backgroundColor: AppTheme.greyLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    final formattedRevenue = PercetakanService.formatHarga(_stats!.totalRevenue);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Total Revenue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formattedRevenue,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dari ${_stats!.totalPesanan} pesanan (${_stats!.pesananSelesai} selesai)',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsDetail() {
    final completionRate = _stats!.totalPesanan > 0
        ? (_stats!.pesananSelesai / _stats!.totalPesanan * 100)
        : 0.0;
    
    final activeRate = _stats!.totalPesanan > 0
        ? (_stats!.pesananAktif / _stats!.totalPesanan * 100)
        : 0.0;

    final cancelRate = _stats!.totalPesanan > 0
        ? (_stats!.statusBreakdown.dibatalkan / _stats!.totalPesanan * 100)
        : 0.0;

    final avgRevenue = _stats!.pesananSelesai > 0
        ? (double.tryParse(_stats!.totalRevenue) ?? 0) / _stats!.pesananSelesai
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackOverlay,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMetricRow(
            'Completion Rate',
            '${completionRate.toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.green,
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Active Rate',
            '${activeRate.toStringAsFixed(1)}%',
            Icons.hourglass_empty,
            Colors.orange,
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Cancel Rate',
            '${cancelRate.toStringAsFixed(1)}%',
            Icons.trending_down,
            Colors.red,
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Avg Revenue/Pesanan',
            PercetakanService.formatHarga(avgRevenue.toStringAsFixed(0)),
            Icons.attach_money,
            AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
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
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.black,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
