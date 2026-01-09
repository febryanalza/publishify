import 'package:flutter/material.dart';
import 'package:publishify/models/percetakan/percetakan_models.dart';
import 'package:publishify/services/percetakan/percetakan_service.dart';
import 'package:publishify/utils/theme.dart';

class PercetakanOrdersPage extends StatefulWidget {
  const PercetakanOrdersPage({super.key});

  @override
  State<PercetakanOrdersPage> createState() => _PercetakanOrdersPageState();
}

class _PercetakanOrdersPageState extends State<PercetakanOrdersPage> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<PesananCetak> _pesanan = [];
  String? _error;
  String? _selectedStatus;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Pagination
  int _currentPage = 1;
  final int _limit = 20;
  int _totalPages = 1;
  int _totalPesanan = 0;

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPesanan({bool loadMore = false}) async {
    if (loadMore) {
      if (_currentPage >= _totalPages) return;
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
      });
    }

    try {
      final response = await PercetakanService.ambilDaftarPesanan(
        halaman: _currentPage,
        limit: _limit,
        status: _selectedStatus,
        cari: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (!mounted) return;

      setState(() {
        if (loadMore) {
          _pesanan.addAll(response.data ?? []);
          _isLoadingMore = false;
        } else {
          _pesanan = response.data ?? [];
          _isLoading = false;
        }

        // Update pagination info
        if (response.metadata != null) {
          _totalPages = response.metadata!.totalHalaman;
          _totalPesanan = response.metadata!.total;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshPesanan() async {
    await _loadPesanan();
  }

  void _onSearchChanged() {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == _searchQuery) return;
      setState(() {
        _searchQuery = _searchController.text;
      });
      _loadPesanan();
    });
  }

  void _onStatusChanged(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    _loadPesanan();
  }

  void _navigateToDetail(String idPesanan) {
    Navigator.pushNamed(
      context,
      '/percetakan/pesanan/detail',
      arguments: idPesanan,
    ).then((result) {
      // Refresh saat kembali dari detail jika ada perubahan
      if (result == true) {
        _refreshPesanan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Daftar Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatusFilter(),
          _buildResultInfo(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget()
                    : _pesanan.isEmpty
                        ? _buildEmptyWidget()
                        : _buildPesananList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _onSearchChanged(),
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan nomor pesanan atau nama...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _loadPesanan();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusChip('Semua', null),
            const SizedBox(width: 8),
            _buildStatusChip('Tertunda', 'tertunda'),
            const SizedBox(width: 8),
            _buildStatusChip('Diterima', 'diterima'),
            const SizedBox(width: 8),
            _buildStatusChip('Produksi', 'dalam_produksi'),
            const SizedBox(width: 8),
            _buildStatusChip('QC', 'kontrol_kualitas'),
            const SizedBox(width: 8),
            _buildStatusChip('Siap', 'siap'),
            const SizedBox(width: 8),
            _buildStatusChip('Dikirim', 'dikirim'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onStatusChanged(status),
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryGreen : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildResultInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Menampilkan ${_pesanan.length} dari $_totalPesanan pesanan',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          if (_totalPages > 1)
            Text(
              'Halaman $_currentPage dari $_totalPages',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPesananList() {
    return RefreshIndicator(
      onRefresh: _refreshPesanan,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pesanan.length + (_currentPage < _totalPages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _pesanan.length) {
            // Load more button
            return _buildLoadMoreButton();
          }
          return _buildPesananCard(_pesanan[index]);
        },
      ),
    );
  }

  Widget _buildPesananCard(PesananCetak pesanan) {
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

    final statusColor = colorMap[warnaStatus[pesanan.status]] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _navigateToDetail(pesanan.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan nomor pesanan dan status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pesanan.nomorPesanan,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          PercetakanService.formatTanggal(pesanan.tanggalPesan),
                          style: TextStyle(
                            fontSize: 12,
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
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      labelStatus[pesanan.status] ?? pesanan.status,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Info naskah
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: pesanan.naskah?.urlSampul != null
                          ? DecorationImage(
                              image: NetworkImage(pesanan.naskah!.urlSampul!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: pesanan.naskah?.urlSampul == null
                        ? Icon(Icons.book, color: Colors.grey[400], size: 32)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pesanan.naskah?.judul ?? 'Tanpa Judul',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pemesan: ${pesanan.pemesan?.profilPengguna?.namaLengkap ?? pesanan.pemesan?.email ?? "Unknown"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Detail pesanan
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            Icons.print,
                            '${pesanan.jumlah} copy',
                          ),
                        ),
                        Expanded(
                          child: _buildInfoRow(
                            Icons.description_outlined,
                            pesanan.formatKertas,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            Icons.layers_outlined,
                            pesanan.jenisKertas,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoRow(
                            Icons.book_outlined,
                            pesanan.jenisCover,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Footer dengan harga dan estimasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    PercetakanService.formatHarga(pesanan.hargaTotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  if (pesanan.estimasiSelesai != null)
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Target: ${PercetakanService.formatTanggal(pesanan.estimasiSelesai!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: () => _loadPesanan(loadMore: true),
                icon: const Icon(Icons.expand_more),
                label: const Text('Muat Lebih Banyak'),
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
            'Tidak ada pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedStatus != null || _searchQuery.isNotEmpty
                ? 'Coba ubah filter atau kata kunci pencarian'
                : 'Belum ada pesanan yang masuk',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
              onPressed: _loadPesanan,
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status Pesanan:'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('Semua', null),
                _buildFilterChip('Tertunda', 'tertunda'),
                _buildFilterChip('Diterima', 'diterima'),
                _buildFilterChip('Produksi', 'dalam_produksi'),
                _buildFilterChip('QC', 'kontrol_kualitas'),
                _buildFilterChip('Siap', 'siap'),
                _buildFilterChip('Dikirim', 'dikirim'),
                _buildFilterChip('Terkirim', 'terkirim'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        _onStatusChanged(status);
        Navigator.pop(context);
      },
    );
  }
}
