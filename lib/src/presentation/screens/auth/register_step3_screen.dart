import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/primary_button.dart';

class RegisterStep3Screen extends StatelessWidget {
  const RegisterStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFAF9F6);
    const darkTextColor = Color(0xFF1B3D2F);
    const subTextColor = Color(0xFF7B8780);

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
                  color: const Color(0xFFEBF1EB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.1)),
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
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3B7D53)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '0912 ••• 678',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkTextColor, letterSpacing: 1),
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
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin tài khoản',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Email: lan.nguyen@example.com',
                      style: TextStyle(fontSize: 13, color: darkTextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Email chưa xác thực',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB37322)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vai trò: Người dùng • Dành cho gia đình',
                      style: TextStyle(fontSize: 13, color: subTextColor),
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
                  context.go('/');
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
                  'Đây là trạng thái hoàn tất minh họa, chưa tạo tài khoản hay xác thực số điện thoại thực tế.\n\nBản mẫu giao diện • Dữ liệu minh họa',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Color(0xFFB0B8B4), height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
