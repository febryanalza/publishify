import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/utils/dummy_data.dart';
import 'package:publishify/models/notification_model.dart';
import 'package:publishify/widgets/navigation/bottom_nav_bar.dart';
import 'package:publishify/widgets/cards/notification_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _currentIndex = 2; // Notifications tab
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load data from DummyData - mudah diganti nanti
    _notifications = DummyData.getNotifications();
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return; // Jika sudah di halaman yang sama, tidak perlu navigate
    
    setState(() {
      _currentIndex = index;
    });
    
    // Navigate to different pages based on index using pushReplacementNamed
    switch (index) {
      case 0:
        // Navigate to Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Navigate to Statistics
        Navigator.pushReplacementNamed(context, '/statistics');
        break;
      case 2:
        // Already on Notifications
        break;
      case 3:
        // Navigate to Profile
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  void _markAsRead(NotificationModel notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });
  }

  void _deleteNotification(NotificationModel notification) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifikasi dihapus'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _loadData(); // Reload to restore
            });
          },
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai sudah dibaca'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua notifikasi dihapus'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation/Header
            _buildHeader(unreadCount),
            
            // Main Content
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Notifications List
                          ..._notifications.map((notification) {
                            return NotificationCard(
                              notification: notification,
                              onTap: () {
                                if (!notification.isRead) {
                                  _markAsRead(notification);
                                }
                                // TODO: Open notification detail
                              },
                              onDelete: () => _deleteNotification(notification),
                            );
                          }),
                          
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

  Widget _buildHeader(int unreadCount) {
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
            children: [
              Text(
                'Notifikasi',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              
              // Action buttons
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppTheme.white,
                ),
                onSelected: (value) {
                  if (value == 'mark_all') {
                    _markAllAsRead();
                  } else if (value == 'clear_all') {
                    _clearAll();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, size: 20),
                        SizedBox(width: 8),
                        Text('Tandai Semua Sudah Dibaca'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, size: 20),
                        SizedBox(width: 8),
                        Text('Hapus Semua'),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: AppTheme.greyMedium.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.greyMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi baru akan muncul di sini',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
