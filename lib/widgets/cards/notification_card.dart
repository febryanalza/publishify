import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorRed,
        child: const Icon(
          Icons.delete,
          color: AppTheme.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!();
        }
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? AppTheme.white 
                : AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.greyDisabled,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon based on notification type
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIcon(),
                  color: AppTheme.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender
                    Text(
                      notification.sender,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Subject
                    Text(
                      notification.subject,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: notification.isRead 
                            ? FontWeight.normal 
                            : FontWeight.w600,
                        color: AppTheme.black,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Message Preview
                    Text(
                      notification.message,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.greyMedium,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Time
                    Text(
                      _formatDate(notification.date),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.greyMedium,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4, left: 8),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.sms:
        return Icons.sms;
      case NotificationType.email:
        return Icons.email;
      case NotificationType.system:
        return Icons.notifications;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.review:
        return Icons.star;
      case NotificationType.update:
        return Icons.update;
    }
  }

  Color _getIconBackgroundColor() {
    switch (notification.type) {
      case NotificationType.sms:
        return AppTheme.primaryGreen;
      case NotificationType.email:
        return AppTheme.googleBlue;
      case NotificationType.system:
        return AppTheme.primaryDark;
      case NotificationType.comment:
        return AppTheme.googleYellow;
      case NotificationType.review:
        return AppTheme.yellow;
      case NotificationType.update:
        return AppTheme.googleGreen;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
