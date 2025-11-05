import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/book.dart';
import 'package:publishify/widgets/cards/status_card.dart';
import 'package:publishify/widgets/cards/action_button.dart';
import 'package:publishify/widgets/cards/book_card.dart';
import 'package:publishify/services/naskah_service.dart';
import 'package:publishify/services/auth_service.dart';

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
  late List<Book> _books;
  late Map<String, int> _statusCount;
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load user name from cache
    final namaTampilan = await AuthService.getNamaTampilan();
    if (namaTampilan != null) {
      _userName = namaTampilan;
    }

    // Load naskah from API
    await _loadNaskahFromAPI();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadNaskahFromAPI() async {
    try {
      // Get all naskah (no status filter to show all books)
      final response = await NaskahService.getNaskahSaya(
        halaman: 1,
        limit: 20,
      );

      if (response.sukses && response.data != null && response.data!.isNotEmpty) {
        // Convert NaskahData to Book model
        _books = response.data!.map((naskah) {
          // Get author name from penulis data
          String authorName = _userName.isNotEmpty ? _userName : 'Anda';
          if (naskah.penulis?.profilPenulis?.namaPena != null) {
            authorName = naskah.penulis!.profilPenulis!.namaPena;
          } else if (naskah.penulis?.profilPengguna?.namaTampilan != null) {
            authorName = naskah.penulis!.profilPengguna!.namaTampilan;
          }

          return Book(
            id: naskah.id,
            title: naskah.judul,
            author: authorName,
            imageUrl: naskah.urlSampul,
            status: naskah.status,
            lastModified: DateTime.tryParse(naskah.dibuatPada),
            pageCount: naskah.jumlahHalaman > 0 
                ? naskah.jumlahHalaman 
                : (naskah.jumlahKata / 250).round(),
            description: naskah.sinopsis,
          );
        }).toList();

        // Get status count
        _statusCount = await NaskahService.getStatusCount();
      } else {
        // No data, show empty message instead of dummy
        _books = [];
        _statusCount = {
          'draft': 0,
          'review': 0,
          'revision': 0,
          'published': 0,
        };
      }
    } catch (e) {
      // Error, show empty
      _books = [];
      _statusCount = {
        'draft': 0,
        'review': 0,
        'revision': 0,
        'published': 0,
      };
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryGreen,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
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
                    'Hi ${_userName.isNotEmpty ? _userName : (widget.userName ?? "Penulis")}',
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
            badgeIcon: Icons.store,
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
        _books.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: AppTheme.greyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada naskah',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mulai menulis naskah pertamamu dengan\nmenekan tombol tambah naskah',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.greyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
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
    } else if (action == 'print') {
      // Navigate to pilih percetakan page
      Navigator.pushNamed(context, '/pilih-percetakan');
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
