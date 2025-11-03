import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback? onTap;

  const StatusCard({
    super.key,
    required this.title,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.greyDisabled, width: 1),
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: AppTheme.headingMedium.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.greyMedium,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
