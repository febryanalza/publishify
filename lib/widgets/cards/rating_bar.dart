import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/statistics.dart';

class RatingBar extends StatelessWidget {
  final Rating rating;

  const RatingBar({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Star icon
          Icon(
            Icons.star,
            size: 16,
            color: AppTheme.yellow,
          ),
          const SizedBox(width: 8),
          
          // Progress bar
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.greyDisabled.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: rating.percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Count
          SizedBox(
            width: 30,
            child: Text(
              '${rating.count}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.greyMedium,
                fontSize: 11,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
