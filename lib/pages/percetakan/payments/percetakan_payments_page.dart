import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/percetakan/pembayaran_models.dart';
import 'package:publishify/services/percetakan/pembayaran_service.dart';

class PercetakanPaymentsPage extends StatefulWidget {
  const PercetakanPaymentsPage({super.key});

  @override
  State<PercetakanPaymentsPage> createState() => _PercetakanPaymentsPageState();
}

class _PercetakanPaymentsPageState extends State<PercetakanPaymentsPage> {
  bool _isLoading = true;
  List<Pembayaran> _payments = [];
  String _selectedFilter = 'semua';
  String? _error;

  // Statistik pembayaran
  int _totalPembayaran = 0;
  int _pendingCount = 0;
  int _completedCount = 0;
  String _totalAmount = '0';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Map filter ke status backend
      String? statusFilter;
      if (_selectedFilter == 'pending') {
        statusFilter = 'tertunda';
      } else if (_selectedFilter == 'completed') {
        statusFilter = 'berhasil';
      }

      // Ambil data pembayaran dari server
      final response = await PembayaranService.ambilDaftarPembayaran(
        halaman: 1,
        limit: 50,
        status: statusFilter,
      );

      if (!mounted) return;

      if (response.sukses && response.data != null) {
        setState(() {
          _payments = response.data!;
          _calculateStats();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.pesan ?? 'Gagal memuat data pembayaran';
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

  void _calculateStats() {
    _totalPembayaran = _payments.length;
    _pendingCount = _payments.where((p) => 
        p.status == 'tertunda' || p.status == 'diproses').length;
    _completedCount = _payments.where((p) => p.status == 'berhasil').length;
    
    double total = 0;
    for (final payment in _payments) {
      total += double.tryParse(payment.jumlah) ?? 0;
    }
    _totalAmount = total.toStringAsFixed(0);
  }

  List<Pembayaran> get filteredPayments {
    if (_selectedFilter == 'semua') {
      return _payments;
    } else if (_selectedFilter == 'pending') {
      return _payments.where((p) => 
          p.status == 'tertunda' || p.status == 'diproses').toList();
    } else if (_selectedFilter == 'completed') {
      return _payments.where((p) => p.status == 'berhasil').toList();
    }
    return _payments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 8),
                    _buildFilterChips(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadPayments,
                        child: filteredPayments.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredPayments.length,
                                itemBuilder: (context, index) {
                                  return _buildPaymentCard(filteredPayments[index]);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPayments,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total',
              _totalPembayaran.toString(),
              Icons.payment,
              AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Pendapatan',
              PembayaranService.formatHarga(_totalAmount),
              Icons.account_balance_wallet,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Lunas',
              _completedCount.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              _pendingCount.toString(),
              Icons.pending,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Semua', 'semua'),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Lunas', 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pembayaran',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Pembayaran payment) {
    final labelStatus = PembayaranService.ambilLabelStatus();
    final warnaStatus = PembayaranService.ambilWarnaStatus();
    final labelMetode = PembayaranService.ambilLabelMetode();
    
    final colorMap = {
      'orange': Colors.orange,
      'blue': Colors.blue,
      'green': Colors.green,
      'red': Colors.red,
      'purple': Colors.purple,
    };

    final statusColor = colorMap[warnaStatus[payment.status]] ?? Colors.grey;
    final statusLabel = labelStatus[payment.status] ?? payment.status;

    // Dapatkan info pesanan dan pengguna
    final nomorPesanan = payment.pesanan?.nomorPesanan ?? '-';
    final judulNaskah = payment.pesanan?.naskah?.judul ?? 'Tidak ada judul';
    final namaPenulis = payment.pengguna?.namaLengkap ?? payment.pengguna?.email ?? 'Unknown';
    final metodePembayaran = labelMetode[payment.metodePembayaran] ?? payment.metodePembayaran;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showPaymentDetail(payment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        Text(
                          nomorPesanan,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          judulNaskah,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          namaPenulis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentInfo(
                      Icons.payment,
                      metodePembayaran,
                    ),
                  ),
                  Expanded(
                    child: _buildPaymentInfo(
                      Icons.calendar_today,
                      PembayaranService.formatTanggal(payment.dibuatPada),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    PembayaranService.formatHarga(payment.jumlah),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (payment.status == 'tertunda' || payment.status == 'diproses')
                    ElevatedButton.icon(
                      onPressed: () => _showConfirmPaymentDialog(payment),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Konfirmasi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
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

  Widget _buildPaymentInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // void _showFilterDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Filter Pembayaran'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           RadioListTile<String>(
  //             title: const Text('Semua'),
  //             value: 'semua',
  //             groupValue: _selectedFilter,
  //             onChanged: (value) {
  //               setState(() {
  //                 _selectedFilter = value!;
  //               });
  //               Navigator.pop(context);
  //             },
  //           ),
  //           RadioListTile<String>(
  //             title: const Text('Pending'),
  //             value: 'pending',
  //             groupValue: _selectedFilter,
  //             onChanged: (value) {
  //               setState(() {
  //                 _selectedFilter = value!;
  //               });
  //               Navigator.pop(context);
  //             },
  //           ),
  //           RadioListTile<String>(
  //             title: const Text('Lunas'),
  //             value: 'completed',
  //             groupValue: _selectedFilter,
  //             onChanged: (value) {
  //               setState(() {
  //                 _selectedFilter = value!;
  //               });
  //               Navigator.pop(context);
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showConfirmPaymentDialog(Pembayaran payment) {
    final nomorPesanan = payment.pesanan?.nomorPesanan ?? '-';
    final judulNaskah = payment.pesanan?.naskah?.judul ?? 'Tidak ada judul';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pesanan: $nomorPesanan'),
            Text('Naskah: $judulNaskah'),
            const SizedBox(height: 8),
            Text(
              'Jumlah: ${PembayaranService.formatHarga(payment.jumlah)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Apakah pembayaran sudah diterima?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmPayment(payment);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPayment(Pembayaran payment) async {
    try {
      final response = await PembayaranService.konfirmasiPembayaran(
        payment.id,
        diterima: true,
      );

      if (!mounted) return;

      if (response.sukses) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil dikonfirmasi'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload data
        await _loadPayments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.pesan ?? 'Gagal mengkonfirmasi pembayaran'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentDetail(Pembayaran payment) {
    final labelStatus = PembayaranService.ambilLabelStatus();
    final labelMetode = PembayaranService.ambilLabelMetode();
    
    final nomorPesanan = payment.pesanan?.nomorPesanan ?? '-';
    final judulNaskah = payment.pesanan?.naskah?.judul ?? 'Tidak ada judul';
    final namaPenulis = payment.pengguna?.namaLengkap ?? payment.pengguna?.email ?? 'Unknown';
    final metodePembayaran = labelMetode[payment.metodePembayaran] ?? payment.metodePembayaran;
    final statusLabel = labelStatus[payment.status] ?? payment.status;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Detail Pembayaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Nomor Transaksi', payment.nomorTransaksi),
              _buildDetailRow('Nomor Pesanan', nomorPesanan),
              _buildDetailRow('Judul Naskah', judulNaskah),
              _buildDetailRow('Penulis', namaPenulis),
              _buildDetailRow('Metode Pembayaran', metodePembayaran),
              _buildDetailRow('Status', statusLabel),
              _buildDetailRow('Tanggal Dibuat', PembayaranService.formatTanggal(payment.dibuatPada)),
              if (payment.tanggalPembayaran != null)
                _buildDetailRow('Tanggal Bayar', PembayaranService.formatTanggal(payment.tanggalPembayaran!)),
              if (payment.catatanPembayaran != null && payment.catatanPembayaran!.isNotEmpty)
                _buildDetailRow('Catatan', payment.catatanPembayaran!),
              const Divider(height: 32),
              _buildDetailRow(
                'Total',
                PembayaranService.formatHarga(payment.jumlah),
                valueStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
