import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';

/// Halaman Notifikasi Editor
class EditorNotificationsPage extends StatefulWidget {
  const EditorNotificationsPage({super.key});

  @override
  State<EditorNotificationsPage> createState() => _EditorNotificationsPageState();
}

class _EditorNotificationsPageState extends State<EditorNotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    // Simulasi delay loading
    await Future.delayed(const Duration(milliseconds: 800));

    // Dummy notifications data
    setState(() {
      _notifications = [
        {
          'id': '1',
          'title': 'Review Baru Ditugaskan',
          'message': 'Anda mendapat tugas review untuk naskah "Perjalanan Sang Penulis"',
          'time': DateTime.now().subtract(const Duration(minutes: 30)),
          'isRead': false,
          'type': 'review_assignment',
          'icon': Icons.assignment,
          'color': AppTheme.primaryGreen,
        },
        {
          'id': '2',
          'title': 'Deadline Review Mendekat',
          'message': 'Review "Rahasia Teknologi Masa Depan" akan berakhir dalam 2 hari',
          'time': DateTime.now().subtract(const Duration(hours: 2)),
          'isRead': false,
          'type': 'deadline_reminder',
          'icon': Icons.schedule,
          'color': Colors.orange,
        },
        {
          'id': '3',
          'title': 'Feedback Diterima',
          'message': 'Penulis memberikan feedback untuk review Anda',
          'time': DateTime.now().subtract(const Duration(hours: 5)),
          'isRead': true,
          'type': 'feedback',
          'icon': Icons.feedback,
          'color': Colors.blue,
        },
        {
          'id': '4',
          'title': 'Naskah Baru Masuk',
          'message': '2 naskah baru perlu direview oleh tim editor',
          'time': DateTime.now().subtract(const Duration(days: 1)),
          'isRead': true,
          'type': 'new_submission',
          'icon': Icons.book,
          'color': Colors.purple,
        },
        {
          'id': '5',
          'title': 'Rating Review Anda',
          'message': 'Review Anda mendapat rating 4.8/5 dari penulis',
          'time': DateTime.now().subtract(const Duration(days: 2)),
          'isRead': true,
          'type': 'rating',
          'icon': Icons.star,
          'color': Colors.amber,
        },
      ];
      _isLoading = false;
    });
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildNotificationsList(),
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

    final unreadNotifications = _notifications.where((n) => !n['isRead']).toList();
    final readNotifications = _notifications.where((n) => n['isRead']).toList();

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (unreadNotifications.isNotEmpty) ...[
            _buildSectionHeader('Belum Dibaca', unreadNotifications.length),
            ...unreadNotifications.map((notification) => _buildNotificationCard(notification)),
            const SizedBox(height: 16),
          ],
          if (readNotifications.isNotEmpty) ...[
            _buildSectionHeader('Sudah Dibaca', readNotifications.length),
            ...readNotifications.map((notification) => _buildNotificationCard(notification)),
          ],
        ],
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
              color: AppTheme.primaryGreen.withOpacity(0.1),
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

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isUnread = !notification['isRead'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.withOpacity(0.02) : Colors.white,
        border: isUnread ? Border.all(color: Colors.blue.withOpacity(0.1)) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            color: notification['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            notification['icon'],
            color: notification['color'],
            size: 24,
          ),
        ),
        title: Text(
          notification['title'],
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
              notification['message'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(notification['time']),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
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
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    // Tandai sebagai sudah dibaca
    setState(() {
      notification['isRead'] = true;
    });

    // Navigate berdasarkan tipe notifikasi
    switch (notification['type']) {
      case 'review_assignment':
        Navigator.pushNamed(context, '/editor/review-naskah');
        break;
      case 'deadline_reminder':
        Navigator.pushNamed(context, '/editor/review-naskah');
        break;
      case 'feedback':
        Navigator.pushNamed(context, '/editor/feedback');
        break;
      case 'new_submission':
        Navigator.pushNamed(context, '/editor/review-naskah');
        break;
      default:
        break;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi telah ditandai sebagai dibaca'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Notifikasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Review Assignment'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Deadline Reminder'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Feedback'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('New Submission'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter diterapkan')),
              );
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }
}