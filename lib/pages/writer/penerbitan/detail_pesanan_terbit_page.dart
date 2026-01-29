import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/pesanan_terbit_models.dart';
import 'package:publishify/services/writer/pesanan_terbit_service.dart';

/// Halaman detail pesanan penerbitan
class DetailPesananTerbitPage extends StatefulWidget {
  final String pesananId;

  const DetailPesananTerbitPage({
    super.key,
    required this.pesananId,
  });

  @override
  State<DetailPesananTerbitPage> createState() => _DetailPesananTerbitPageState();
}

class _DetailPesananTerbitPageState extends State<DetailPesananTerbitPage>
    with SingleTickerProviderStateMixin {
  PesananTerbitDetail? _pesanan;
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response =
          await PesananTerbitService.getDetailPesananTerbit(widget.pesananId);

      if (response.sukses && response.data != null) {
        setState(() {
          _pesanan = response.data;
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
        title: Text(_pesanan?.nomorPesanan ?? 'Detail Pesanan'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
        bottom: _isLoading || _errorMessage != null
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: AppTheme.white,
                unselectedLabelColor: AppTheme.white.withValues(alpha: 0.7),
                indicatorColor: AppTheme.white,
                tabs: const [
                  Tab(text: 'Info'),
                  Tab(text: 'Spesifikasi'),
                  Tab(text: 'Kelengkapan'),
                  Tab(text: 'Log'),
                ],
              ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInfoTab(),
                    _buildSpesifikasiTab(),
                    _buildKelengkapanTab(),
                    _buildLogTab(),
                  ],
                ),
      bottomNavigationBar: _pesanan != null ? _buildBottomActions() : null,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: AppTheme.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    final pesanan = _pesanan!;
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryGreen,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(pesanan),
            const SizedBox(height: 16),

            // Naskah Info
            if (pesanan.naskah != null) _buildNaskahCard(pesanan.naskah!),
            const SizedBox(height: 16),

            // Paket Info
            if (pesanan.paket != null) _buildPaketCard(pesanan.paket!),
            const SizedBox(height: 16),

            // Detail Pesanan
            _buildDetailCard(pesanan),
            const SizedBox(height: 16),

            // Catatan
            if (pesanan.catatanPenulis != null ||
                pesanan.catatanEditor != null ||
                pesanan.catatanAdmin != null)
              _buildCatatanCard(pesanan),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(PesananTerbitDetail pesanan) {
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
                Text(
                  'Status Pesanan',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(pesanan.statusEnum),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status Pembayaran',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                  ),
                ),
                _buildStatusPembayaranChip(pesanan.statusPembayaranEnum),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Harga',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                  ),
                ),
                Text(
                  _formatRupiah(pesanan.totalHarga),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNaskahCard(NaskahInfoTerbit naskah) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.greyLight,
                borderRadius: BorderRadius.circular(8),
                image: naskah.urlSampul != null
                    ? DecorationImage(
                        image: NetworkImage(naskah.urlSampul!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: naskah.urlSampul == null
                  ? const Icon(Icons.book, color: AppTheme.greyMedium)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    naskah.judul,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (naskah.subJudul != null)
                    Text(
                      naskah.subJudul!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.greyMedium,
                      ),
                    ),
                  if (naskah.jumlahHalaman != null)
                    Text(
                      '${naskah.jumlahHalaman} halaman',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.greyMedium,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaketCard(PaketPenerbitan paket) {
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
                Text(
                  'Paket Penerbitan',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    paket.nama,
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (paket.deskripsi != null) ...[
              const SizedBox(height: 8),
              Text(
                paket.deskripsi!,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyMedium,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (paket.termasukLayoutDesain == true)
                  _buildFeatureChip('Layout & Desain', Icons.dashboard),
                if (paket.termasukProofreading == true)
                  _buildFeatureChip('Proofreading', Icons.spellcheck),
                if (paket.termasukISBN == true)
                  _buildFeatureChip('ISBN', Icons.qr_code),
                if (paket.termasukEbook == true)
                  _buildFeatureChip('E-Book', Icons.menu_book),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppTheme.primaryGreen),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: AppTheme.greyLight,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildDetailCard(PesananTerbitDetail pesanan) {
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
            Text(
              'Detail Pesanan',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Jumlah Buku', '${pesanan.jumlahBuku} buku'),
            _buildDetailRow(
                'Tanggal Pesan', _formatTanggal(pesanan.tanggalPesan)),
            if (pesanan.tanggalBayar != null)
              _buildDetailRow(
                  'Tanggal Bayar', _formatTanggal(pesanan.tanggalBayar!)),
            if (pesanan.tanggalMulaiProses != null)
              _buildDetailRow('Mulai Proses',
                  _formatTanggal(pesanan.tanggalMulaiProses!)),
            if (pesanan.tanggalSelesai != null)
              _buildDetailRow(
                  'Selesai', _formatTanggal(pesanan.tanggalSelesai!)),
            const Divider(height: 24),
            _buildDetailRow('Status Editing', pesanan.statusEditing),
            _buildDetailRow('Status Layout', pesanan.statusLayout),
            _buildDetailRow('Status ISBN', pesanan.statusISBN),
            if (pesanan.isbn != null)
              _buildDetailRow('ISBN', pesanan.isbn!),
            _buildDetailRow(
              'Revisi Desain',
              '${pesanan.jumlahRevisiDesain}/${pesanan.revisiMaksimal}',
            ),
            _buildDetailRow(
              'Revisi Layout',
              '${pesanan.jumlahRevisiLayout}/${pesanan.revisiMaksimal}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyMedium,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanCard(PesananTerbitDetail pesanan) {
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
            Text(
              'Catatan',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (pesanan.catatanPenulis != null)
              _buildCatatanItem('Catatan Penulis', pesanan.catatanPenulis!),
            if (pesanan.catatanEditor != null)
              _buildCatatanItem('Catatan Editor', pesanan.catatanEditor!),
            if (pesanan.catatanAdmin != null)
              _buildCatatanItem('Catatan Admin', pesanan.catatanAdmin!),
          ],
        ),
      ),
    );
  }

  Widget _buildCatatanItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSpesifikasiTab() {
    final spesifikasi = _pesanan?.spesifikasi;
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryGreen,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: spesifikasi == null
            ? _buildEmptySpesifikasi()
            : Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spesifikasi Buku',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      _buildDetailRow('Jenis Sampul', spesifikasi.jenisSampul),
                      _buildDetailRow(
                          'Lapis Sampul', spesifikasi.lapisSampul ?? '-'),
                      _buildDetailRow('Jenis Kertas', spesifikasi.jenisKertas),
                      _buildDetailRow('Ukuran Buku', spesifikasi.ukuranBuku),
                      if (spesifikasi.ukuranBuku == 'Custom')
                        _buildDetailRow(
                          'Ukuran Custom',
                          '${spesifikasi.ukuranCustomPanjang ?? 0} x ${spesifikasi.ukuranCustomLebar ?? 0} mm',
                        ),
                      _buildDetailRow('Jenis Jilid', spesifikasi.jenisJilid),
                      _buildDetailRow(
                          'Laminasi', spesifikasi.laminasi ?? '-'),
                      _buildDetailRow(
                        'Pembatas Buku',
                        spesifikasi.pembatasBuku ? 'Ya' : 'Tidak',
                      ),
                      _buildDetailRow(
                        'Packing Khusus',
                        spesifikasi.packingKhusus ? 'Ya' : 'Tidak',
                      ),
                      if (spesifikasi.catatanTambahan != null) ...[
                        const Divider(height: 24),
                        Text(
                          'Catatan Tambahan',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.greyMedium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          spesifikasi.catatanTambahan!,
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmptySpesifikasi() {
    final canEdit = _pesanan != null &&
        (_pesanan!.status == 'draft' ||
            _pesanan!.status == 'menunggu_pembayaran' ||
            _pesanan!.status == 'pembayaran_dikonfirmasi');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              size: 64,
              color: AppTheme.greyMedium.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada spesifikasi',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
            if (canEdit) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showEditSpesifikasiDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
                icon: const Icon(Icons.add, color: AppTheme.white),
                label: const Text(
                  'Tambah Spesifikasi',
                  style: TextStyle(color: AppTheme.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKelengkapanTab() {
    final kelengkapan = _pesanan?.kelengkapan;
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryGreen,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: kelengkapan == null
            ? _buildEmptyKelengkapan()
            : Card(
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
                          Text(
                            'Kelengkapan Naskah',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildVerifikasiChip(kelengkapan.statusVerifikasi),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildKelengkapanItem(
                          'Kata Pengantar', kelengkapan.adaKataPengantar),
                      _buildKelengkapanItem(
                          'Daftar Isi', kelengkapan.adaDaftarIsi),
                      _buildKelengkapanItem('Bab Isi', kelengkapan.adaBabIsi),
                      _buildKelengkapanItem(
                          'Daftar Pustaka', kelengkapan.adaDaftarPustaka),
                      _buildKelengkapanItem(
                          'Tentang Penulis', kelengkapan.adaTentangPenulis),
                      _buildKelengkapanItem('Sinopsis', kelengkapan.adaSinopsis),
                      _buildKelengkapanItem('Lampiran', kelengkapan.adaLampiran),
                      if (kelengkapan.catatanKelengkapan != null) ...[
                        const Divider(height: 24),
                        Text(
                          'Catatan',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.greyMedium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kelengkapan.catatanKelengkapan!,
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyKelengkapan() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_outlined,
              size: 64,
              color: AppTheme.greyMedium.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data kelengkapan',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showEditKelengkapanDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              icon: const Icon(Icons.add, color: AppTheme.white),
              label: const Text(
                'Tambah Kelengkapan',
                style: TextStyle(color: AppTheme.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKelengkapanItem(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: value ? Colors.green : AppTheme.errorRed,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildVerifikasiChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'lengkap':
        color = Colors.green;
        label = 'Lengkap';
        break;
      case 'tidak_lengkap':
        color = Colors.red;
        label = 'Tidak Lengkap';
        break;
      default:
        color = Colors.orange;
        label = 'Belum Diperiksa';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLogTab() {
    final logs = _pesanan?.logProsesTerbit ?? [];
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryGreen,
      child: logs.isEmpty
          ? Center(
              child: Text(
                'Belum ada log proses',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.greyMedium,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return _buildLogItem(log, index == 0);
              },
            ),
    );
  }

  Widget _buildLogItem(LogProsesTerbit log, bool isLatest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isLatest ? AppTheme.primaryGreen : AppTheme.greyMedium,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 60,
                color: AppTheme.greyLight,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getLabelStatusPenerbitan(
                      statusPenerbitanFromString(log.statusBaru)),
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (log.statusSebelumnya != null)
                  Text(
                    'dari ${getLabelStatusPenerbitan(statusPenerbitanFromString(log.statusSebelumnya))}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyMedium,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatTanggal(log.dibuatPada),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                  ),
                ),
                if (log.catatan != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.catatan!,
                    style: AppTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final pesanan = _pesanan!;
    final canUploadBukti = pesanan.status == 'menunggu_pembayaran' &&
        pesanan.statusPembayaran == 'belum_bayar';
    final canEditSpek = pesanan.status == 'draft' ||
        pesanan.status == 'menunggu_pembayaran' ||
        pesanan.status == 'pembayaran_dikonfirmasi';

    if (!canUploadBukti && !canEditSpek) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canEditSpek)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showEditSpesifikasiDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Spesifikasi'),
              ),
            ),
          if (canUploadBukti && canEditSpek) const SizedBox(width: 12),
          if (canUploadBukti)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _uploadBuktiPembayaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
                icon: const Icon(Icons.upload, color: AppTheme.white),
                label: const Text(
                  'Upload Bukti',
                  style: TextStyle(color: AppTheme.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(StatusPenerbitan status) {
    Color color;
    switch (status) {
      case StatusPenerbitan.draft:
        color = Colors.grey;
        break;
      case StatusPenerbitan.menungguPembayaran:
        color = Colors.orange;
        break;
      case StatusPenerbitan.pembayaranDikonfirmasi:
      case StatusPenerbitan.naskahDikirim:
      case StatusPenerbitan.dalamPemeriksaan:
        color = Colors.blue;
        break;
      case StatusPenerbitan.perluRevisi:
        color = Colors.red;
        break;
      case StatusPenerbitan.prosesEditing:
      case StatusPenerbitan.prosesLayout:
      case StatusPenerbitan.prosesIsbn:
        color = Colors.purple;
        break;
      case StatusPenerbitan.siapTerbit:
        color = Colors.teal;
        break;
      case StatusPenerbitan.diterbitkan:
      case StatusPenerbitan.dalamDistribusi:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        getLabelStatusPenerbitan(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusPembayaranChip(StatusPembayaranTerbit status) {
    Color color;
    switch (status) {
      case StatusPembayaranTerbit.belumBayar:
        color = Colors.red;
        break;
      case StatusPembayaranTerbit.menungguKonfirmasi:
        color = Colors.orange;
        break;
      case StatusPembayaranTerbit.lunas:
        color = Colors.green;
        break;
      case StatusPembayaranTerbit.dibatalkan:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        getLabelStatusPembayaran(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showEditSpesifikasiDialog() {
    // TODO: Implement edit spesifikasi dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur edit spesifikasi akan segera tersedia'),
      ),
    );
  }

  void _showEditKelengkapanDialog() {
    // TODO: Implement edit kelengkapan dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur edit kelengkapan akan segera tersedia'),
      ),
    );
  }

  Future<void> _uploadBuktiPembayaran() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
        ),
      );

      try {
        final response = await PesananTerbitService.uploadBuktiPembayaran(
          widget.pesananId,
          file,
        );

        Navigator.pop(context); // Close loading

        if (response.sukses) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  String _formatTanggal(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final bulan = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${date.day} ${bulan[date.month]} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatRupiah(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }
}
