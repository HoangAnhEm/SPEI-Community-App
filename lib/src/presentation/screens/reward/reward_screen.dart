import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Vườn điểm xanh',
              subtitle: 'Việc nhỏ mỗi ngày, thói quen lớn dần',
              showBackButton: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(context),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildFilterChip('Người bạn của cây', AppColors.successBg, AppColors.primary),
                        const SizedBox(width: 8),
                        _buildFilterChip('Gia đình tái chế', AppColors.blueBg, AppColors.bluePrimary),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Nhiệm vụ cùng con',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 16),
                    _buildTaskItem(
                      iconPath: 'assets/icons/ic_bulb.png',
                      fallbackIcon: Icons.lightbulb_outline,
                      title: '7 ngày tắt thiết bị',
                      subtitle: 'Cùng con kiểm tra đèn, quạt khi rời phòng.',
                      statusText: '4/7 ngày • Chưa nhận',
                      pointText: '+50 điểm',
                      pointBgColor: AppColors.successBg,
                      pointTextColor: AppColors.primary,
                      description: 'Hoàn thành đủ 7 ngày để nhận điểm.',
                      progress: 4 / 7,
                    ),
                    const SizedBox(height: 12),
                    _buildTaskItem(
                      iconPath: 'assets/icons/feature_plant.png',
                      fallbackIcon: Icons.eco_outlined,
                      title: 'Cùng con chăm cây',
                      subtitle: 'Tưới vừa đủ và quan sát một chiếc lá mới.',
                      statusText: '1/1 hoạt động • Có thể nhận',
                      pointText: '+80 điểm',
                      pointBgColor: const Color(0xFFFFF3E0),
                      pointTextColor: const Color(0xFFE65100),
                      showClaimButton: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTaskItem(
                      iconPath: 'assets/icons/ic_recycle.png',
                      fallbackIcon: Icons.recycling,
                      title: 'Phân loại rác tại nhà',
                      subtitle: 'Bé chọn thùng cho giấy và chai sạch.',
                      statusText: 'Hoàn thành • 07/10',
                      pointText: 'Đã nhận +100',
                      pointBgColor: AppColors.successBg,
                      pointTextColor: AppColors.primary,
                      description: '100 điểm đã cộng vào số dư ngày 07/10.',
                    ),
                    const SizedBox(height: 24),
                    _buildInfoFooter(),
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

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số dư của gia đình Lan & An',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        '1.250',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'điểm',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/ic_sprout_smile.png',
                    width: 64,
                    height: 64,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: AppColors.primary, size: 32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đủ đổi bộ trồng cây 800 điểm',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              GestureDetector(
                onTap: () {
                  context.push('/reward-store');
                },
                child: Row(
                  children: [
                    const Text(
                      'Đổi quà',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(width: 4),
                    Image.asset(
                      'assets/icons/ic_arrow_right.png',
                      width: 16,
                      height: 16,
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildTaskItem({
    required String iconPath,
    required IconData fallbackIcon,
    required String title,
    required String subtitle,
    required String statusText,
    required String pointText,
    required Color pointBgColor,
    required Color pointTextColor,
    String? description,
    double? progress,
    bool showClaimButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    width: 20,
                    height: 20,
                    color: AppColors.primary,
                    errorBuilder: (context, error, stackTrace) => Icon(fallbackIcon, color: AppColors.primary, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.subText, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusText,
                style: const TextStyle(fontSize: 11, color: AppColors.subText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: pointBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pointText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: pointTextColor),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 11, color: AppColors.subText),
            ),
          ],
          if (showClaimButton) ...[
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Nhận 80 điểm',
              onPressed: () {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/icons/ic_info.png',
            width: 16,
            height: 16,
            color: AppColors.subText,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.info_outline, size: 16, color: AppColors.subText),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Chỉ nhiệm vụ hợp lệ mới nhận điểm, mỗi nhiệm vụ theo giới hạn hiển thị. Gửi phản ánh không được thưởng điểm. Số dư là dữ liệu minh họa.',
              style: TextStyle(fontSize: 11, color: AppColors.subText, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
