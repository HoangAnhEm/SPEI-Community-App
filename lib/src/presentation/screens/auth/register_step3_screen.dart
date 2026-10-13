import 'package:flutter/material.dart';
import '../../../../src/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/register/register_cubit.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/primary_button.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';

class RegisterStep3Screen extends StatelessWidget {
  const RegisterStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;
    const darkTextColor = AppColors.darkText;
    const subTextColor = AppColors.subText;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(
                showBackButton: true,
                stepText: 'Bước 3/3 • Hoàn tất',
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Mầm xanh đã sẵn sàng!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tài khoản của bạn đã được tạo. Cả nhà có thể bắt đầu hành trình cùng SPEI Community.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 32),
              
              // Success Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icons/ic_sprout_smile.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Số điện thoại đã xác thực',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatPhone(context.read<RegisterCubit>().currentPhone),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkTextColor, letterSpacing: 1),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Xác thực thành công bằng OTP SMS.',
                      style: TextStyle(fontSize: 12, color: subTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin tài khoản',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Email: ${context.read<RegisterCubit>().currentEmail ?? 'lan.nguyen@example.com'}',
                      style: const TextStyle(fontSize: 13, color: darkTextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Email chưa xác thực',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vai trò: ${context.read<RegisterCubit>().registeredUser?.role ?? 'Người dùng • Dành cho gia đình'}',
                      style: const TextStyle(fontSize: 13, color: subTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Action Button
              PrimaryButton(
                text: 'Về trang chủ gia đình',
                iconPath: 'assets/icons/ic_home.png',
                onPressed: () {
                  context.read<AuthBloc>().add(AuthStatusChanged());
                  // GoRouter sẽ tự động redirect
                },
              ),
              const SizedBox(height: 32),
              
              // Bottom Illustration
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/onboarding_illustration.jpg', 
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
              const SizedBox(height: 24),
              
              // Footer
              const Center(
                child: Text(
                  'Đây là trạng thái hoàn tất minh họa, chưa tạo tài khoản hay xác thực số điện thoại thực tế.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: AppColors.greyText, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPhone(String? phone) {
    if (phone == null || phone.length < 7) return '0912 ••• 678';
    final start = phone.substring(0, 4);
    final end = phone.substring(phone.length - 3);
    return '$start ••• $end';
  }
}



