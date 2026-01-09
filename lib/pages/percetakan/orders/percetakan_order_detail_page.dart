import 'package:flutter/material.dart';
import 'package:publishify/models/percetakan/percetakan_models.dart';
import 'package:publishify/services/percetakan/percetakan_service.dart';
import 'package:publishify/utils/theme.dart';

class PercetakanOrderDetailPage extends StatefulWidget {
  final String idPesanan;

  const PercetakanOrderDetailPage({
    super.key,
    required this.idPesanan,
  });

  @override
  State<PercetakanOrderDetailPage> createState() =>
      _PercetakanOrderDetailPageState();
}

class _PercetakanOrderDetailPageState extends State<PercetakanOrderDetailPage> {
  bool _isLoading = true;
  bool _isProcessing = false;
  PesananCetak? _pesanan;
  String? _error;

  // Form controllers untuk konfirmasi
  final _formKey = GlobalKey<FormState>();
  final _hargaTotalController = TextEditingController();
  final _catatanController = TextEditingController();
  DateTime? _estimasiSelesai;

  @override
  void initState() {
    super.initState();
    _loadDetailPesanan();
  }

  @override
  void dispose() {
    _hargaTotalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadDetailPesanan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response =
          await PercetakanService.ambilDetailPesanan(widget.idPesanan);

      if (!mounted) return;

      if (response.sukses && response.data != null) {
        setState(() {
          _pesanan = response.data;
          _isLoading = false;
          // Pre-fill form dengan harga total dari pesanan
          _hargaTotalController.text = response.data!.hargaTotal;
        });
      } else {
        setState(() {
          _error = response.pesan ?? 'Gagal memuat detail pesanan';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _konfirmasiPesanan(bool diterima) async {
    // Validasi form jika menerima pesanan
    if (diterima && !_formKey.currentState!.validate()) {
      return;
    }

    // Konfirmasi dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(diterima ? 'Terima Pesanan?' : 'Tolak Pesanan?'),
        content: Text(
          diterima
              ? 'Apakah Anda yakin ingin menerima pesanan ini? Pesanan akan masuk ke daftar produksi.'
              : 'Apakah Anda yakin ingin menolak pesanan ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: diterima ? AppTheme.primaryGreen : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(diterima ? 'Ya, Terima' : 'Ya, Tolak'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      double? hargaTotal;
      if (diterima && _hargaTotalController.text.isNotEmpty) {
        hargaTotal = double.tryParse(_hargaTotalController.text);
      }

      final response = await PercetakanService.konfirmasiPesanan(
        widget.idPesanan,
        diterima: diterima,
        hargaTotal: hargaTotal,
        estimasiSelesai: _estimasiSelesai,
        catatan: _catatanController.text.isNotEmpty
            ? _catatanController.text
            : null,
      );

      if (!mounted) return;

      if (response.sukses) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              diterima
                  ? 'Pesanan berhasil diterima'
                  : 'Pesanan berhasil ditolak',
            ),
            backgroundColor: diterima ? Colors.green : Colors.orange,
          ),
        );

        // Kembali ke halaman sebelumnya dengan hasil true
        Navigator.pop(context, true);
      } else {
        throw Exception(response.pesan ?? 'Gagal memproses pesanan');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _estimasiSelesai ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _estimasiSelesai = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _pesanan == null
                  ? _buildEmptyWidget()
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadDetailPesanan,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildNaskahInfo(),
            const SizedBox(height: 16),
            _buildPemesanInfo(),
            const SizedBox(height: 16),
            _buildDetailPesanan(),
            const SizedBox(height: 16),
            _buildHargaInfo(),
            if (_pesanan!.status == 'tertunda') ...[
              const SizedBox(height: 24),
              _buildKonfirmasiForm(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ] else ...[
              const SizedBox(height: 16),
              _buildProgressButtons(),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final labelStatus = PercetakanService.ambilLabelStatus();
    final warnaStatus = PercetakanService.ambilWarnaStatus();

    final colorMap = {
      'grey': Colors.grey,
      'blue': Colors.blue,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'green': Colors.green,
      'teal': Colors.teal,
      'red': Colors.red,
    };

    final statusColor = colorMap[warnaStatus[_pesanan!.status]] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nomor Pesanan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _pesanan!.nomorPesanan,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  labelStatus[_pesanan!.status] ?? _pesanan!.status,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Tanggal Pesan: ${PercetakanService.formatTanggal(_pesanan!.tanggalPesan)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (_pesanan!.estimasiSelesai != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Target Selesai: ${PercetakanService.formatTanggal(_pesanan!.estimasiSelesai!)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNaskahInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Naskah',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: _pesanan!.naskah?.urlSampul != null
                      ? DecorationImage(
                          image: NetworkImage(_pesanan!.naskah!.urlSampul!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _pesanan!.naskah?.urlSampul == null
                    ? Icon(Icons.book, color: Colors.grey[400], size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pesanan!.naskah?.judul ?? 'Tanpa Judul',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_pesanan!.naskah?.jumlahHalaman != null)
                      Row(
                        children: [
                          Icon(Icons.description, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${_pesanan!.naskah!.jumlahHalaman} halaman',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPemesanInfo() {
    final pemesan = _pesanan!.pemesan;
    final namaPemesan = pemesan?.profilPengguna?.namaLengkap ?? pemesan?.email ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pemesan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Nama', namaPemesan),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email, 'Email', pemesan?.email ?? '-'),
        ],
      ),
    );
  }

  Widget _buildDetailPesanan() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.print, 'Jumlah', '${_pesanan!.jumlah} copy'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.description_outlined, 'Format Kertas', _pesanan!.formatKertas),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.layers_outlined, 'Jenis Kertas', _pesanan!.jenisKertas),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.book_outlined, 'Jenis Cover', _pesanan!.jenisCover),
          if (_pesanan!.finishingTambahan.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.auto_awesome,
              'Finishing Tambahan',
              _pesanan!.finishingTambahan.join(', '),
            ),
          ],
          if (_pesanan!.catatan != null && _pesanan!.catatan!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Catatan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _pesanan!.catatan!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHargaInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.1),
            AppTheme.primaryGreen.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Harga',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            PercetakanService.formatHarga(_pesanan!.hargaTotal),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKonfirmasiForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Form Konfirmasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hargaTotalController,
              keyboardType: TextInputType.number,
              decoration: AppTheme.inputDecoration(
                hintText: 'Masukkan harga total (opsional)',
                prefixIcon: const Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final harga = double.tryParse(value);
                  if (harga == null || harga <= 0) {
                    return 'Harga harus berupa angka positif';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pilihTanggal,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.greyDisabled,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.greyMedium),
                    const SizedBox(width: 12),
                    Text(
                      _estimasiSelesai == null
                          ? 'Pilih estimasi selesai (opsional)'
                          : 'Estimasi: ${PercetakanService.formatTanggal(_estimasiSelesai!)}',
                      style: TextStyle(
                        color: _estimasiSelesai == null
                            ? AppTheme.greyText
                            : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _catatanController,
              maxLines: 4,
              maxLength: 500,
              decoration: AppTheme.inputDecoration(
                hintText: 'Catatan untuk pemesan (opsional)',
                prefixIcon: const Icon(Icons.note),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : () => _konfirmasiPesanan(true),
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle),
            label: Text(
              _isProcessing ? 'Memproses...' : 'Terima Pesanan',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : () => _konfirmasiPesanan(false),
            icon: const Icon(Icons.cancel),
            label: const Text(
              'Tolak Pesanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressButtons() {
    final currentStatus = _pesanan!.status;
    final labelStatus = PercetakanService.ambilLabelStatus();
    
    // Definisi urutan status
    final statusFlow = [
      {'key': 'diterima', 'label': 'Diterima', 'next': 'dalam_produksi', 'icon': Icons.check_circle},
      {'key': 'dalam_produksi', 'label': 'Mulai Produksi', 'next': 'kontrol_kualitas', 'icon': Icons.build},
      {'key': 'kontrol_kualitas', 'label': 'Kontrol Kualitas', 'next': 'siap', 'icon': Icons.verified},
      {'key': 'siap', 'label': 'Siap Kirim', 'next': 'dikirim', 'icon': Icons.inventory},
      {'key': 'dikirim', 'label': 'Dikirim', 'next': 'terkirim', 'icon': Icons.local_shipping},
      {'key': 'terkirim', 'label': 'Selesai', 'next': null, 'icon': Icons.done_all},
    ];

    // Cari index status saat ini
    int currentIndex = statusFlow.indexWhere((s) => s['key'] == currentStatus);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Icon(Icons.timeline, color: AppTheme.primaryGreen, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Progress Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${labelStatus[currentStatus] ?? currentStatus}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Progress buttons
          ...List.generate(statusFlow.length, (index) {
            final step = statusFlow[index];
            final stepLabel = step['label'] as String;
            final nextStatus = step['next'] as String?;
            final stepIcon = step['icon'] as IconData;
            
            final isCompleted = currentIndex > index;
            final isCurrent = currentIndex == index;
            final isNext = currentIndex == index - 1;
            final isLocked = currentIndex < index - 1;
            
            return Column(
              children: [
                _buildProgressButton(
                  label: stepLabel,
                  icon: stepIcon,
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                  isNext: isNext,
                  isLocked: isLocked,
                  onPressed: isNext && nextStatus != null
                      ? () => _updateStatus(nextStatus)
                      : null,
                ),
                if (index < statusFlow.length - 1)
                  _buildProgressConnector(isCompleted || isCurrent),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressButton({
    required String label,
    required IconData icon,
    required bool isCompleted,
    required bool isCurrent,
    required bool isNext,
    required bool isLocked,
    VoidCallback? onPressed,
  }) {
    Color getColor() {
      if (isCompleted) return Colors.green;
      if (isCurrent) return AppTheme.primaryGreen;
      if (isNext) return Colors.blue;
      return Colors.grey;
    }

    final color = getColor();
    final canPress = isNext && onPressed != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canPress ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted 
              ? Colors.green.withValues(alpha: 0.1)
              : isCurrent
                  ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                  : isNext
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.05),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: color.withValues(alpha: isLocked ? 0.2 : 0.5),
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCompleted
                        ? 'Selesai'
                        : isCurrent
                            ? 'Status saat ini'
                            : isNext
                                ? 'Tekan untuk lanjut'
                                : 'Belum dapat diakses',
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (canPress)
              Icon(Icons.arrow_forward, color: color, size: 20)
            else if (isLocked)
              Icon(Icons.lock_outline, color: color.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressConnector(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 28),
          Container(
            width: 3,
            height: 24,
            decoration: BoxDecoration(
              color: isActive 
                  ? AppTheme.primaryGreen.withValues(alpha: 0.5)
                  : Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    final labelStatus = PercetakanService.ambilLabelStatus();
    
    // Konfirmasi dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status Pesanan'),
        content: Text(
          'Apakah Anda yakin ingin mengubah status pesanan menjadi "${labelStatus[newStatus]}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Update'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await PercetakanService.perbaruiStatusPesanan(
        widget.idPesanan,
        newStatus,
      );

      if (!mounted) return;

      if (response.sukses) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status berhasil diperbarui menjadi ${labelStatus[newStatus]}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload detail
        await _loadDetailPesanan();
      } else {
        throw Exception(response.pesan ?? 'Gagal memperbarui status');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDetailPesanan,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Pesanan tidak ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
