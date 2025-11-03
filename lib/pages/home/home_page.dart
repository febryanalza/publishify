import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/utils/dummy_data.dart';
import 'package:publishify/models/book.dart';
import 'package:publishify/widgets/navigation/bottom_nav_bar.dart';
import 'package:publishify/widgets/cards/status_card.dart';
import 'package:publishify/widgets/cards/action_button.dart';
import 'package:publishify/widgets/cards/book_card.dart';

class HomePage extends StatefulWidget {
  final String? userName;

  const HomePage({
    super.key,
    this.userName,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Book> _books;
  late Map<String, int> _statusCount;

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Load data from DummyData class - mudah diganti nanti
    _books = DummyData.getBooks();
    _statusCount = DummyData.getStatusCount();
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return; // Jika sudah di halaman yang sama, tidak perlu navigate
    
    setState(() {
      _currentIndex = index;
    });
    
    // Navigate to different pages based on index using pushReplacementNamed
    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        // Navigate to Statistics
        Navigator.pushReplacementNamed(context, '/statistics');
        break;
      case 2:
        // Navigate to Notifications
        Navigator.pushReplacementNamed(context, '/notifications');
        break;
      case 3:
        // Navigate to Profile
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation/Header
            _buildHeader(),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    _buildSearchBar(),
                    
                    const SizedBox(height: 24),
                    
                    // Status Summary
                    _buildStatusSummary(),
                    
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    _buildActionButtons(),
                    
                    const SizedBox(height: 24),
                    
                    // Books List
                    _buildBooksList(),
                    
                    const SizedBox(height: 80), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi ${widget.userName ?? "Salsabila"}',
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Apa yang mau kamu tulis hari ini?',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.greyDisabled, width: 1),
              ),
              child: Row(
                children: [
                  Text(
                    'Search',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.greyMedium,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.search,
                    color: AppTheme.greyMedium,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.greyDisabled, width: 1),
            ),
            child: const Icon(
              Icons.tune,
              color: AppTheme.primaryDark,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kamu telah menulis',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusCard(
                title: 'Draft',
                count: _statusCount['draft'] ?? 0,
                onTap: () => _filterByStatus('draft'),
              ),
              const SizedBox(width: 12),
              StatusCard(
                title: 'Revisi',
                count: _statusCount['revisi'] ?? 0,
                onTap: () => _filterByStatus('revisi'),
              ),
              const SizedBox(width: 12),
              StatusCard(
                title: 'Cetak',
                count: _statusCount['cetak'] ?? 0,
                onTap: () => _filterByStatus('cetak'),
              ),
              const SizedBox(width: 12),
              StatusCard(
                title: 'Publish',
                count: _statusCount['publish'] ?? 0,
                onTap: () => _filterByStatus('publish'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ActionButton(
            icon: Icons.note_add,
            label: '',
            onTap: () => _handleAction('new_document'),
          ),
          ActionButton(
            icon: Icons.edit_note,
            label: '',
            onTap: () => _handleAction('revisi'),
            hasNotification: true,
          ),
          ActionButton(
            icon: Icons.print,
            label: '',
            onTap: () => _handleAction('print'),
          ),
          ActionButton(
            icon: Icons.list,
            label: '',
            onTap: () => _handleAction('list'),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buku Saya',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _books.length,
            itemBuilder: (context, index) {
              return BookCard(
                book: _books[index],
                onTap: () => _openBook(_books[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  void _filterByStatus(String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter by: $status'),
        duration: const Duration(seconds: 1),
      ),
    );
    // TODO: Implement filter logic
  }

  void _handleAction(String action) {
    if (action == 'new_document') {
      // Navigate to upload book page
      Navigator.pushNamed(context, '/upload-book');
    } else if (action == 'revisi') {
      // Navigate to revision page
      Navigator.pushNamed(context, '/revisi');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Action: $action'),
          duration: const Duration(seconds: 1),
        ),
      );
      // TODO: Implement other actions
    }
  }

  void _openBook(Book book) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open: ${book.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
    // TODO: Navigate to book detail page
  }
}
