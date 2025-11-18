import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/writer/revision.dart';

/// Reusable component untuk menampilkan revision item
class RevisionCard extends StatelessWidget {
  final Revision revision;
  final VoidCallback onTap;

  const RevisionCard({
    super.key,
    required this.revision,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.greyDisabled,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Title
            Expanded(
              child: Text(
                revision.bookTitle,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppTheme.black,
                ),
              ),
            ),
            
            // Status Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(),
                color: AppTheme.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (revision.status) {
      case RevisionStatus.completed:
        return AppTheme.primaryGreen;
      case RevisionStatus.inProgress:
        return AppTheme.yellow;
      case RevisionStatus.pending:
        return AppTheme.greyMedium;
    }
  }

  IconData _getStatusIcon() {
    switch (revision.status) {
      case RevisionStatus.completed:
        return Icons.check;
      case RevisionStatus.inProgress:
        return Icons.schedule;
      case RevisionStatus.pending:
        return Icons.pending;
    }
  }
}
