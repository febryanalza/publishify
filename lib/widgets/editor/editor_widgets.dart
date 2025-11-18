import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/editor/editor_models.dart';

/// Widget untuk menampilkan kartu review assignment
class ReviewAssignmentCard extends StatelessWidget {
  final ReviewAssignment review;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final String? actionLabel;
  final IconData? actionIcon;

  const ReviewAssignmentCard({
    super.key,
    required this.review,
    this.onTap,
    this.onActionTap,
    this.actionLabel,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(review.status);
    final priorityColor = _getPriorityColor(review.prioritas);
    final isDeadlineNear = _isDeadlineNear(review.batasWaktu);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isDeadlineNear
                  ? Border.all(color: AppTheme.errorRed, width: 1)
                  : Border.all(color: AppTheme.greyDisabled),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row dengan judul dan prioritas
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.judulNaskah,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        review.prioritasLabel,
                        style: AppTheme.bodySmall.copyWith(
                          color: priorityColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Info penulis
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppTheme.greyMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.penulis,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.greyMedium,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Tags jika ada
                if (review.tags != null && review.tags!.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: review.tags!.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryGreen,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                
                if (review.tags != null && review.tags!.isNotEmpty)
                  const SizedBox(height: 12),
                
                // Bottom row dengan status dan deadline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        review.statusLabel,
                        style: AppTheme.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          isDeadlineNear ? Icons.warning : Icons.schedule,
                          size: 14,
                          color: isDeadlineNear 
                              ? AppTheme.errorRed 
                              : AppTheme.greyMedium,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDeadline(review.batasWaktu),
                          style: AppTheme.bodySmall.copyWith(
                            color: isDeadlineNear
                                ? AppTheme.errorRed
                                : AppTheme.greyMedium,
                            fontWeight: isDeadlineNear 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Action button jika ada
                if (onActionTap != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onActionTap,
                        icon: Icon(
                          actionIcon ?? Icons.play_arrow,
                          size: 16,
                        ),
                        label: Text(
                          actionLabel ?? 'Mulai Review',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ditugaskan':
        return Colors.blue;
      case 'sedang_review':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return AppTheme.greyMedium;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
      case 5:
        return AppTheme.greyMedium;
      default:
        return AppTheme.greyMedium;
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    
    if (difference < 0) {
      return 'Terlambat';
    } else if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Besok';
    } else {
      return '$difference hari lagi';
    }
  }

  bool _isDeadlineNear(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference <= 1;
  }
}

/// Widget untuk menampilkan statistik editor dalam bentuk card
class EditorStatsCard extends StatelessWidget {
  final String title;
  final int value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const EditorStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.greyLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                Text(
                  value.toString(),
                  style: AppTheme.headingMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan progress bar dengan informasi
class EditorProgressCard extends StatelessWidget {
  final String title;
  final int current;
  final int target;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const EditorProgressCard({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  double get progress {
    if (target == 0) return 0.0;
    return (current / target).clamp(0.0, 1.0);
  }

  double get percentage {
    return (progress * 100);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.greyLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$current/$target',
                  style: AppTheme.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyMedium,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.greyDisabled,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 100 ? Colors.green : color,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}% selesai',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                  ),
                ),
                if (percentage >= 100)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Target tercapai',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}