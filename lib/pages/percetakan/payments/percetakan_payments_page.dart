import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';

class PercetakanPaymentsPage extends StatefulWidget {
  const PercetakanPaymentsPage({super.key});

  @override
  State<PercetakanPaymentsPage> createState() => _PercetakanPaymentsPageState();
}

class _PercetakanPaymentsPageState extends State<PercetakanPaymentsPage> {
  bool _isLoading = true;
  List<DummyPayment> _payments = [];
  String _selectedFilter = 'semua';
  String? _error;

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
      // Gunakan data dummy
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _payments = _getDummyPayments();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<DummyPayment> _getDummyPayments() {
    final now = DateTime.now();
    return [
      DummyPayment(
        id: '1',
        nomorPesanan: 'PO-2024-001',
        judulNaskah: 'Petualangan Anak Rimba',
        namaPenulis: 'Ahmad Santoso',
        jumlah: 850000,
        metodePembayaran: 'Transfer Bank',
        status: 'pending',
        tanggalPesan: now.subtract(const Duration(hours: 2)),
        tanggalBayar: null,
      ),
      DummyPayment(
        id: '2',
        nomorPesanan: 'PO-2024-002',
        judulNaskah: 'Panduan Bisnis Online',
        namaPenulis: 'Siti Nurhaliza',
        jumlah: 1200000,
        metodePembayaran: 'E-Wallet',
        status: 'completed',
        tanggalPesan: now.subtract(const Duration(days: 2)),
        tanggalBayar: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      DummyPayment(
        id: '3',
        nomorPesanan: 'PO-2024-003',
        judulNaskah: 'Kumpulan Puisi Remaja',
        namaPenulis: 'Budi Prasetyo',
        jumlah: 950000,
        metodePembayaran: 'Transfer Bank',
        status: 'completed',
        tanggalPesan: now.subtract(const Duration(days: 5)),
        tanggalBayar: now.subtract(const Duration(days: 4)),
      ),
      DummyPayment(
        id: '4',
        nomorPesanan: 'PO-2024-004',
        judulNaskah: 'Ensiklopedia Sains Anak',
        namaPenulis: 'Dewi Lestari',
        jumlah: 1500000,
        metodePembayaran: 'Kredit/Tempo',
        status: 'pending',
        tanggalPesan: now.subtract(const Duration(hours: 6)),
        tanggalBayar: null,
      ),
      DummyPayment(
        id: '5',
        nomorPesanan: 'PO-2024-005',
        judulNaskah: 'Resep Masakan Nusantara',
        namaPenulis: 'Rina Kusuma',
        jumlah: 750000,
        metodePembayaran: 'Transfer Bank',
        status: 'completed',
        tanggalPesan: now.subtract(const Duration(days: 3)),
        tanggalBayar: now.subtract(const Duration(days: 2, hours: 12)),
      ),
    ];
  }

  List<DummyPayment> get filteredPayments {
    if (_selectedFilter == 'semua') {
      return _payments;
    }
    return _payments.where((p) => p.status == _selectedFilter).toList();
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
    final totalAmount = _payments.fold<double>(
      0,
      (sum, payment) => sum + payment.jumlah,
    );
    final completedPayments = _payments.where((p) => p.status == 'completed').length;
    final pendingPayments = _payments.where((p) => p.status == 'pending').length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total',
              _formatCurrency(totalAmount),
              Icons.account_balance_wallet,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Lunas',
              completedPayments.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              pendingPayments.toString(),
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

  Widget _buildPaymentCard(DummyPayment payment) {
    final statusColor = payment.status == 'completed' ? Colors.green : Colors.orange;
    final statusLabel = payment.status == 'completed' ? 'Lunas' : 'Pending';

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
                          payment.nomorPesanan,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.judulNaskah,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.namaPenulis,
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
                      payment.metodePembayaran,
                    ),
                  ),
                  Expanded(
                    child: _buildPaymentInfo(
                      Icons.calendar_today,
                      _formatDate(payment.tanggalPesan),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatCurrency(payment.jumlah),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (payment.status == 'pending')
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

  void _showConfirmPaymentDialog(DummyPayment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pesanan: ${payment.nomorPesanan}'),
            Text('Naskah: ${payment.judulNaskah}'),
            const SizedBox(height: 8),
            Text(
              'Jumlah: ${_formatCurrency(payment.jumlah)}',
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

  void _confirmPayment(DummyPayment payment) {
    setState(() {
      final index = _payments.indexWhere((p) => p.id == payment.id);
      if (index != -1) {
        _payments[index] = DummyPayment(
          id: payment.id,
          nomorPesanan: payment.nomorPesanan,
          judulNaskah: payment.judulNaskah,
          namaPenulis: payment.namaPenulis,
          jumlah: payment.jumlah,
          metodePembayaran: payment.metodePembayaran,
          status: 'completed',
          tanggalPesan: payment.tanggalPesan,
          tanggalBayar: DateTime.now(),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran berhasil dikonfirmasi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPaymentDetail(DummyPayment payment) {
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
              _buildDetailRow('Nomor Pesanan', payment.nomorPesanan),
              _buildDetailRow('Judul Naskah', payment.judulNaskah),
              _buildDetailRow('Penulis', payment.namaPenulis),
              _buildDetailRow('Metode Pembayaran', payment.metodePembayaran),
              _buildDetailRow('Status', payment.status == 'completed' ? 'Lunas' : 'Pending'),
              _buildDetailRow('Tanggal Pesan', _formatDate(payment.tanggalPesan)),
              if (payment.tanggalBayar != null)
                _buildDetailRow('Tanggal Bayar', _formatDate(payment.tanggalBayar!)),
              const Divider(height: 32),
              _buildDetailRow(
                'Total',
                _formatCurrency(payment.jumlah),
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

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Dummy Payment Model
class DummyPayment {
  final String id;
  final String nomorPesanan;
  final String judulNaskah;
  final String namaPenulis;
  final double jumlah;
  final String metodePembayaran;
  final String status;
  final DateTime tanggalPesan;
  final DateTime? tanggalBayar;

  DummyPayment({
    required this.id,
    required this.nomorPesanan,
    required this.judulNaskah,
    required this.namaPenulis,
    required this.jumlah,
    required this.metodePembayaran,
    required this.status,
    required this.tanggalPesan,
    this.tanggalBayar,
  });
}
