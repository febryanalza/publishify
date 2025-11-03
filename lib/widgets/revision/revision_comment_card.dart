import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/models/revision.dart';

/// Reusable component untuk menampilkan revision comment
class RevisionCommentCard extends StatelessWidget {
  final RevisionComment comment;

  const RevisionCommentCard({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.greyDisabled,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File Label
          Text(
            'File',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comment.file,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Description Label
          Text(
            'Deskripsi',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comment.description,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.black,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Attachment (if exists)
          if (comment.attachmentPath != null) ...[
            Text(
              'Pilih File Perbaikan',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyMedium,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.greyDisabled,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.greyDisabled,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      comment.attachmentPath!,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.greyMedium,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Comment Label
          Text(
            'Komentar',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyMedium,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comment.comment,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
