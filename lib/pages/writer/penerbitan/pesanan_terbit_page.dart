import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/pesanan_terbit_models.dart';
import 'package:publishify/services/writer/pesanan_terbit_service.dart';
import 'package:publishify/pages/writer/penerbitan/detail_pesanan_terbit_page.dart';
import 'package:publishify/pages/writer/penerbitan/buat_pesanan_terbit_page.dart';

/// Halaman daftar pesanan terbit milik penulis
class PesananTerbitPage extends StatefulWidget {
  const PesananTerbitPage({super.key});

  @override
  State<PesananTerbitPage> createState() => _PesananTerbitPageState();
}

class _PesananTerbitPageState extends State<PesananTerbitPage> {
  List<PesananTerbitSummary> _pesananList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedStatus;
  String? _selectedStatusPembayaran;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await PesananTerbitService.getPesananTerbitSaya(
        status: _selectedStatus,
        statusPembayaran: _selectedStatusPembayaran,
        halaman: _currentPage,
        limit: _limit,
      );

      if (response.sukses) {
        setState(() {
          _pesananList = response.data;
          _totalPages = response.metadata?.totalHalaman ?? 1;
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
        title: const Text('Pesanan Penerbitan'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_selectedStatus != null || _selectedStatusPembayaran != null)
            _buildActiveFilters(),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGreen,
                      ),
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorView()
                    : _pesananList.isEmpty
                        ? _buildEmptyView()
                        : RefreshIndicator(
                            onRefresh: () => _loadData(refresh: true),
                            color: AppTheme.primaryGreen,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _pesananList.length,
                              itemBuilder: (context, index) {
                                return _buildPesananCard(_pesananList[index]);
                              },
                            ),
                          ),
          ),

          // Pagination
          if (!_isLoading && _pesananList.isNotEmpty) _buildPagination(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToBuatPesanan,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: AppTheme.white),
        label: const Text(
          'Buat Pesanan',
          style: TextStyle(color: AppTheme.white),
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (_selectedStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(getLabelStatusPenerbitan(
                    statusPenerbitanFromString(_selectedStatus))),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _selectedStatus = null;
                  });
                  _loadData(refresh: true);
                },
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                labelStyle: const TextStyle(color: AppTheme.primaryGreen),
              ),
            ),
          if (_selectedStatusPembayaran != null)
            Chip(
              label: Text(getLabelStatusPembayaran(
                  statusPembayaranFromString(_selectedStatusPembayaran))),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedStatusPembayaran = null;
                });
                _loadData(refresh: true);
              },
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              labelStyle: const TextStyle(color: Colors.orange),
            ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedStatusPembayaran = null;
              });
              _loadData(refresh: true);
            },
            child: const Text('Reset'),
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
              onPressed: () => _loadData(refresh: true),
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
              Icons.menu_book_outlined,
              size: 80,
              color: AppTheme.greyMedium.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan penerbitan',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai terbitkan naskah Anda dengan\nmembuat pesanan penerbitan baru',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToBuatPesanan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add, color: AppTheme.white),
              label: const Text(
                'Buat Pesanan Pertama',
                style: TextStyle(color: AppTheme.white),
              ),
            ),
          ],
        ),
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
              // Header dengan nomor pesanan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    pesanan.nomorPesanan,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  _buildStatusChip(pesanan.statusEnum),
                ],
              ),
              const SizedBox(height: 12),

              // Info naskah
              if (pesanan.naskah != null)
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppTheme.greyLight,
                        borderRadius: BorderRadius.circular(6),
                        image: pesanan.naskah!.urlSampul != null
                            ? DecorationImage(
                                image: NetworkImage(pesanan.naskah!.urlSampul!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: pesanan.naskah!.urlSampul == null
                          ? const Icon(Icons.book, color: AppTheme.greyMedium)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pesanan.naskah!.judul,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
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
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Footer dengan info tambahan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah: ${pesanan.jumlahBuku} buku',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyMedium,
                        ),
                      ),
                      Text(
                        _formatTanggal(pesanan.tanggalPesan),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.greyMedium,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatRupiah(pesanan.totalHarga),
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      _buildStatusPembayaranChip(pesanan.statusPembayaranEnum),
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

    return Text(
      getLabelStatusPembayaran(status),
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPagination() {
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
          ),
          Text(
            'Halaman $_currentPage dari $_totalPages',
            style: AppTheme.bodyMedium,
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
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
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
          _loadData(refresh: true);
        },
      ),
    );
  }

  void _navigateToBuatPesanan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BuatPesananTerbitPage(),
      ),
    ).then((value) {
      if (value == true) {
        _loadData(refresh: true);
      }
    });
  }

  void _navigateToDetail(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPesananTerbitPage(pesananId: id),
      ),
    ).then((value) {
      if (value == true) {
        _loadData(refresh: true);
      }
    });
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
  final String? selectedStatus;
  final String? selectedStatusPembayaran;
  final Function(String?, String?) onApply;

  const _FilterBottomSheet({
    this.selectedStatus,
    this.selectedStatusPembayaran,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? _status;
  String? _statusPembayaran;

  final List<StatusPenerbitan> _statusOptions = StatusPenerbitan.values;
  final List<StatusPembayaranTerbit> _statusPembayaranOptions =
      StatusPembayaranTerbit.values;

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _statusPembayaran = widget.selectedStatusPembayaran;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Pesanan',
                  style: AppTheme.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status filter
            Text(
              'Status Penerbitan',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusOptions.map((status) {
                final isSelected =
                    _status == statusPenerbitanToString(status);
                return FilterChip(
                  label: Text(getLabelStatusPenerbitan(status)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _status =
                          selected ? statusPenerbitanToString(status) : null;
                    });
                  },
                  selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.primaryGreen,
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Status pembayaran filter
            Text(
              'Status Pembayaran',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusPembayaranOptions.map((status) {
                final isSelected =
                    _statusPembayaran == statusPembayaranFromEnum(status);
                return FilterChip(
                  label: Text(getLabelStatusPembayaran(status)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _statusPembayaran =
                          selected ? statusPembayaranFromEnum(status) : null;
                    });
                  },
                  selectedColor: Colors.orange.withValues(alpha: 0.2),
                  checkmarkColor: Colors.orange,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _status = null;
                        _statusPembayaran = null;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_status, _statusPembayaran);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                    child: const Text(
                      'Terapkan',
                      style: TextStyle(color: AppTheme.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
