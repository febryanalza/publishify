import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/statistics.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.greyDisabled, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar or Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                comment.userName[0].toUpperCase(),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Comment Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.userName,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                    _buildStarRating(comment.rating),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.comment,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.greyMedium,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          size: 14,
          color: AppTheme.yellow,
        );
      }),
    );
  }
}
