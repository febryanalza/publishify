import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/percetakan.dart';

class PercetakanCard extends StatelessWidget {
  final Percetakan percetakan;
  final VoidCallback? onTap;

  const PercetakanCard({
    super.key,
    required this.percetakan,
    this.onTap,
  });

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppTheme.greyBackground,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      percetakan.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.greyBackground,
                          child: Center(
                            child: Icon(
                              Icons.print,
                              size: 40,
                              color: AppTheme.greyText,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
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
                    // Rating Badge (optional)
                    if (percetakan.rating != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha:  0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: AppTheme.yellow,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                percetakan.rating!.toStringAsFixed(1),
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      percetakan.nama,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppTheme.greyText,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            percetakan.alamat,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.greyText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Arrow Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppTheme.primaryGreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
