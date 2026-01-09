import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/cetak_models.dart';
import 'package:publishify/services/writer/cetak_service.dart';
import 'package:publishify/pages/writer/percetakan/buat_pesanan_cetak_page.dart';
import 'package:publishify/pages/writer/percetakan/detail_pesanan_cetak_page.dart';

/// Halaman utama percetakan untuk penulis
/// Menampilkan daftar pesanan cetak dan opsi untuk membuat pesanan baru
class PercetakanPenulisPage extends StatefulWidget {
  const PercetakanPenulisPage({super.key});

  @override
  State<PercetakanPenulisPage> createState() => _PercetakanPenulisPageState();
}

class _PercetakanPenulisPageState extends State<PercetakanPenulisPage> {
  List<PesananCetak> _pesananList = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'semua';
  PaginationMetadata? _metadata;

  final List<Map<String, String>> _filterOptions = [
    {'value': 'semua', 'label': 'Semua'},
    {'value': 'tertunda', 'label': 'Menunggu'},
    {'value': 'diterima', 'label': 'Diterima'},
    {'value': 'dalam_produksi', 'label': 'Produksi'},
    {'value': 'dikirim', 'label': 'Dikirim'},
    {'value': 'terkirim', 'label': 'Selesai'},
    {'value': 'dibatalkan', 'label': 'Batal'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  Future<void> _loadPesanan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await CetakService.ambilPesananSaya(
      limit: 50,
      status: _selectedFilter == 'semua' ? null : _selectedFilter,
    );

    setState(() {
      _isLoading = false;
      if (response.sukses) {
        _pesananList = response.data;
        _metadata = response.metadata;
      } else {
        _error = response.pesan;
      }
    });
  }

  void _navigateToBuatPesanan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BuatPesananCetakPage(),
      ),
    );

    if (result == true) {
      _loadPesanan();
    }
  }

  void _navigateToDetail(PesananCetak pesanan) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPesananCetakPage(pesananId: pesanan.id),
      ),
    );

    if (result == true) {
      _loadPesanan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cetak Buku',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.white),
            onPressed: _loadPesanan,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header dengan info
          _buildHeader(),
          // Filter chips
          _buildFilterChips(),
          // Content
          Expanded(
            child: _isLoading
                ? _buildLoading()
                : _error != null
                    ? _buildError()
                    : _pesananList.isEmpty
                        ? _buildEmptyState()
                        : _buildPesananList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToBuatPesanan,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: AppTheme.white),
        label: Text(
          'Pesan Cetak',
          style: AppTheme.buttonText.copyWith(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelola Pesanan Cetak',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cetak naskah Anda yang sudah diterbitkan',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.white.withValues(alpha: 0.8),
            ),
          ),
          if (_metadata != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_metadata!.total} Pesanan',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = _selectedFilter == option['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(option['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = option['value']!;
                });
                _loadPesanan();
              },
              backgroundColor: AppTheme.white,
              selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.greyText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.greyDisabled,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.black),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Gagal memuat data',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPesanan,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: AppTheme.primaryButtonStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.print_outlined,
              size: 80,
              color: AppTheme.greyMedium.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Pesanan',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.black),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'semua'
                  ? 'Cetak naskah Anda yang sudah diterbitkan\ndengan menekan tombol di bawah'
                  : 'Tidak ada pesanan dengan status "${_filterOptions.firstWhere((e) => e['value'] == _selectedFilter)['label']}"',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_selectedFilter == 'semua')
              ElevatedButton.icon(
                onPressed: _navigateToBuatPesanan,
                icon: const Icon(Icons.add),
                label: const Text('Buat Pesanan Pertama'),
                style: AppTheme.primaryButtonStyle,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPesananList() {
    return RefreshIndicator(
      onRefresh: _loadPesanan,
      color: AppTheme.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _pesananList.length,
        itemBuilder: (context, index) {
          final pesanan = _pesananList[index];
          return _buildPesananCard(pesanan);
        },
      ),
    );
  }

  Widget _buildPesananCard(PesananCetak pesanan) {
    final statusColor = Color(CetakService.getStatusColor(pesanan.status));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(pesanan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nomor Pesanan & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    pesanan.nomorPesanan,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      CetakService.getStatusLabel(pesanan.status),
                      style: AppTheme.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Judul Naskah
              if (pesanan.naskah != null)
                Text(
                  pesanan.naskah!.judul,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              // Info Cetak
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.layers_outlined,
                    label: '${pesanan.jumlah} eks',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.description_outlined,
                    label: pesanan.formatKertas,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.book_outlined,
                    label: pesanan.jenisCover,
                  ),
                ],
              ),
              const Divider(height: 24),
              // Footer: Harga & Tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Harga',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyText,
                        ),
                      ),
                      Text(
                        pesanan.hargaFormatted,
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tanggal Pesan',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyText,
                        ),
                      ),
                      Text(
                        CetakService.formatTanggal(pesanan.tanggalPesan),
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.greyText),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }
}
