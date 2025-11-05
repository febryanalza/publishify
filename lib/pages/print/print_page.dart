import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/print_item.dart';
import 'package:publishify/widgets/print_card.dart';

class PrintPage extends StatefulWidget {
  const PrintPage({super.key});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  List<PrintItem> _allItems = [];
  List<PrintItem> _filteredItems = [];
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'Semua',
    'Selesai Cetak',
    'Dalam Proses',
    'Menunggu Konfirmasi',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading from cache/API
    await Future.delayed(const Duration(seconds: 1));

    // Load dummy data
    _allItems = PrintItem.getDummyData();
    _filteredItems = _allItems;

    setState(() {
      _isLoading = false;
    });
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        // Filter by status
        final matchesFilter = _selectedFilter == 'Semua' || 
                             item.status == _selectedFilter;
        
        // Filter by search query
        final matchesSearch = _searchQuery.isEmpty ||
                             item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             item.author.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  void _handleSearch(String query) {
    _searchQuery = query;
    _filterItems();
  }

  void _handleFilterChange(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _filterItems();
  }

  void _handleDownload(PrintItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mengunduh: ${item.title}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // TODO: Implement download functionality
  }

  void _handleShare(PrintItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membagikan: ${item.title}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // TODO: Implement share functionality
  }

  void _handleItemTap(PrintItem item) {
    showDialog(
      context: context,
      builder: (context) => _PrintDetailDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Riwayat Cetak',
          style: AppTheme.headingSmall.copyWith(
            color: AppTheme.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryGreen),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Filter Chips
          _buildFilterChips(),
          
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
                : _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : _buildItemsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: TextField(
        onChanged: _handleSearch,
        decoration: InputDecoration(
          hintText: 'Cari judul atau penulis...',
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.greyText,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.greyText,
          ),
          filled: true,
          fillColor: AppTheme.backgroundWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.map((filter) {
            final isSelected = filter == _selectedFilter;
            final count = filter == 'Semua'
                ? _allItems.length
                : _allItems.where((item) => item.status == filter).length;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('$filter ($count)'),
                selected: isSelected,
                onSelected: (_) => _handleFilterChange(filter),
                backgroundColor: AppTheme.backgroundWhite,
                selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                labelStyle: AppTheme.bodySmall.copyWith(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.greyText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.greyLight,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PrintCard(
            item: item,
            onTap: () => _handleItemTap(item),
            onDownload: () => _handleDownload(item),
            onShare: () => _handleShare(item),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.print_disabled,
            size: 80,
            color: AppTheme.greyText,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada riwayat cetak',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.greyText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat cetak Anda akan muncul di sini',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyText,
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Dialog Widget (Reusable)
class _PrintDetailDialog extends StatelessWidget {
  final PrintItem item;

  const _PrintDetailDialog({required this.item});

  Color _getStatusColor() {
    switch (item.status) {
      case 'Selesai Cetak':
        return AppTheme.googleGreen;
      case 'Dalam Proses':
        return AppTheme.googleYellow;
      case 'Menunggu Konfirmasi':
        return AppTheme.googleBlue;
      default:
        return AppTheme.greyText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detail Cetak',
                    style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Book Cover
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 180,
                      color: AppTheme.greyBackground,
                      child: Icon(
                        Icons.book,
                        size: 60,
                        color: AppTheme.greyText,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Title
            Center(
              child: Text(
                item.title,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Author
            Center(
              child: Text(
                'oleh ${item.author}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyText,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status,
                  style: AppTheme.bodyMedium.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Details
            _DetailRow(
              icon: Icons.description_outlined,
              label: 'Halaman',
              value: '${item.pageCount ?? '-'} halaman',
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.category_outlined,
              label: 'Genre',
              value: item.genre ?? '-',
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.business_outlined,
              label: 'Penerbit',
              value: item.publisher ?? '-',
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.access_time,
              label: 'Terakhir diupdate',
              value: item.getFormattedDate(),
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement share
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement download
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Unduh'),
                    style: AppTheme.primaryButtonStyle,
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

// Detail Row Widget (Reusable)
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.greyText,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
