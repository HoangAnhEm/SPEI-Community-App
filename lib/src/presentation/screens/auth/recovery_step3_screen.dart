import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/recovery/recovery_cubit.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class RecoveryStep3Screen extends StatefulWidget {
  const RecoveryStep3Screen({super.key});

  @override
  State<RecoveryStep3Screen> createState() => _RecoveryStep3ScreenState();
}

class _RecoveryStep3ScreenState extends State<RecoveryStep3Screen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _isPassVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  bool _isValid() {
    final pass = _passController.text;
    final confirm = _confirmPassController.text;
    return pass.isNotEmpty && pass == confirm && pass.length >= 8;
  }

  String? _confirmPassError() {
    final pass = _passController.text;
    final confirm = _confirmPassController.text;
    if (confirm.isEmpty) return null;
    if (confirm != pass) {
      return 'Mật khẩu nhập lại không khớp';
    }
    return null;
  }

  Widget _buildChecklistItem(String part1, String part2) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '✓',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          part1,
          style: const TextStyle(fontSize: 11, color: AppColors.subText),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text('•', style: TextStyle(fontSize: 11, color: AppColors.subText)),
        ),
        Text(
          part2,
          style: const TextStyle(fontSize: 11, color: AppColors.subText),
        ),
      ],
    );
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
                stepText: 'Khôi phục • Bước 3/3',
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Tạo mật khẩu mới',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Chọn một mật khẩu mới, khác mật khẩu cũ, để bảo vệ hành trình xanh của cả nhà.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.subText,
                ),
              ),
              const SizedBox(height: 32),
              
              // Success Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/ic_shield_check.png',
                      width: 18,
                      height: 18,
                      color: AppColors.primary,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.security, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Đã xác minh OTP đến email ${context.read<RecoveryCubit>().currentEmail}. Bạn có thể đặt lại mật khẩu.',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Password
              CustomTextField(
                controller: _passController,
                label: 'Mật khẩu mới',
                hintText: '••••••••••••',
                isPassword: !_isPassVisible,
                onChanged: (_) => setState(() {}),
                suffixIcon: IconButton(
                  icon: Image.asset(
                    _isPassVisible ? 'assets/icons/ic_eye.png' : 'assets/icons/ic_eye_off.png',
                    width: 20,
                    height: 20,
                    color: AppColors.primary,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.visibility_off, color: AppColors.primary, size: 20),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPassVisible = !_isPassVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              
              // Password Checklist
              const Text(
                'Mật khẩu đủ mạnh',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              _buildChecklistItem('Ít nhất 8 ký tự', 'Có chữ hoa và chữ thường'),
              const SizedBox(height: 4),
              _buildChecklistItem('Có số và ký tự đặc biệt', 'Không dùng thông tin cá nhân'),
              const SizedBox(height: 24),
              
              // Confirm Password
              CustomTextField(
                controller: _confirmPassController,
                label: 'Nhập lại mật khẩu mới',
                hintText: '••••••••••••',
                isPassword: !_isConfirmVisible,
                errorText: _confirmPassError(),
                onChanged: (_) => setState(() {}),
                suffixIcon: IconButton(
                  icon: Image.asset(
                    _isConfirmVisible ? 'assets/icons/ic_eye.png' : 'assets/icons/ic_eye_off.png',
                    width: 20,
                    height: 20,
                    color: AppColors.primary,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.visibility_off, color: AppColors.primary, size: 20),
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmVisible = !_isConfirmVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '✓',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: (_passController.text.isNotEmpty &&
                              _confirmPassController.text.isNotEmpty &&
                              _passController.text == _confirmPassController.text)
                          ? AppColors.primary
                          : AppColors.subText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mật khẩu nhập lại trùng khớp.',
                    style: TextStyle(
                      fontSize: 11,
                      color: (_passController.text.isNotEmpty &&
                              _confirmPassController.text.isNotEmpty &&
                              _passController.text == _confirmPassController.text)
                          ? AppColors.primary
                          : AppColors.subText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Button
              BlocConsumer<RecoveryCubit, RecoveryState>(
                listener: (context, state) {
                  if (state is RecoverySuccess) {
                    context.go('/recovery/success', extra: context.read<RecoveryCubit>());
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      if (state is RecoveryFailure) ...[
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
                                  state.error,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFC94A4A), height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      PrimaryButton(
                        text: 'Lưu mật khẩu mới',
                        iconPath: 'assets/icons/ic_check.png',
                        isLoading: state is RecoveryLoading,
                        isDisabled: !_isValid(),
                        onPressed: () {
                          context.read<RecoveryCubit>().resetPassword(_passController.text);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              
              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Quay lại đăng nhập',
                    style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Info Sprout
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/ic_sprout_smile.png',
                      width: 32,
                      height: 32,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Mầm nhắc bạn: đừng chia sẻ mật khẩu và mã OTP với bất kỳ ai nhé!',
                        style: TextStyle(fontSize: 13, color: AppColors.darkText, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Footer Texts
              const Text(
                'Sau khi lưu, các phiên đăng nhập cũ sẽ kết thúc. Bạn cần đăng nhập lại bằng mật khẩu mới.',
                style: TextStyle(fontSize: 11, color: AppColors.greyText, height: 1.5),
              ),
              const SizedBox(height: 24),
              const Text(
                'Xác minh và lưu mật khẩu là trạng thái minh họa; chưa thay đổi mật khẩu thực tế.',
                style: TextStyle(fontSize: 10, color: AppColors.greyText, height: 1.5),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
