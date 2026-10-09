import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/di/di.dart';
import '../../blocs/login/login_cubit.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: const _LoginScreenView(),
    );
  }
}

class _LoginScreenView extends StatefulWidget {
  const _LoginScreenView();

  @override
  State<_LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<_LoginScreenView> {
  bool _isPasswordVisible = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              const AuthHeader(),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Chào cả nhà trở lại!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đăng nhập để tiếp tục hành trình sống xanh cùng bạn Mầm.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 24),
              
              // Illustration
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/onboarding_illustration.jpg', // Tạm dùng lại ảnh minh họa onboarding
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Form
              CustomTextField(
                controller: _usernameController,
                label: 'Email hoặc số điện thoại',
                hintText: 'lan.nguyen@example.com',
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
              CustomTextField(
                controller: _passwordController,
                label: 'Mật khẩu',
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
              const SizedBox(height: 12),
              
              // Forgot Password
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      fontSize: 13,
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Login Button
              BlocConsumer<LoginCubit, LoginState>(
                listener: (context, state) {
                  if (state is LoginFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error), backgroundColor: Colors.red),
                    );
                  } else if (state is LoginSuccess) {
                    context.go('/');
                  }
                },
                builder: (context, state) {
                  return PrimaryButton(
                    text: 'Đăng nhập',
                    iconPath: 'assets/icons/ic_arrow_right.png',
                    isLoading: state is LoginLoading,
                    onPressed: () {
                      context.read<LoginCubit>().login(
                        _usernameController.text.trim(),
                        _passwordController.text,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Register Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    context.push('/register');
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Chưa có tài khoản? ',
                      style: TextStyle(color: subTextColor, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Đăng ký ngay',
                          style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Message Chip
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF1EB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/mam_ai_avatar.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.eco, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Mỗi việc nhỏ hôm nay là một mầm xanh cho ngày mai.',
                        style: TextStyle(
                          fontSize: 13,
                          color: darkTextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Footer
              const Center(
                child: Text(
                  'Thao tác đăng nhập trong bản mẫu chưa hoạt động thực tế.\n\nBản mẫu giao diện • Dữ liệu minh họa',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFB0B8B4),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
