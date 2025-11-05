import 'package:flutter/material.dart';
import 'package:publishify/pages/home/home_page.dart';
import 'package:publishify/pages/statistics/statistics_page.dart';
import 'package:publishify/pages/notifications/notifications_page.dart';
import 'package:publishify/pages/profile/profile_page.dart';
import 'package:publishify/widgets/navigation/bottom_nav_bar.dart';

/// Main Layout with persistent bottom navigation bar
/// Uses IndexedStack to keep all pages in memory and switch between them
class MainLayout extends StatefulWidget {
  final int initialIndex;
  final String? userName;

  const MainLayout({
    super.key,
    this.initialIndex = 0,
    this.userName,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Initialize all pages once
    _pages = [
      HomePage(userName: widget.userName),
      const StatisticsPage(),
      const NotificationsPage(),
      const ProfilePage(),
    ];
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return; // Already on this page
    
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
