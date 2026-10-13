import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/primary_button.dart';

class ChangePasswordSuccessScreen extends StatelessWidget {
  const ChangePasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;
    const darkTextColor = AppColors.darkText;
    const subTextColor = AppColors.subText;

    final authState = context.watch<AuthBloc>().state;
    String email = 'lan.nguyen@example.com';
    if (authState is AuthAuthenticated && authState.user.email.isNotEmpty) {
      email = authState.user.email;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                  showBackButton: false,
                  stepText: 'Bảo mật • Hoàn tất',
                ),
                const SizedBox(height: 32),

                const Text(
                  'Đổi mật khẩu thành công!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tài khoản của bạn đã được cập nhật mật khẩu mới. Bạn cần đăng nhập lại với mật khẩu mới để tiếp tục hành trình cùng SPEI Community.',
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
                        'Tài khoản đã được bảo vệ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: darkTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Mật khẩu mới đã được cập nhật và sẵn sàng sử dụng.',
                        textAlign: TextAlign.center,
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
                        'Thông tin bảo mật',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Email: $email',
                        style: const TextStyle(fontSize: 13, color: darkTextColor),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Mật khẩu: Đã đổi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Lưu ý: Các phiên đăng nhập cũ đã được vô hiệu hóa để đảm bảo an toàn. Vui lòng đăng nhập lại.',
                        style: TextStyle(fontSize: 13, color: subTextColor, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Button to Re-Login
                PrimaryButton(
                  text: 'Đăng nhập lại',
                  iconPath: 'assets/icons/ic_arrow_right.png',
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
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
                    'Bảo mật tài khoản là ưu tiên hàng đầu của SPEI Community.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: AppColors.greyText, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
