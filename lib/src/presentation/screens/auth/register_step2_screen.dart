import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/primary_button.dart';

class RegisterStep2Screen extends StatefulWidget {
  const RegisterStep2Screen({super.key});

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  bool hasError = false; // Demo trạng thái lỗi

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFAF9F6);
    const darkTextColor = Color(0xFF1B3D2F);
    const subTextColor = Color(0xFF7B8780);
    const iconColor = Color(0xFF3B7D53);
    const errorColor = Color(0xFFD32F2F);
    const errorBgColor = Color(0xFFFDECEA);

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

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
                stepText: 'Bước 2/3 • Xác thực',
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Xác thực số điện thoại',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mã OTP đã được gửi qua SMS đến số 0912 ••• 678.\nNhập 6 chữ số để hoàn tất đăng ký.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 32),
              
              // Center Phone Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF1EB),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/ic_phone_large.png',
                      width: 32,
                      height: 32,
                      color: iconColor,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Mã xác nhận 6 chữ số',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Pinput for OTP
              Center(
                child: Pinput(
                  length: 6,
                  controller: pinController,
                  focusNode: focusNode,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: iconColor, width: 2),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: errorColor, width: 2),
                    ),
                  ),
                  forceErrorState: hasError,
                  onChanged: (value) {
                    if (hasError) setState(() => hasError = false);
                  },
                  onCompleted: (pin) {
                    // Demo: 123456 là lỗi, còn lại pass
                    if (pin == '123456') {
                      setState(() => hasError = true);
                    } else {
                      setState(() => hasError = false);
                      // context.push('/register/success');
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mã có hiệu lực 5 phút', style: TextStyle(fontSize: 12, color: subTextColor)),
                  Text('• Còn 04:32', style: TextStyle(fontSize: 12, color: hasError ? errorColor : subTextColor)),
                ],
              ),
              const SizedBox(height: 24),
              
              // Error message
              if (hasError) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: errorBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/ic_info.png',
                        width: 18,
                        height: 18,
                        color: errorColor,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Mã chưa đúng. Vui lòng kiểm tra SMS và nhập lại. Mã vẫn còn hiệu lực.',
                          style: TextStyle(fontSize: 12, color: errorColor, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Verify Button
              PrimaryButton(
                text: 'Xác nhận OTP',
                iconPath: 'assets/icons/ic_check_circle.png',
                onPressed: () {
                  if (pinController.text.length == 6 && !hasError) {
                    context.push('/register/success');
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // Resend Text
              const Center(
                child: Text(
                  'Chưa nhận được mã? Gửi lại sau 00:32',
                  style: TextStyle(fontSize: 13, color: subTextColor),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text(
                    'Sửa số điện thoại',
                    style: TextStyle(fontSize: 13, color: iconColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giữ mã OTP cho riêng bạn',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkTextColor),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'SPEI không yêu cầu bạn chia sẻ mã. Nếu mã hết hạn, hãy yêu cầu mã mới khi bộ đếm gửi lại kết thúc.',
                      style: TextStyle(fontSize: 12, color: subTextColor, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Footer
              const Center(
                child: Text(
                  'Trạng thái sau gửi OTP là minh họa; chưa gửi SMS thực tế.\n\nBản mẫu giao diện • Dữ liệu minh họa',
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
