import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/utils/dummy_data.dart';
import 'package:publishify/models/revision.dart';
import 'package:publishify/widgets/revision/revision_card.dart';
import 'package:publishify/pages/revision/revision_detail_page.dart';

class RevisionPage extends StatefulWidget {
  const RevisionPage({super.key});

  @override
  State<RevisionPage> createState() => _RevisionPageState();
}

class _RevisionPageState extends State<RevisionPage> {
  late List<Revision> _revisions;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load data from DummyData - mudah diganti nanti
    _revisions = DummyData.getRevisions();
  }

  void _openRevisionDetail(Revision revision) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RevisionDetailPage(revision: revision),
      ),
    );
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
              child: _revisions.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Revisions List
                          ..._revisions.map((revision) {
                            return RevisionCard(
                              revision: revision,
                              onTap: () => _openRevisionDetail(revision),
                            );
                          }),
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
          Text(
            'Revisi',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note,
            size: 80,
            color: AppTheme.greyMedium.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada revisi',
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.greyMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revisi buku akan muncul di sini',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
