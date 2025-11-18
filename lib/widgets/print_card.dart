import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/print_item.dart';
import 'package:publishify/widgets/network_image_widget.dart';

class PrintCard extends StatelessWidget {
  final PrintItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;

  const PrintCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDownload,
    this.onShare,
  });

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

  IconData _getStatusIcon() {
    switch (item.status) {
      case 'Selesai Cetak':
        return Icons.check_circle;
      case 'Dalam Proses':
        return Icons.sync;
      case 'Menunggu Konfirmasi':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 120,
                      color: AppTheme.greyBackground,
                      child: Icon(
                        Icons.book,
                        size: 40,
                        color: AppTheme.greyText,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 80,
                      height: 120,
                      color: AppTheme.greyBackground,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryGreen,
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Book Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Author
                    Text(
                      item.author,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.greyText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 14,
                            color: _getStatusColor(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.status,
                            style: AppTheme.bodySmall.copyWith(
                              color: _getStatusColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Info Row
                    Row(
                      children: [
                        if (item.pageCount != null) ...[
                          Icon(
                            Icons.description_outlined,
                            size: 14,
                            color: AppTheme.greyText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.pageCount} halaman',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.greyText,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.greyText,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.getFormattedDate(),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.greyText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Share Button
                        if (onShare != null)
                          _ActionIconButton(
                            icon: Icons.share_outlined,
                            onTap: onShare!,
                            tooltip: 'Bagikan',
                          ),
                        
                        const SizedBox(width: 8),
                        
                        // Download Button
                        if (onDownload != null)
                          _ActionIconButton(
                            icon: Icons.download_outlined,
                            onTap: onDownload!,
                            tooltip: 'Unduh',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryGreen,
          ),
        ),
      ),
    );
  }
}
