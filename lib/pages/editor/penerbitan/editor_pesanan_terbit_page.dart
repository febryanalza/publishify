import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/pesanan_terbit_models.dart';
import 'package:publishify/services/writer/pesanan_terbit_service.dart';
import 'editor_detail_pesanan_terbit_page.dart';

/// Halaman untuk Editor melihat semua pesanan penerbitan
class EditorPesananTerbitPage extends StatefulWidget {
  const EditorPesananTerbitPage({super.key});

  @override
  State<EditorPesananTerbitPage> createState() =>
      _EditorPesananTerbitPageState();
}

class _EditorPesananTerbitPageState extends State<EditorPesananTerbitPage> {
  List<PesananTerbitSummary> _daftarPesanan = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 10;

  // Filters
  StatusPenerbitan? _selectedStatus;
  StatusPembayaranTerbit? _selectedStatusPembayaran;
  String? _searchQuery;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await PesananTerbitService.getAllPesananTerbit(
        halaman: _currentPage,
        limit: _limit,
        status: _selectedStatus?.toApiString(),
        statusPembayaran: _selectedStatusPembayaran?.toApiString(),
      );

      if (response.sukses) {
        setState(() {
          _daftarPesanan = response.data;
          if (response.metadata != null) {
            _totalPages = response.metadata!.totalHalaman;
          }
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
        title: const Text('Kelola Pesanan Terbit'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Filter chips
          if (_selectedStatus != null || _selectedStatusPembayaran != null)
            _buildActiveFilters(),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorView()
                    : _daftarPesanan.isEmpty
                        ? _buildEmptyView()
                        : _buildListView(),
          ),

          // Pagination
          if (!_isLoading && _daftarPesanan.isNotEmpty) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari nomor pesanan atau judul naskah...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.greyMedium),
          suffixIcon: _searchQuery != null && _searchQuery!.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = null;
                    });
                    _loadData(resetPage: true);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.greyLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.greyLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryGreen),
          ),
          filled: true,
          fillColor: AppTheme.white,
        ),
        onSubmitted: (value) {
          setState(() {
            _searchQuery = value.isEmpty ? null : value;
          });
          _loadData(resetPage: true);
        },
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedStatus != null)
            Chip(
              label: Text(getLabelStatusPenerbitan(_selectedStatus!)),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedStatus = null;
                });
                _loadData(resetPage: true);
              },
              backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
            ),
          if (_selectedStatusPembayaran != null)
            Chip(
              label: Text(getLabelStatusPembayaran(_selectedStatusPembayaran!)),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedStatusPembayaran = null;
                });
                _loadData(resetPage: true);
              },
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
            ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedStatusPembayaran = null;
              });
              _loadData(resetPage: true);
            },
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
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

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.greyMedium.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan penerbitan',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: () => _loadData(),
      color: AppTheme.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _daftarPesanan.length,
        itemBuilder: (context, index) {
          final pesanan = _daftarPesanan[index];
          return _buildPesananCard(pesanan);
        },
      ),
    );
  }

  Widget _buildPesananCard(PesananTerbitSummary pesanan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(pesanan.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nomor pesanan & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pesanan.nomorPesanan,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (pesanan.penulis != null)
                          Text(
                            pesanan.penulis!.namaLengkap,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.greyMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildStatusChip(pesanan.statusEnum),
                ],
              ),
              const Divider(height: 24),

              // Naskah Info
              if (pesanan.naskah != null)
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.greyLight,
                        borderRadius: BorderRadius.circular(4),
                        image: pesanan.naskah!.urlSampul != null
                            ? DecorationImage(
                                image:
                                    NetworkImage(pesanan.naskah!.urlSampul!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: pesanan.naskah!.urlSampul == null
                          ? const Icon(Icons.book,
                              color: AppTheme.greyMedium, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pesanan.naskah!.judul,
                            style: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (pesanan.paket != null)
                            Text(
                              'Paket: ${pesanan.paket!.nama}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.greyMedium,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // Bottom Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTanggal(pesanan.tanggalPesan),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.greyMedium,
                    ),
                  ),
                  Row(
                    children: [
                      _buildStatusPembayaranChip(pesanan.statusPembayaranEnum),
                      const SizedBox(width: 8),
                      Text(
                        _formatRupiah(pesanan.totalHarga),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        getLabelStatusPenerbitan(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusPembayaranChip(StatusPembayaranTerbit status) {
    Color color;
    IconData icon;
    switch (status) {
      case StatusPembayaranTerbit.belumBayar:
        color = Colors.red;
        icon = Icons.payment;
        break;
      case StatusPembayaranTerbit.menungguKonfirmasi:
        color = Colors.orange;
        icon = Icons.hourglass_bottom;
        break;
      case StatusPembayaranTerbit.lunas:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case StatusPembayaranTerbit.dibatalkan:
        color = Colors.grey;
        icon = Icons.cancel;
        break;
    }

    return Icon(icon, size: 18, color: color);
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _loadData();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
            color: AppTheme.primaryGreen,
            disabledColor: AppTheme.greyMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Halaman $_currentPage dari $_totalPages',
              style: AppTheme.bodySmall,
            ),
          ),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _loadData();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
            color: AppTheme.primaryGreen,
            disabledColor: AppTheme.greyMedium,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        selectedStatus: _selectedStatus,
        selectedStatusPembayaran: _selectedStatusPembayaran,
        onApply: (status, statusPembayaran) {
          setState(() {
            _selectedStatus = status;
            _selectedStatusPembayaran = statusPembayaran;
          });
          _loadData(resetPage: true);
        },
      ),
    );
  }

  void _navigateToDetail(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorDetailPesananTerbitPage(pesananId: id),
      ),
    ).then((_) => _loadData());
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
      return '${date.day} ${bulan[date.month]} ${date.year}';
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

/// Bottom sheet untuk filter
class _FilterBottomSheet extends StatefulWidget {
  final StatusPenerbitan? selectedStatus;
  final StatusPembayaranTerbit? selectedStatusPembayaran;
  final Function(StatusPenerbitan?, StatusPembayaranTerbit?) onApply;

  const _FilterBottomSheet({
    required this.selectedStatus,
    required this.selectedStatusPembayaran,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  StatusPenerbitan? _tempStatus;
  StatusPembayaranTerbit? _tempStatusPembayaran;

  @override
  void initState() {
    super.initState();
    _tempStatus = widget.selectedStatus;
    _tempStatusPembayaran = widget.selectedStatusPembayaran;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.greyMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Pesanan',
                    style: AppTheme.headingMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tempStatus = null;
                        _tempStatusPembayaran = null;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Pesanan
              Text(
                'Status Pesanan',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: StatusPenerbitan.values.map((status) {
                  final isSelected = _tempStatus == status;
                  return FilterChip(
                    label: Text(getLabelStatusPenerbitan(status)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _tempStatus = selected ? status : null;
                      });
                    },
                    selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryGreen,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Status Pembayaran
              Text(
                'Status Pembayaran',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: StatusPembayaranTerbit.values.map((status) {
                  final isSelected = _tempStatusPembayaran == status;
                  return FilterChip(
                    label: Text(getLabelStatusPembayaran(status)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _tempStatusPembayaran = selected ? status : null;
                      });
                    },
                    selectedColor: Colors.orange.withValues(alpha: 0.2),
                    checkmarkColor: Colors.orange,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Apply Button
              ElevatedButton(
                onPressed: () {
                  widget.onApply(_tempStatus, _tempStatusPembayaran);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Terapkan Filter',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
