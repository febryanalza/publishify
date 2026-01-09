import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/cetak_models.dart';
import 'package:publishify/services/writer/cetak_service.dart';

/// Halaman detail pesanan cetak
class DetailPesananCetakPage extends StatefulWidget {
  final String pesananId;

  const DetailPesananCetakPage({
    super.key,
    required this.pesananId,
  });

  @override
  State<DetailPesananCetakPage> createState() => _DetailPesananCetakPageState();
}

class _DetailPesananCetakPageState extends State<DetailPesananCetakPage> {
  PesananCetak? _pesanan;
  bool _isLoading = true;
  String? _error;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await CetakService.ambilDetailPesanan(widget.pesananId);

    setState(() {
      _isLoading = false;
      if (response.sukses && response.data != null) {
        _pesanan = response.data;
      } else {
        _error = response.pesan;
      }
    });
  }

  Future<void> _batalkanPesanan() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pesanan ini?\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isCancelling = true;
    });

    final response = await CetakService.batalkanPesanan(widget.pesananId);

    setState(() {
      _isCancelling = false;
    });

    if (response.sukses) {
      _showSnackBar('Pesanan berhasil dibatalkan');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      _showSnackBar(response.pesan ?? 'Gagal membatalkan pesanan', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          'Detail Pesanan',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.white),
            onPressed: _loadDetail,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _buildContent(),
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
              'Gagal Memuat Data',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.black),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Terjadi kesalahan',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: AppTheme.primaryButtonStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final pesanan = _pesanan!;
    final statusColor = Color(CetakService.getStatusColor(pesanan.status));

    return SingleChildScrollView(
      child: Column(
        children: [
          // Status Header
          _buildStatusHeader(pesanan, statusColor),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Pesanan
                _buildInfoCard(pesanan),
                const SizedBox(height: 16),
                
                // Info Naskah
                if (pesanan.naskah != null) ...[
                  _buildNaskahCard(pesanan.naskah!),
                  const SizedBox(height: 16),
                ],
                
                // Spesifikasi Cetak
                _buildSpesifikasiCard(pesanan),
                const SizedBox(height: 16),
                
                // Info Pengiriman (jika ada)
                if (pesanan.pengiriman != null) ...[
                  _buildPengirimanCard(pesanan.pengiriman!),
                  const SizedBox(height: 16),
                ],
                
                // Catatan
                if (pesanan.catatan != null && pesanan.catatan!.isNotEmpty) ...[
                  _buildCatatanCard(pesanan.catatan!),
                  const SizedBox(height: 16),
                ],
                
                // Ringkasan Harga
                _buildHargaCard(pesanan),
                const SizedBox(height: 24),
                
                // Tombol Aksi
                if (pesanan.status == 'tertunda') _buildActionButtons(),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(PesananCetak pesanan, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(pesanan.status),
              size: 40,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            CetakService.getStatusLabel(pesanan.status),
            style: AppTheme.headingSmall.copyWith(color: statusColor),
          ),
          const SizedBox(height: 4),
          Text(
            pesanan.nomorPesanan,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyText),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    const icons = {
      'tertunda': Icons.hourglass_empty,
      'diterima': Icons.check_circle_outline,
      'dalam_produksi': Icons.precision_manufacturing,
      'kontrol_kualitas': Icons.fact_check_outlined,
      'siap': Icons.inventory_2_outlined,
      'dikirim': Icons.local_shipping_outlined,
      'terkirim': Icons.done_all,
      'dibatalkan': Icons.cancel_outlined,
    };
    return icons[status] ?? Icons.help_outline;
  }

  Widget _buildInfoCard(PesananCetak pesanan) {
    return _buildCard(
      title: 'Informasi Pesanan',
      icon: Icons.receipt_long_outlined,
      children: [
        _buildInfoRow('Nomor Pesanan', pesanan.nomorPesanan),
        _buildInfoRow('Tanggal Pesan', CetakService.formatTanggalWaktu(pesanan.tanggalPesan)),
        if (pesanan.tanggalSelesai != null)
          _buildInfoRow('Tanggal Selesai', CetakService.formatTanggalWaktu(pesanan.tanggalSelesai!)),
      ],
    );
  }

  Widget _buildNaskahCard(NaskahInfo naskah) {
    return _buildCard(
      title: 'Naskah',
      icon: Icons.menu_book_outlined,
      children: [
        _buildInfoRow('Judul', naskah.judul),
        if (naskah.isbn != null) _buildInfoRow('ISBN', naskah.isbn!),
        if (naskah.jumlahHalaman != null)
          _buildInfoRow('Jumlah Halaman', '${naskah.jumlahHalaman} halaman'),
      ],
    );
  }

  Widget _buildSpesifikasiCard(PesananCetak pesanan) {
    return _buildCard(
      title: 'Spesifikasi Cetak',
      icon: Icons.settings_outlined,
      children: [
        _buildInfoRow('Jumlah Eksemplar', '${pesanan.jumlah} eks'),
        _buildInfoRow('Format Kertas', pesanan.formatKertas),
        _buildInfoRow('Jenis Kertas', pesanan.jenisKertas),
        _buildInfoRow('Jenis Cover', pesanan.jenisCover),
        if (pesanan.finishingTambahan.isNotEmpty &&
            !pesanan.finishingTambahan.contains('Tidak Ada'))
          _buildInfoRow('Finishing', pesanan.finishingTambahan.join(', ')),
      ],
    );
  }

  Widget _buildPengirimanCard(PengirimanInfo pengiriman) {
    return _buildCard(
      title: 'Informasi Pengiriman',
      icon: Icons.local_shipping_outlined,
      children: [
        if (pengiriman.namaEkspedisi != null)
          _buildInfoRow('Ekspedisi', pengiriman.namaEkspedisi!),
        if (pengiriman.nomorResi != null)
          _buildInfoRow('Nomor Resi', pengiriman.nomorResi!),
        if (pengiriman.status != null)
          _buildInfoRow('Status', pengiriman.status!),
        if (pengiriman.alamatTujuan != null)
          _buildInfoRow('Alamat', pengiriman.alamatTujuan!),
      ],
    );
  }

  Widget _buildCatatanCard(String catatan) {
    return _buildCard(
      title: 'Catatan',
      icon: Icons.note_outlined,
      children: [
        Text(
          catatan,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.black),
        ),
      ],
    );
  }

  Widget _buildHargaCard(PesananCetak pesanan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Harga',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyText),
              ),
              const SizedBox(height: 4),
              Text(
                pesanan.hargaFormatted,
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppTheme.primaryGreen,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.greyText),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _isCancelling ? null : _batalkanPesanan,
            icon: _isCancelling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.errorRed),
                    ),
                  )
                : const Icon(Icons.cancel_outlined, color: AppTheme.errorRed),
            label: Text(
              'Batalkan Pesanan',
              style: AppTheme.buttonText.copyWith(color: AppTheme.errorRed),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.errorRed),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pesanan hanya dapat dibatalkan selama masih dalam status "Menunggu Konfirmasi"',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.greyText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
