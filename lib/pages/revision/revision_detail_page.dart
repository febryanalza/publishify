import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/utils/dummy_data.dart';
import 'package:publishify/models/revision.dart';
import 'package:publishify/widgets/revision/revision_comment_card.dart';

class RevisionDetailPage extends StatefulWidget {
  final Revision revision;

  const RevisionDetailPage({
    super.key,
    required this.revision,
  });

  @override
  State<RevisionDetailPage> createState() => _RevisionDetailPageState();
}

class _RevisionDetailPageState extends State<RevisionDetailPage> {
  late List<RevisionComment> _comments;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load comments for this revision
    _comments = DummyData.getRevisionComments(widget.revision.id);
  }

  void _handleSubmit() {
    // TODO: Implement submit revision
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Revisi berhasil disubmit!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    Text(
                      'Komentar',
                      style: AppTheme.headingMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Comments List
                    ..._comments.map((comment) {
                      return RevisionCommentCard(comment: comment);
                    }),
                    
                    const SizedBox(height: 20),
                    
                    // Submit Button
                    _buildSubmitButton(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Detail Revisi',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Submit',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
