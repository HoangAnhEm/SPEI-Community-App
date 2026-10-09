import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  bool _isPasswordVisible = false;
  bool _agreeTerms = true;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFAF9F6);
    const darkTextColor = Color(0xFF1B3D2F);
    const subTextColor = Color(0xFF7B8780);
    const iconColor = Color(0xFF3B7D53);

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
                stepText: 'Bước 1/3 • Thông tin',
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Gieo mầm cùng SPEI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tạo tài khoản phụ huynh để cả nhà cùng học và sống xanh.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 32),
              
              // Email
              CustomTextField(
                label: 'Email *',
                hintText: 'lan.nguyen@example.com',
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Image.asset(
                    'assets/icons/ic_mail.png',
                    width: 20,
                    height: 20,
                    color: iconColor,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Phone
              CustomTextField(
                label: 'Số điện thoại *',
                hintText: '0912 345 678',
                keyboardType: TextInputType.phone,
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Image.asset(
                    'assets/icons/ic_phone.png',
                    width: 20,
                    height: 20,
                    color: iconColor,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nhận mã OTP qua SMS để xác thực số điện thoại.',
                style: TextStyle(fontSize: 12, color: subTextColor),
              ),
              const SizedBox(height: 16),
              
              // Password
              CustomTextField(
                label: 'Mật khẩu *',
                hintText: '••••••••••••',
                isPassword: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Image.asset(
                    _isPasswordVisible ? 'assets/icons/ic_eye.png' : 'assets/icons/ic_eye_off.png',
                    width: 20,
                    height: 20,
                    color: iconColor,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Password Checklist
              const Text(
                'Mật khẩu đủ mạnh',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: iconColor),
              ),
              const SizedBox(height: 8),
              _buildChecklistItem('Ít nhất 8 ký tự', 'Có chữ hoa và chữ thường'),
              const SizedBox(height: 4),
              _buildChecklistItem('Có số và ký tự đặc biệt', 'Không dùng thông tin cá nhân'),
              const SizedBox(height: 24),
              
              // Terms Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreeTerms = !_agreeTerms;
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 2, right: 12),
                      decoration: BoxDecoration(
                        color: _agreeTerms ? iconColor : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _agreeTerms ? iconColor : Colors.grey.shade400),
                      ),
                      child: _agreeTerms
                          ? Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Image.asset(
                                'assets/icons/ic_check.png',
                                color: Colors.white,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.check, size: 14, color: Colors.white),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Tôi đồng ý với Điều khoản sử dụng và Chính sách bảo mật của SPEI Community.',
                      style: TextStyle(fontSize: 13, color: darkTextColor, height: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Next Button
              PrimaryButton(
                text: 'Gửi OTP xác nhận',
                iconPath: 'assets/icons/ic_arrow_right.png',
                onPressed: () {
                  context.push('/register/otp');
                },
              ),
              const SizedBox(height: 24),
              
              // Login Link
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Đã có tài khoản? ',
                      style: TextStyle(color: subTextColor, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Đăng nhập',
                          style: TextStyle(color: iconColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Info Chip
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF1EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/ic_shield_check.png',
                      width: 18,
                      height: 18,
                      color: iconColor,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tài khoản mới có vai trò Người dùng. Quyền quản trị chỉ được ban quản trị cấp riêng.',
                        style: TextStyle(fontSize: 12, color: subTextColor, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Footer
              const Center(
                child: Text(
                  'Bản mẫu không gửi SMS hoặc tạo tài khoản thực tế.\n\nBản mẫu giao diện • Dữ liệu minh họa',
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

  Widget _buildChecklistItem(String part1, String part2) {
    const subTextColor = Color(0xFF7B8780);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '✓',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: subTextColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          part1,
          style: const TextStyle(fontSize: 11, color: subTextColor),
        ),
        const SizedBox(width: 6),
        const Text('•', style: TextStyle(fontSize: 11, color: subTextColor)),
        const SizedBox(width: 6),
        Text(
          part2,
          style: const TextStyle(fontSize: 11, color: subTextColor),
        ),
      ],
    );
  }
}
