import 'package:flutter/material.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../home/home_screen.dart';
import '../mam_ai/mam_ai_screen.dart';
import '../reward/reward_store_screen.dart';
import '../family/family_screen.dart';
import '../incident/incident_list_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  static const int homeTab = 0;
  static const int mamAiTab = 1;
  static const int incidentTab = 2;
  static const int rewardTab = 3;
  static const int familyTab = 4;

  /// Chuyển tab bottom nav từ các màn con bên trong MainLayoutScreen.
  static void switchTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_MainLayoutScreenState>()?.switchTab(index);
  }

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  void switchTab(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const MamAiScreen(),
    const IncidentListScreen(showBackButton: false),
    // RewardScreen không còn dùng ở tab này, chuyển thẳng tới cửa hàng quà.
    const RewardStoreScreen(showBackButton: false),
    const FamilyScreen(),
  ];

  Widget _buildIcon(
      String asset,
      bool isSelected, {
        IconData fallback = Icons.circle_outlined,
      }) {
    final Color color =
    isSelected ? AppColors.primary : const Color(0xFF7B8782);

    final double size = isSelected ? 24 : 22;

    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      errorBuilder: (context, error, stackTrace) => Icon(
        fallback,
        color: color,
        size: size,
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
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (states) {
                final isSelected = states.contains(WidgetState.selected);

                return TextStyle(
                  // Màu chữ khi chọn / không chọn.
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF7B8782),

                  // Kích thước chữ khi chọn / không chọn.
                  fontSize: isSelected ? 11 : 11,

                  // Độ đậm chữ khi chọn / không chọn.
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
                );
              },
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: switchTab,
            backgroundColor: Colors.white,
            indicatorColor: AppColors.successBg,
            surfaceTintColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: _buildIcon(
                  'assets/icons/ic_nav_home.png',
                  false,
                ),
                selectedIcon: _buildIcon(
                  'assets/icons/ic_nav_home.png',
                  true,
                ),
                label: 'Nhà',
              ),
              NavigationDestination(
                icon: _buildIcon(
                  'assets/icons/feature_plant.png',
                  false,
                ),
                selectedIcon: _buildIcon(
                  'assets/icons/feature_plant.png',
                  true,
                ),
                label: 'Bạn Mầm',
              ),
              NavigationDestination(
                icon: _buildIcon(
                  'assets/icons/ic_nav_feedback.png',
                  false,
                ),
                selectedIcon: _buildIcon(
                  'assets/icons/ic_nav_feedback.png',
                  true,
                ),
                label: 'Phản ánh',
              ),
              NavigationDestination(
                icon: _buildIcon(
                  'assets/icons/feature_gift.png',
                  false,
                ),
                selectedIcon: _buildIcon(
                  'assets/icons/feature_gift.png',
                  true,
                ),
                label: 'Điểm xanh',
              ),
              NavigationDestination(
                icon: _buildIcon(
                  'assets/icons/ic_family.png',
                  false,
                  fallback: Icons.people_outline,
                ),
                selectedIcon: _buildIcon(
                  'assets/icons/ic_family.png',
                  true,
                  fallback: Icons.people_outline,
                ),
                label: 'Gia đình',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
