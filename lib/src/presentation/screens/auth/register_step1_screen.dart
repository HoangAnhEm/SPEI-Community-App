import 'package:flutter/material.dart';
import '../../../../src/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/di/di.dart';
import '../../blocs/register/register_cubit.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RegisterCubit>(),
      child: const _RegisterStep1View(),
    );
  }
}

class _RegisterStep1View extends StatefulWidget {
  const _RegisterStep1View();

  @override
  State<_RegisterStep1View> createState() => _RegisterStep1ViewState();
}

class _RegisterStep1ViewState extends State<_RegisterStep1View> {
  bool _isPasswordVisible = false;
  bool _agreeTerms = false; // Mặc định chưa đồng ý

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateState);
    _phoneController.addListener(_updateState);
    _fullNameController.addListener(_updateState);
    _passwordController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {}); // Trigger rebuild to update _isFormValid()
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateState);
    _phoneController.removeListener(_updateState);
    _fullNameController.removeListener(_updateState);
    _passwordController.removeListener(_updateState);
    _emailController.dispose();
    _phoneController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _emailController.text.isNotEmpty && _emailError() == null &&
        _fullNameController.text.isNotEmpty && _fullNameController.text.trim().length >= 2 &&
        _phoneController.text.isNotEmpty && _phoneError() == null &&
        _passwordController.text.isNotEmpty && _passError() == null &&
        _agreeTerms;
  }

  String? _emailError() {
    final text = _emailController.text.trim();
    if (text.isEmpty) return null;
    if (!text.contains('@') || !text.contains('.')) return 'Email không đúng định dạng';
    return null;
  }

  String? _phoneError() {
    final text = _phoneController.text.trim();
    if (text.isEmpty) return null;
    if (text.length < 10 || !RegExp(r'^[0-9]+$').hasMatch(text)) return 'Số điện thoại không hợp lệ (cần ít nhất 10 số)';
    return null;
  }

  String? _passError() {
    final text = _passwordController.text;
    if (text.isEmpty) return null;
    if (text.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;
    const darkTextColor = AppColors.darkText;
    const subTextColor = AppColors.subText;
    const mainTextColor = AppColors.primary;
    const iconColor = AppColors.primary;

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
              
              // Full Name
              CustomTextField(
                controller: _fullNameController,
                label: 'Họ và tên *',
                hintText: 'VD: Nguyễn Văn A',
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Image.asset(
                    'assets/icons/ic_user.png',
                    width: 20,
                    height: 20,
                    color: iconColor,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email
              CustomTextField(
                controller: _emailController,
                label: 'Email *',
                hintText: 'lan.nguyen@example.com',
                errorText: _emailError(),
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
                controller: _phoneController,
                label: 'Số điện thoại *',
                hintText: '0912 345 678',
                keyboardType: TextInputType.phone,
                errorText: _phoneError(),
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
                controller: _passwordController,
                label: 'Mật khẩu *',
                hintText: '••••••••••••',
                isPassword: !_isPasswordVisible,
                errorText: _passError(),
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
              BlocConsumer<RegisterCubit, RegisterState>(
                listener: (context, state) {
                  if (state is RegisterInfoSuccess) {
                    context.push('/register/otp', extra: context.read<RegisterCubit>());
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      if (state is RegisterFailure) ...[
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
                        text: 'Gửi OTP xác nhận',
                        iconPath: 'assets/icons/ic_arrow_right.png',
                        isLoading: state is RegisterLoading,
                        isDisabled: !_isFormValid(),
                        onPressed: () {
                          context.read<RegisterCubit>().submitInfo(
                            _emailController.text.trim(),
                            _phoneController.text.trim(),
                            _fullNameController.text.trim(),
                            _passwordController.text,
                          );
                        },
                      ),
                    ],
                  );
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
                      color: iconColor,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tài khoản mới có vai trò Người dùng. Quyền quản trị chỉ được ban quản trị cấp riêng.',
                        style: TextStyle(fontSize: 12, color: mainTextColor, height: 1.4),
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
                  style: TextStyle(fontSize: 10, color: AppColors.greyText, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String part1, String part2) {
    const subTextColor = AppColors.subText;
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


