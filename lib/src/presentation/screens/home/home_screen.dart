import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../src/core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildGreeting(),
              const SizedBox(height: 24),
              _buildMainCard(),
              const SizedBox(height: 16),
              _buildPointsCard(),
              const SizedBox(height: 18),
              const Text(
                'Hôm nay mình làm gì?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 18),
              _buildGridMenu(context),
              const SizedBox(height: 12),
              _buildTaskCard(),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Bản mẫu giao diện • Dữ liệu minh họa',
                  style: TextStyle(fontSize: 10, color: AppColors.greyText),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/icons/logo.png',
          width: 50,
          height: 38,
          errorBuilder: (context, error, stackTrace) => const CircleAvatar(
            backgroundColor: AppColors.successBg,
            radius: 16,
            child: Icon(Icons.eco, color: AppColors.primary, size: 16),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'SPEI Community',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ),
        IconButton(
          icon: Image.asset(
            'assets/icons/ic_notification.png',
            width: 24,
            height: 24,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.notifications_none, color: AppColors.primary),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Image.asset(
            'assets/icons/ic_user.png',
            width: 24,
            height: 24,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_outline, color: AppColors.primary),
          ),
          onPressed: () {
            context.push('/profile');
          },
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thứ Năm, 08 tháng 10',
                style: TextStyle(fontSize: 12, color: AppColors.subText),
              ),
              SizedBox(height: 8),
              Text(
                'Chào mẹ Lan\nvà bé An!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: AppColors.successBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/ic_sprout_smile.png',
              width: 68,
              height: 68,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: AppColors.primary, size: 30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Điện gia đình • Tháng 09/2026',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Image.asset(
                'assets/icons/ic_arrow_up_right.png',
                width: 20,
                height: 20,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.arrow_outward, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '250',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'kWh sử dụng',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '164,8',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'kg CO₂e ước tính',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/ic_trend_down.png',
                  width: 18,
                  height: 18,
                  color: Colors.white,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.trending_down, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Giảm 10,7% điện so với tháng 08',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ước tính từ điện • Hệ số minh hoạ 0,6592',
            style: TextStyle(color: Color(0xFFE4F0DD), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D9), // Light yellowish bg
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/ic_leaf_outline.png',
            width: 28,
            height: 28,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco_outlined, color: Color(0xFF5A7B45)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Điểm xanh của cả nhà',
                  style: TextStyle(fontSize: 12, color: AppColors.subText),
                ),
                SizedBox(height: 2),
                Text(
                  '1.250 điểm',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Text(
                'Xem ví',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/icons/ic_arrow_right.png',
                width: 16,
                height: 16,
                color: AppColors.primary,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildGridItem('assets/icons/feature_electric.png', AppColors.primary, AppColors.successBg, 'Tính phát thải', 'Từ điện sử dụng', onTap: () {
          context.push('/input-electricity');
        }),
        _buildGridItem('assets/icons/ic_chat_bubble.png', AppColors.bluePrimary, AppColors.blueBg,'Hỏi bạn Mầm AI', 'Học xanh cùng con'),
        _buildGridItem('assets/icons/ic_camera.png', AppColors.bluePrimary, AppColors.blueBg,'Gửi phản ánh', 'Góp ý môi trường'),
        _buildGridItem('assets/icons/feature_gift.png', AppColors.primary, AppColors.successBg,'Đổi quà xanh', 'Quà cho cả nhà'),
      ],
    );
  }

  Widget _buildGridItem(String iconAsset, Color iconColor,Color iconBgColor, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              iconAsset,
              width: 22,
              height: 22,
              color: iconColor,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.widgets_outlined, color: iconColor, size: 20),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.subText),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildTaskCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '7 ngày tắt thiết bị',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              Text(
                '+50 điểm',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Cùng bé An kiểm tra đèn và quạt trước khi ra khỏi phòng.',
            style: TextStyle(fontSize: 13, color: AppColors.subText, height: 1.4),
          ),
          const SizedBox(height: 12),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8DC),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 6,
                width: 150, // Static width for mock
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '4/7 ngày • Chưa nhận điểm',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkText),
          ),
        ],
      ),
    );
  }
}
