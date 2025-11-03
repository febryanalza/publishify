import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';

/// Reusable component untuk menampilkan statistik (Buku, Rating, Viewers)
class StatItem extends StatelessWidget {
  final int count;
  final String label;

  const StatItem({
    super.key,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: AppTheme.headingMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.greyMedium,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
