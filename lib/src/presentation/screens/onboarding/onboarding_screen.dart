import 'package:flutter/material.dart';
import '../../../../src/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/di/di.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../widgets/auth_header.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors based on the design
    const backgroundColor = AppColors.background;
    const darkTextColor = AppColors.darkText;
    const subTextColor = AppColors.subText;
    const mainTitleColor = AppColors.primary;
    const buttonColor = AppColors.primary;
    const iconBgColor = AppColors.successBg;
    const iconColor = AppColors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Logo and Title
              const AuthHeader(showBackButton: false),
              const SizedBox(height: 18),

              // Main Illustration with Chip
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/onboarding_illustration.jpg',
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text('Placeholder Image', style: TextStyle(color: Colors.grey)),
                          ),
                        );
                      },
                    ),
                  ),
                  // Floating Chip
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.successBg,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/icons/mam_ai_avatar.png', // Avatar Mầm AI
                                width: 32,
                                height: 32,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.eco, color: Colors.green, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Mầm cùng cả nhà lớn lên!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: mainTitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Title and Subtitle
              const Text(
                'Cả nhà cùng học,\ncùng sống xanh.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: darkTextColor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Biến những việc nhỏ hôm nay thành thói quen tốt cho con và một hành tinh xanh hơn.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 18),

              // Feature List
              _buildFeatureItem(
                iconPath: 'assets/icons/feature_electric.png',
                iconBgColor: iconBgColor,
                iconColor: iconColor,
                title: 'Hiểu điện dùng, giảm phát thải',
                subtitle: 'Từ hóa đơn đến những thay đổi nhỏ.',
                darkTextColor: darkTextColor,
                subTextColor: subTextColor,
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                iconPath: 'assets/icons/feature_plant.png',
                iconBgColor: iconBgColor,
                iconColor: iconColor,
                title: 'Học cùng bạn Mầm AI',
                subtitle: 'Gợi ý xanh, dễ làm cùng con mỗi ngày.',
                darkTextColor: darkTextColor,
                subTextColor: subTextColor,
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                iconPath: 'assets/icons/feature_gift.png',
                iconBgColor: iconBgColor,
                iconColor: iconColor,
                title: 'Gieo thói quen, nhận quà xanh',
                subtitle: 'Làm nhiệm vụ gia đình và tích điểm.',
                darkTextColor: darkTextColor,
                subTextColor: subTextColor,
              ),
              const SizedBox(height: 18),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Mark as not first time
                    await getIt<AuthRepository>().setFirstTime(false);
                    if (context.mounted) {
                      context.read<AuthBloc>().add(AppStarted());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Bắt đầu hành trình xanh',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Footer Text
              const Center(
                child: Text(
                  'Dành cho phụ huynh và trẻ em.\nCác tính năng trong bản mẫu chưa hoạt động thực tế.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Bản mẫu giao diện • Dữ liệu minh họa',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.subText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String iconPath,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color darkTextColor,
    required Color subTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(10), // Padding cho icon bên trong viền
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            iconPath,
            color: iconColor,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.image_not_supported, color: iconColor, size: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: subTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


