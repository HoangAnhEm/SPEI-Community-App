import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class RecoveryStep1Screen extends StatefulWidget {
  const RecoveryStep1Screen({super.key});

  @override
  State<RecoveryStep1Screen> createState() => _RecoveryStep1ScreenState();
}

class _RecoveryStep1ScreenState extends State<RecoveryStep1Screen> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  bool _isValid() {
    return _inputController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(
                showBackButton: true,
                stepText: 'Khôi phục • Bước 1/3',
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Lấy lại mật khẩu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nhập email hoặc số điện thoại đã đăng ký. Mình sẽ giúp bạn trở lại với cả nhà.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.subText,
                ),
              ),
              const SizedBox(height: 22),
              
              // Input Field
              CustomTextField(
                controller: _inputController,
                label: 'Email hoặc số điện thoại',
                hintText: '0912 345 678',
                onChanged: (_) => setState(() {}),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Image.asset(
                    'assets/icons/ic_phone.png',
                    width: 20,
                    height: 20,
                    color: AppColors.primary,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.phone, color: AppColors.primary, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              
              // Verification Channel
              const Text(
                'Kênh nhận mã xác minh',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/icons/ic_check_circle.png',
                        width: 20,
                        height: 20,
                        color: AppColors.primary,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SMS đến số điện thoại',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '0912 ••• 678 • Đã xác thực',
                            style: TextStyle(fontSize: 12, color: AppColors.subText),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Kênh đang chọn',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              
              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/ic_info.png',
                      width: 18,
                      height: 18,
                      color: const Color(0xFF2A6C91),
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.info_outline, color: Color(0xFF2A6C91), size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Nhập số điện thoại: nhận OTP qua SMS. Nhập email: chỉ nhận OTP qua email đã xác thực; nếu chưa xác thực, hãy dùng số điện thoại liên kết.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF2A6C91), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              
              // Button
              PrimaryButton(
                text: 'Gửi OTP khôi phục',
                iconPath: 'assets/icons/ic_arrow_right.png',
                isDisabled: !_isValid(),
                onPressed: () {
                  context.push('/recovery/step3');
                },
              ),
              const SizedBox(height: 22),
              
              // Next Steps Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E9E7)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiếp theo sẽ làm gì?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '1. Nhập mã OTP 6 chữ số nhận được.\n2. Xác minh danh tính của bạn.\n3. Tạo mật khẩu mới và đăng nhập lại.',
                      style: TextStyle(fontSize: 13, color: AppColors.subText, height: 1.8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              
              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Quay lại đăng nhập',
                    style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              
              // Footer Text
              const Text(
                'Không tiết lộ tài khoản có tồn tại hay không sau khi gửi yêu cầu. Bản mẫu không gửi OTP thực tế.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppColors.greyText, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Bản mẫu giao diện • Dữ liệu minh họa',
                  style: TextStyle(fontSize: 10, color: AppColors.greyText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
