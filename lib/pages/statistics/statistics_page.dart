import 'package:flutter/material.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/utils/dummy_data.dart';
import 'package:publishify/models/statistics.dart';
import 'package:publishify/widgets/cards/sales_chart.dart';
import 'package:publishify/widgets/cards/comment_card.dart';
import 'package:publishify/widgets/cards/rating_bar.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Statistics _statistics;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load data from DummyData - mudah diganti nanti
    _statistics = DummyData.getStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation/Header
            _buildHeader(),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sales Chart
                      SalesChart(
                        data: _statistics.salesData,
                        title: 'Penjualan',
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Comments and Ratings Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Comments Section
                          Expanded(
                            child: _buildCommentsSection(),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Ratings Section
                          Expanded(
                            child: _buildRatingsSection(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
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
          Text(
            'Statistik',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.grid_view,
              color: AppTheme.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'Komentar',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        // Comments List
        ...(_statistics.comments.take(5).map((comment) {
          return CommentCard(comment: comment);
        })),
      ],
    );
  }

  Widget _buildRatingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'Rating',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        // Ratings Container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.greyDisabled, width: 1),
          ),
          child: Column(
            children: [
              // Average Rating Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _statistics.averageRating.toStringAsFixed(1),
                    style: AppTheme.headingLarge.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.star,
                    color: AppTheme.yellow,
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Rating Bars
              ...(_statistics.ratings.map((rating) {
                return RatingBar(rating: rating);
              })),
            ],
          ),
        ),
      ],
    );
  }
}
