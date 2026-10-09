import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../blocs/register/register_cubit.dart';
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
  
  Timer? _countdownTimer;
  Timer? _resendTimer;
  
  int _countdownSeconds = 300; // 5 minutes
  int _resendSeconds = 32; // 32 seconds initial as per design

  @override
  void initState() {
    super.initState();
    _startTimers();
    pinController.addListener(_updateState);
  }

  void _resetTimers() {
    setState(() {
      _countdownSeconds = 300;
      _resendSeconds = 32;
    });
    _countdownTimer?.cancel();
    _resendTimer?.cancel();
    _startTimers();
  }

  void _updateState() {
    setState(() {}); // Trigger rebuild
  }

  void _startTimers() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
      }
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatPhone(String? phone) {
    if (phone == null || phone.length < 7) return '0912 ••• 678';
    final start = phone.substring(0, 4);
    final end = phone.substring(phone.length - 3);
    return '$start ••• $end';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _resendTimer?.cancel();
    pinController.removeListener(_updateState);
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
              Text(
                'Mã OTP đã được gửi qua SMS đến số ${_formatPhone(context.read<RegisterCubit>().currentPhone)}.\nNhập 6 chữ số để hoàn tất đăng ký.',
                style: const TextStyle(
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
              BlocConsumer<RegisterCubit, RegisterState>(
                listener: (context, state) {
                  if (state is RegisterOtpSuccess) {
                    context.push('/register/success', extra: context.read<RegisterCubit>());
                  } else if (state is RegisterResendSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã gửi lại mã OTP thành công.'), backgroundColor: Color(0xFF3B7D53)),
                    );
                    _resetTimers(); // Bắt đầu đếm ngược lại sau khi gửi thành công
                  }
                },
                builder: (context, state) {
                  final bool hasError = state is RegisterFailure;
                  final bool isExpired = _countdownSeconds == 0;
                  
                  return Column(
                    children: [
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
                            if (hasError) {
                              // Reset state by emitting Initial if needed, or just let Cubit handle it.
                              // Actually we shouldn't modify state directly here without event, 
                              // but we can just use the controller length to enable button.
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mã có hiệu lực 5 phút', style: TextStyle(fontSize: 12, color: subTextColor)),
                          Text('• Còn ${_formatTime(_countdownSeconds)}', style: TextStyle(fontSize: 12, color: hasError ? errorColor : subTextColor)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Error / Expired message
                      if (hasError || isExpired) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEEFEF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/icons/ic_info.png',
                                width: 18,
                                height: 18,
                                color: const Color(0xFFC94A4A),
                                errorBuilder: (context, error, stackTrace) => const SizedBox(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isExpired 
                                      ? 'Mã OTP đã hết hạn. Vui lòng bấm gửi lại mã mới.' 
                                      : (state as RegisterFailure).error,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFC94A4A), height: 1.4),
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
                        isLoading: state is RegisterLoading,
                        isDisabled: pinController.text.length != 6 || _countdownSeconds == 0,
                        onPressed: () {
                          context.read<RegisterCubit>().verifyOtp(pinController.text);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Resend Text
              Center(
                child: TextButton(
                  onPressed: _resendSeconds == 0 
                    ? () {
                        // Gọi Cubit để resend OTP. Việc đếm ngược lại sẽ được xử lý trong listener khi Success
                        context.read<RegisterCubit>().resendOtp();
                      } 
                    : null,
                  child: Text(
                    _resendSeconds > 0 
                      ? 'Chưa nhận được mã? Gửi lại sau ${_formatTime(_resendSeconds)}'
                      : 'Chưa nhận được mã? Gửi lại ngay',
                    style: TextStyle(fontSize: 13, color: _resendSeconds == 0 ? iconColor : subTextColor),
                  ),
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
