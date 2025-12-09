import 'package:flutter/material.dart';
import 'package:publishify/models/percetakan/percetakan_models.dart';
import 'package:publishify/services/percetakan/percetakan_service.dart';
import 'package:publishify/utils/theme.dart';

class PercetakanDashboardPage extends StatefulWidget {
  const PercetakanDashboardPage({super.key});

  @override
  State<PercetakanDashboardPage> createState() => _PercetakanDashboardPageState();
}

class _PercetakanDashboardPageState extends State<PercetakanDashboardPage> {
  bool _isLoading = true;
  List<PesananCetak> _recentOrders = [];
  PercetakanStats? _stats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Gunakan data dummy untuk sementara
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _recentOrders = _getDummyOrders();
        _stats = _getDummyStats();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Data dummy untuk pesanan
  List<PesananCetak> _getDummyOrders() {
    final now = DateTime.now();
    return [
      PesananCetak(
        id: '1',
        idNaskah: 'naskah-1',
        idPemesan: 'penulis-1',
        nomorPesanan: 'PO-2024-001',
        jumlah: 100,
        formatKertas: 'A5',
        jenisKertas: 'HVS 70gr',
        jenisCover: 'Soft Cover',
        finishingTambahan: ['Laminasi Doff'],
        catatan: 'Mohon dikerjakan dengan teliti',
        hargaTotal: '850000',
        status: 'tertunda',
        tanggalPesan: now.subtract(const Duration(hours: 2)),
        estimasiSelesai: now.add(const Duration(days: 7)),
        diperbaruiPada: now.subtract(const Duration(hours: 2)),
        naskah: const NaskahInfo(
          id: 'naskah-1',
          judul: 'Petualangan Anak Rimba',
          jumlahHalaman: 120,
        ),
        pemesan: const PemesanInfo(
          id: 'penulis-1',
          email: 'ahmad@example.com',
          profilPengguna: ProfilPenggunaInfo(
            namaDepan: 'Ahmad',
            namaBelakang: 'Santoso',
          ),
        ),
      ),
      PesananCetak(
        id: '2',
        idNaskah: 'naskah-2',
        idPemesan: 'penulis-2',
        nomorPesanan: 'PO-2024-002',
        jumlah: 50,
        formatKertas: 'A4',
        jenisKertas: 'Art Paper 120gr',
        jenisCover: 'Hard Cover',
        finishingTambahan: ['Emboss', 'Spot UV'],
        hargaTotal: '1200000',
        status: 'dalam_produksi',
        tanggalPesan: now.subtract(const Duration(days: 2)),
        estimasiSelesai: now.add(const Duration(days: 5)),
        diperbaruiPada: now.subtract(const Duration(hours: 6)),
        naskah: const NaskahInfo(
          id: 'naskah-2',
          judul: 'Panduan Bisnis Online',
          jumlahHalaman: 200,
        ),
        pemesan: const PemesanInfo(
          id: 'penulis-2',
          email: 'siti@example.com',
          profilPengguna: ProfilPenggunaInfo(
            namaDepan: 'Siti',
            namaBelakang: 'Nurhaliza',
          ),
        ),
      ),
      PesananCetak(
        id: '3',
        idNaskah: 'naskah-3',
        idPemesan: 'penulis-3',
        nomorPesanan: 'PO-2024-003',
        jumlah: 200,
        formatKertas: '14x20cm',
        jenisKertas: 'Book Paper 70gr',
        jenisCover: 'Soft Cover',
        finishingTambahan: ['Laminasi Glossy'],
        hargaTotal: '950000',
        status: 'siap',
        tanggalPesan: now.subtract(const Duration(days: 5)),
        estimasiSelesai: now.add(const Duration(days: 2)),
        diperbaruiPada: now.subtract(const Duration(hours: 12)),
        naskah: const NaskahInfo(
          id: 'naskah-3',
          judul: 'Kumpulan Puisi Remaja',
          jumlahHalaman: 80,
        ),
        pemesan: const PemesanInfo(
          id: 'penulis-3',
          email: 'budi@example.com',
          profilPengguna: ProfilPenggunaInfo(
            namaDepan: 'Budi',
            namaBelakang: 'Prasetyo',
          ),
        ),
      ),
    ];
  }

  // Data dummy untuk statistik
  PercetakanStats _getDummyStats() {
    return const PercetakanStats(
      totalPesanan: 45,
      pesananAktif: 12,
      pesananSelesai: 33,
      totalRevenue: '15000000',
      statusBreakdown: StatusBreakdown(
        tertunda: 5,
        diterima: 3,
        dalamProduksi: 2,
        kontrolKualitas: 1,
        siap: 1,
        dikirim: 2,
        terkirim: 30,
        dibatalkan: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Dashboard Percetakan',
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
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsCards(),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        _buildRecentOrders(),
                      ],
                    ),
                  ),
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
            onPressed: _loadDashboardData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    if (_stats == null) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Pesanan',
                _stats!.totalPesanan.toString(),
                Icons.shopping_bag_outlined,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Pesanan Aktif',
                _stats!.pesananAktif.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Selesai',
                _stats!.pesananSelesai.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Revenue',
                PercetakanService.formatHarga(_stats!.totalRevenue),
                Icons.attach_money,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatusBreakdown(),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    if (_stats == null) return const SizedBox();

    final breakdown = _stats!.statusBreakdown;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow('tertunda', breakdown.tertunda, Colors.grey),
          _buildStatusRow('diterima', breakdown.diterima, Colors.blue),
          _buildStatusRow('dalam_produksi', breakdown.dalamProduksi, Colors.orange),
          _buildStatusRow('kontrol_kualitas', breakdown.kontrolKualitas, Colors.purple),
          _buildStatusRow('siap', breakdown.siap, Colors.green),
          _buildStatusRow('dikirim', breakdown.dikirim, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status, int count, Color color) {
    final labelStatus = PercetakanService.ambilLabelStatus();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              labelStatus[status] ?? status,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final menuItems = PercetakanService.ambilMenuItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: menuItems.length > 4 ? 4 : menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return _buildQuickActionCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> item) {
    final colorMap = {
      'blue': Colors.blue,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'green': Colors.green,
      'indigo': Colors.indigo,
    };

    final color = colorMap[item['warna']] ?? Colors.blue;

    return InkWell(
      onTap: () {
        // TODO: Navigate to respective page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigasi ke ${item['judul']}')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconData(item['icon']),
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              item['judul'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item['subjudul'],
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'inbox': Icons.inbox,
      'print': Icons.print,
      'check_circle': Icons.check_circle,
      'local_shipping': Icons.local_shipping,
      'analytics': Icons.analytics,
    };
    return iconMap[iconName] ?? Icons.help_outline;
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pesanan Terbaru',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all orders
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lihat semua pesanan')),
                );
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _recentOrders.isEmpty
            ? _buildEmptyOrders()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentOrders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(_recentOrders[index]);
                },
              ),
      ],
    );
  }

  Widget _buildEmptyOrders() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(PesananCetak order) {
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

    final statusColor = colorMap[warnaStatus[order.status]] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to order detail
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detail pesanan ${order.nomorPesanan}')),
          );
        },
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
                          order.naskah?.judul ?? 'Tanpa Judul',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pemesan: ${order.pemesan?.profilPengguna?.namaLengkap ?? order.pemesan?.email ?? "Unknown"}',
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
                      color: statusColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      labelStatus[order.status] ?? order.status,
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
                    child: _buildOrderInfo(
                      Icons.shopping_cart_outlined,
                      '${order.jumlah} copy',
                    ),
                  ),
                  Expanded(
                    child: _buildOrderInfo(
                      Icons.calendar_today_outlined,
                      PercetakanService.formatTanggal(order.tanggalPesan),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    PercetakanService.formatHarga(order.hargaTotal),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (order.estimasiSelesai != null)
                    Text(
                      'Target: ${PercetakanService.formatTanggal(order.estimasiSelesai!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  Widget _buildOrderInfo(IconData icon, String text) {
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
}
