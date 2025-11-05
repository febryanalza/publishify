import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool hasNotification;
  final IconData? badgeIcon;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.hasNotification = false,
    this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.greyDisabled, width: 1),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppTheme.primaryDark,
                ),
              ),
              if (hasNotification)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppTheme.errorRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              if (badgeIcon != null)
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.white,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        badgeIcon,
                        size: 14,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              fontSize: 11,
              color: AppTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
