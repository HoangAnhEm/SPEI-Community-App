import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/change_password/change_password_cubit.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isCurrentVisible = false;
  bool _isNewVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  bool _isValid() {
    final current = _currentPassController.text;
    final newPass = _newPassController.text;
    final confirm = _confirmPassController.text;
    return current.isNotEmpty && newPass.length >= 8 && newPass == confirm;
  }

  String? _confirmPassError() {
    final newPass = _newPassController.text;
    final confirm = _confirmPassController.text;
    if (confirm.isEmpty) return null;
    if (confirm != newPass) {
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
    const backgroundColor = AppColors.background;
    const subTextColor = AppColors.subText;

    final authState = context.watch<AuthBloc>().state;
    String email = 'lan.nguyen@example.com';
    if (authState is AuthAuthenticated && authState.user.email.isNotEmpty) {
      email = authState.user.email;
    }

    final bool isMatching = _newPassController.text.isNotEmpty &&
        _confirmPassController.text.isNotEmpty &&
        _newPassController.text == _confirmPassController.text;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Đổi mật khẩu',
              subtitle: 'Bảo vệ tài khoản SPEI Community của bạn.',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account info badge
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
                          Image.asset(
                            'assets/icons/ic_shield_check.png',
                            width: 18,
                            height: 18,
                            color: AppColors.primary,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.security, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Đang đổi mật khẩu cho tài khoản $email. Mật khẩu mới cần khác mật khẩu cũ.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mật khẩu hiện tại
                    CustomTextField(
                      controller: _currentPassController,
                      label: 'Mật khẩu hiện tại',
                      hintText: '••••••••••••',
                      isPassword: !_isCurrentVisible,
                      onChanged: (_) => setState(() {}),
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          _isCurrentVisible ? 'assets/icons/ic_eye.png' : 'assets/icons/ic_eye_off.png',
                          width: 20,
                          height: 20,
                          color: AppColors.primary,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(_isCurrentVisible ? Icons.visibility : Icons.visibility_off, color: AppColors.primary, size: 20),
                        ),
                        onPressed: () {
                          setState(() {
                            _isCurrentVisible = !_isCurrentVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mật khẩu mới
                    CustomTextField(
                      controller: _newPassController,
                      label: 'Mật khẩu mới',
                      hintText: '••••••••••••',
                      isPassword: !_isNewVisible,
                      onChanged: (_) => setState(() {}),
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          _isNewVisible ? 'assets/icons/ic_eye.png' : 'assets/icons/ic_eye_off.png',
                          width: 20,
                          height: 20,
                          color: AppColors.primary,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(_isNewVisible ? Icons.visibility : Icons.visibility_off, color: AppColors.primary, size: 20),
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewVisible = !_isNewVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Checklist
                    const Text(
                      'Mật khẩu đủ mạnh',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    _buildChecklistItem('Ít nhất 8 ký tự', 'Có chữ hoa và chữ thường'),
                    const SizedBox(height: 4),
                    _buildChecklistItem('Có số và ký tự đặc biệt', 'Không dùng thông tin cá nhân'),
                    const SizedBox(height: 24),

                    // Nhập lại mật khẩu mới
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
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(_isConfirmVisible ? Icons.visibility : Icons.visibility_off, color: AppColors.primary, size: 20),
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmVisible = !_isConfirmVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Row indicator match
                    Row(
                      children: [
                        Text(
                          '✓',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isMatching ? AppColors.primary : subTextColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mật khẩu nhập lại trùng khớp.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isMatching ? AppColors.primary : subTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Submit Button & State
                    BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
                      listener: (context, state) {
                        if (state is ChangePasswordSuccess) {
                          context.pushReplacement('/profile/change-password/success');
                        }
                      },
                      builder: (context, state) {
                        return Column(
                          children: [
                            if (state is ChangePasswordFailure) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.errorBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/icons/ic_info.png',
                                      width: 18,
                                      height: 18,
                                      color: AppColors.error,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        state.error,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.error,
                                          height: 1.4,
                                        ),
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
                              isLoading: state is ChangePasswordLoading,
                              isDisabled: !_isValid(),
                              onPressed: () {
                                context.read<ChangePasswordCubit>().changePassword(
                                      currentPassword: _currentPassController.text,
                                      newPassword: _newPassController.text,
                                    );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Footer
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
