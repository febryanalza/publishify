import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/utils/image_helper.dart';
import 'package:publishify/models/user_profile.dart';

/// Reusable component untuk menampilkan portfolio item dengan loading placeholder
class PortfolioItem extends StatelessWidget {
  final Portfolio portfolio;
  final VoidCallback? onTap;

  const PortfolioItem({
    super.key,
    required this.portfolio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Portfolio image with loading placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.greyLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ImageHelper.getFullImageUrl(portfolio.imageUrl),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryGreen,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.book,
                        color: AppTheme.greyMedium,
                        size: 30,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Portfolio title
              Expanded(
                child: Text(
                  portfolio.title,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.black,
                  ),
                ),
              ),
              
              // Arrow icon
              const Icon(
                Icons.chevron_right,
                color: AppTheme.greyMedium,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
