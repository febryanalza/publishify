import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/services/statistik_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  StatistikData? _statistikData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await StatistikService.ambilStatistikPenulis();
      
      if (response.sukses && response.data != null) {
        setState(() {
          _statistikData = response.data;
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
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.greyDisabled),
            const SizedBox(height: 16),
            Text('Gagal memuat data', style: AppTheme.headingSmall),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: const Text('Coba Lagi', style: TextStyle(color: AppTheme.white)),
            ),
          ],
        ),
      );
    }

    if (_statistikData == null) {
      return const Center(child: Text('Data tidak tersedia'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainStatsCard(),
              const SizedBox(height: 24),
              _buildSalesChart(),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCommentsSection()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatusNaskahSection()),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Statistik Penulis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Total Naskah', _statistikData!.totalNaskah.toString(), Icons.article_outlined),
                            _buildStatItem('Diterbitkan', _statistikData!.naskahDiterbitkan.toString(), Icons.publish_outlined),
              _buildStatItem('Total Dibaca', _statistikData!.totalDibaca.toString(), Icons.visibility_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Rating', _statistikData!.ratingRataRata.toStringAsFixed(1), Icons.star_outline),
              _buildStatItem('Review', _statistikData!.naskahDalamReview.toString(), Icons.comment_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.white.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: AppTheme.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.white, fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildSalesChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statistik Bulanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _statistikData!.penjualanBulanan.isEmpty 
              ? const Center(child: Text('Belum ada data', style: TextStyle(color: AppTheme.greyText)))
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _statistikData!.penjualanBulanan.map((data) {
                  final maxValue = _statistikData!.penjualanBulanan
                      .map((d) => d.jumlahDibaca)
                      .reduce((a, b) => a > b ? a : b);
                  final height = maxValue > 0 ? (data.jumlahDibaca / maxValue * 160).toDouble() : 0.0;
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 30,
                        height: height,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(data.bulan.substring(0, 3), style: const TextStyle(fontSize: 10, color: AppTheme.greyText)),
                    ],
                  );
                }).toList(),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Komentar Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _statistikData!.komentarTerbaru.isEmpty 
            ? const Text('Belum ada komentar', style: TextStyle(color: AppTheme.greyText, fontSize: 12))
            : Column(
              children: _statistikData!.komentarTerbaru.take(3).map((comment) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.greyLight.withValues(alpha:0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment.namaPembaca, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
                      const SizedBox(height: 4),
                      Text(comment.isiKomentar, style: const TextStyle(fontSize: 12, color: AppTheme.greyText), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.orange.shade600),
                          const SizedBox(width: 4),
                          Text(comment.rating.toString(), style: const TextStyle(fontSize: 10, color: AppTheme.greyText)),
                          const Spacer(),
                          Text(comment.judulNaskah, style: const TextStyle(fontSize: 10, color: AppTheme.greyText), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusNaskahSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Naskah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _statistikData!.naskahPerStatus.isEmpty 
            ? const Text('Belum ada data', style: TextStyle(color: AppTheme.greyText, fontSize: 12))
            : Column(
              children: _statistikData!.naskahPerStatus.map((status) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_getStatusLabel(status.status), style: const TextStyle(fontSize: 12, color: AppTheme.greyText)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(status.jumlah.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.white)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'draft': return 'Draft';
      case 'diajukan': return 'Diajukan';
      case 'dalam_review': return 'Review';
      case 'disetujui': return 'Disetujui';
      case 'diterbitkan': return 'Diterbitkan';
      case 'ditolak': return 'Ditolak';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft': return AppTheme.greyDisabled;
      case 'diajukan': return Colors.blue;
      case 'dalam_review': return Colors.orange;
      case 'disetujui': return Colors.green;
      case 'diterbitkan': return AppTheme.primaryGreen;
      case 'ditolak': return Colors.red;
      default: return AppTheme.greyDisabled;
    }
  }
}