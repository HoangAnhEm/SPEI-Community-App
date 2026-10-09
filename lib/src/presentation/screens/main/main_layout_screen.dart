import 'package:flutter/material.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../home/home_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Scaffold(body: Center(child: Text('Bạn Mầm', style: TextStyle(color: AppColors.darkText)))),
    const Scaffold(body: Center(child: Text('Phản ánh', style: TextStyle(color: AppColors.darkText)))),
    const Scaffold(body: Center(child: Text('Điểm xanh', style: TextStyle(color: AppColors.darkText)))),
  ];

  Widget _buildIcon(String asset, bool isSelected) {
    return Image.asset(
      asset,
      width: 24,
      height: 24,
      color: isSelected ? AppColors.primary : AppColors.greyText,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.circle_outlined,
        color: isSelected ? AppColors.primary : AppColors.greyText,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFEAF3E4),
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: _buildIcon('assets/icons/ic_nav_home.png', false),
              selectedIcon: _buildIcon('assets/icons/ic_nav_home.png', true),
              label: 'Nhà',
            ),
            NavigationDestination(
              icon: _buildIcon('assets/icons/feature_plant.png', false),
              selectedIcon: _buildIcon('assets/icons/feature_plant.png', true),
              label: 'Bạn Mầm',
            ),
            NavigationDestination(
              icon: _buildIcon('assets/icons/ic_nav_feedback.png', false),
              selectedIcon: _buildIcon('assets/icons/ic_nav_feedback.png', true),
              label: 'Phản ánh',
            ),
            NavigationDestination(
              icon: _buildIcon('assets/icons/feature_gift.png', false),
              selectedIcon: _buildIcon('assets/icons/feature_gift.png', true),
              label: 'Điểm xanh',
            ),
          ],
        ),
      ),
    );
  }
}
