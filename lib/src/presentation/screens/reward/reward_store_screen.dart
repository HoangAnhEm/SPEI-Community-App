import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class RewardStoreScreen extends StatelessWidget {
  const RewardStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Quà xanh cho nhà',
              subtitle: 'Tích thói quen tốt, đổi niềm vui nhỏ',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Tất cả', AppColors.successBg, AppColors.primary),
                          const SizedBox(width: 8),
                          _buildFilterChip('Làm vườn', const Color(0xFFF0F0F0), AppColors.subText),
                          const SizedBox(width: 8),
                          _buildFilterChip('Đồ dùng', const Color(0xFFF0F0F0), AppColors.subText),
                          const SizedBox(width: 8),
                          _buildFilterChip('Học cùng bé', const Color(0xFFF0F0F0), AppColors.subText),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: AppColors.successBg,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/icons/mam_ai_avatar.png', // Avatar Mầm AI
                              width: 42,
                              height: 42,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.eco, color: Colors.green, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Một món quà, thêm một cách để cả nhà sống xanh!',
                            style: TextStyle(fontSize: 13, color: AppColors.subText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                      children: [
                        _buildGiftItem(
                          context: context,
                          imageUrl: 'assets/images/plant.png',
                          fallbackIcon: Icons.local_florist,
                          title: 'Bộ trồng cây',
                          subtitle: 'Gieo mầm cùng bé',
                          points: 800,
                          statusText: 'Đủ điểm • Xem quà',
                          isEnoughPoints: true,
                        ),
                        _buildGiftItem(
                          context: context,
                          imageUrl: 'assets/images/bottle.png',
                          fallbackIcon: Icons.local_drink,
                          title: 'Bình nước xanh',
                          subtitle: 'Bình 500 ml, dùng lại',
                          points: 1500,
                          statusText: 'Thiếu 250 điểm',
                          isEnoughPoints: false,
                        ),
                        _buildGiftItem(
                          context: context,
                          imageUrl: 'assets/images/book.png',
                          fallbackIcon: Icons.menu_book,
                          title: 'Sách hoạt động xanh',
                          subtitle: '20 trò chơi cùng con',
                          points: 600,
                          statusText: 'Đủ điểm • Xem quà',
                          isEnoughPoints: true,
                        ),
                        _buildGiftItem(
                          context: context,
                          imageUrl: 'assets/images/bag.png',
                          fallbackIcon: Icons.shopping_bag,
                          title: 'Túi vải lá nhỏ',
                          subtitle: 'Mang theo khi đi chợ',
                          points: 950,
                          statusText: 'Đủ điểm • Xem quà',
                          isEnoughPoints: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Danh mục, giá điểm và hình ảnh là ví dụ. Bản mẫu chưa có dịch vụ cung cấp hoặc giao quà.',
                      style: TextStyle(fontSize: 10, color: AppColors.subText),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Bản mẫu giao diện • Dữ liệu minh họa',
                        style: TextStyle(fontSize: 10, color: AppColors.greyText),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/ic_leaf_outline.png',
            width: 32,
            height: 32,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco_outlined, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Điểm xanh hiện có',
                  style: TextStyle(fontSize: 11, color: AppColors.subText),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '1.250',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black, height: 1.0),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'điểm',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black, height: 1.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/icons/ic_history.png',
            width: 24,
            height: 24,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.history, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildGiftItem({
    required BuildContext context,
    required String imageUrl,
    required IconData fallbackIcon,
    required String title,
    required String subtitle,
    required int points,
    required String statusText,
    required bool isEnoughPoints,
  }) {
    final formattedPoints = points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    
    return GestureDetector(
      onTap: () {
        context.push('/reward-detail');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFFF5F5F5),
                  child: Icon(fallbackIcon, size: 40, color: AppColors.subText),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: AppColors.subText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formattedPoints,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1.0),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'điểm',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isEnoughPoints ? AppColors.successBg : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isEnoughPoints ? AppColors.primary : AppColors.subText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
