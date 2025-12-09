import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/services/editor/notifikasi_service.dart';

/// Halaman Notifikasi Editor - Terintegrasi dengan Backend
class EditorNotificationsPage extends StatefulWidget {
  const EditorNotificationsPage({super.key});

  @override
  State<EditorNotificationsPage> createState() => _EditorNotificationsPageState();
}

class _EditorNotificationsPageState extends State<EditorNotificationsPage> {
  List<Notifikasi> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;
  
  // Filter states
  bool? _filterDibaca;
  String? _filterTipe;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _notifications.clear();
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await EditorNotifikasiService.ambilNotifikasi(
        halaman: _currentPage,
        limit: _limit,
        dibaca: _filterDibaca,
        tipe: _filterTipe,
      );

      if (response.sukses && response.data != null) {
        setState(() {
          if (refresh) {
            _notifications = response.data!;
          } else {
            _notifications.addAll(response.data!);
          }
          _hasMore = response.metadata != null && 
                     _currentPage < response.metadata!.totalHalaman;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.pesan ?? 'Gagal memuat notifikasi';
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

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    
    setState(() {
      _currentPage++;
    });
    
    await _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await EditorNotifikasiService.tandaiSemuaDibaca();
      
      if (response.sukses) {
        // Refresh notifikasi
        await _loadNotifications(refresh: true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan ?? 'Semua notifikasi telah ditandai sebagai dibaca'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan ?? 'Gagal menandai notifikasi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      final response = await EditorNotifikasiService.hapusNotifikasi(id);
      
      if (response.sukses) {
        setState(() {
          _notifications.removeWhere((n) => n.id == id);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan ?? 'Notifikasi berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.pesan ?? 'Gagal menghapus notifikasi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: _markAllAsRead,
            tooltip: 'Tandai semua telah dibaca',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
            tooltip: 'Filter notifikasi',
          ),
        ],
      ),
      body: _isLoading && _notifications.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            )
          : _errorMessage != null && _notifications.isEmpty
              ? _buildErrorState()
              : _buildNotificationsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Gagal memuat notifikasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadNotifications(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada notifikasi',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi baru akan muncul di sini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final unreadNotifications = _notifications.where((n) => !n.dibaca).toList();
    final readNotifications = _notifications.where((n) => n.dibaca).toList();

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(refresh: true),
      color: AppTheme.primaryGreen,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoading &&
              _hasMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMore();
          }
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (unreadNotifications.isNotEmpty) ...[
              _buildSectionHeader('Belum Dibaca', unreadNotifications.length),
              ...unreadNotifications.map((notification) => 
                _buildNotificationCard(notification)),
              const SizedBox(height: 16),
            ],
            if (readNotifications.isNotEmpty) ...[
              _buildSectionHeader('Sudah Dibaca', readNotifications.length),
              ...readNotifications.map((notification) => 
                _buildNotificationCard(notification)),
            ],
            if (_isLoading && _notifications.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                ),
              ),
            if (!_hasMore && _notifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Semua notifikasi telah ditampilkan',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Notifikasi notification) {
    final isUnread = !notification.dibaca;
    final tipeColor = _getTipeColor(notification.tipe);
    final tipeIcon = _getTipeIcon(notification.tipe);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Notifikasi'),
            content: const Text('Apakah Anda yakin ingin menghapus notifikasi ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isUnread ? Colors.blue.withValues(alpha: 0.02) : Colors.white,
          border: isUnread ? Border.all(color: Colors.blue.withValues(alpha: 0.1)) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tipeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              tipeIcon,
              color: tipeColor,
              size: 24,
            ),
          ),
          title: Text(
            notification.judul,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.pesan,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _formatTime(notification.dibuatPada),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tipeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTipeLabel(notification.tipe),
                      style: TextStyle(
                        color: tipeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: isUnread
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () => _onNotificationTap(notification),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  Color _getTipeColor(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'sukses':
        return Colors.green;
      case 'peringatan':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
      default:
        return AppTheme.primaryGreen;
    }
  }

  IconData _getTipeIcon(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'sukses':
        return Icons.check_circle;
      case 'peringatan':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
      default:
        return Icons.info;
    }
  }

  String _getTipeLabel(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'sukses':
        return 'Sukses';
      case 'peringatan':
        return 'Peringatan';
      case 'error':
        return 'Error';
      case 'info':
      default:
        return 'Info';
    }
  }

  Future<void> _onNotificationTap(Notifikasi notification) async {
    // Tandai sebagai sudah dibaca jika belum
    if (!notification.dibaca) {
      final response = await EditorNotifikasiService.tandaiDibaca(notification.id);
      if (response.sukses) {
        setState(() {
          notification = Notifikasi(
            id: notification.id,
            idPengguna: notification.idPengguna,
            judul: notification.judul,
            pesan: notification.pesan,
            tipe: notification.tipe,
            url: notification.url,
            dibaca: true,
            dibuatPada: notification.dibuatPada,
            diperbaruiPada: DateTime.now(),
          );
          // Update in list
          final index = _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = notification;
          }
        });
      }
    }

    // Navigate berdasarkan URL jika ada
    if (notification.url != null && notification.url!.isNotEmpty) {
      // TODO: Implement navigation based on URL
      // For now, just show a dialog with the URL
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(notification.judul),
            content: Text(notification.pesan),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildRadioIndicator(bool isSelected) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.greyMedium,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen,
                ),
              ),
            )
          : null,
    );
  }

  void _showFilterDialog() {
    bool? tempDibaca = _filterDibaca;
    String? tempTipe = _filterTipe;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Notifikasi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: _buildRadioIndicator(tempDibaca == null),
                  title: const Text('Semua'),
                  onTap: () {
                    setDialogState(() {
                      tempDibaca = null;
                    });
                  },
                  selected: tempDibaca == null,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                ListTile(
                  leading: _buildRadioIndicator(tempDibaca == false),
                  title: const Text('Belum Dibaca'),
                  onTap: () {
                    setDialogState(() {
                      tempDibaca = false;
                    });
                  },
                  selected: tempDibaca == false,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                ListTile(
                  leading: _buildRadioIndicator(tempDibaca == true),
                  title: const Text('Sudah Dibaca'),
                  onTap: () {
                    setDialogState(() {
                      tempDibaca = true;
                    });
                  },
                  selected: tempDibaca == true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tipe',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: _buildRadioIndicator(tempTipe == null),
                  title: const Text('Semua Tipe'),
                  onTap: () {
                    setDialogState(() {
                      tempTipe = null;
                    });
                  },
                  selected: tempTipe == null,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                ..._buildTipeFilters(tempTipe, setDialogState, (value) {
                  tempTipe = value;
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterDibaca = tempDibaca;
                  _filterTipe = tempTipe;
                });
                Navigator.pop(context);
                _loadNotifications(refresh: true);
              },
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTipeFilters(
    String? selectedTipe,
    StateSetter setDialogState,
    Function(String?) onChanged,
  ) {
    final tipes = ['info', 'sukses', 'peringatan', 'error'];
    return tipes.map((tipe) {
      return ListTile(
        leading: _buildRadioIndicator(selectedTipe == tipe),
        title: Text(_getTipeLabel(tipe)),
        onTap: () {
          setDialogState(() {
            onChanged(tipe);
          });
        },
        selected: selectedTipe == tipe,
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    }).toList();
  }
}
