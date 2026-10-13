import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/di/di.dart';
import '../../blocs/recovery/recovery_cubit.dart';

// Màu riêng của màn này
const Color _kGreyLightE5E9E7 = Color(0xFFE5E9E7);

class RecoveryStep1Screen extends StatelessWidget {
  const RecoveryStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RecoveryCubit>(),
      child: const _RecoveryStep1View(),
    );
  }
}

class _RecoveryStep1View extends StatefulWidget {
  const _RecoveryStep1View();

  @override
  State<_RecoveryStep1View> createState() => _RecoveryStep1ViewState();
}

class _RecoveryStep1ViewState extends State<_RecoveryStep1View> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  bool _isValid() {
    return _inputController.text.trim().isNotEmpty && _inputController.text.contains('@');
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
                'Nhập email đã đăng ký để nhận mã OTP khôi phục mật khẩu.',
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
                label: 'Email đã đăng ký',
                hintText: 'email@example.vn',
                onChanged: (_) => setState(() {}),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Image.asset(
                    'assets/icons/ic_mail.png',
                    width: 20,
                    height: 20,
                    color: AppColors.primary,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.mail, color: AppColors.primary, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              
              // // Verification Channel
              // const Text(
              //   'Kênh nhận mã xác minh',
              //   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText),
              // ),
              // const SizedBox(height: 12),
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: AppColors.successBg,
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Container(
              //         padding: const EdgeInsets.all(2),
              //         decoration: const BoxDecoration(
              //           shape: BoxShape.circle,
              //         ),
              //         child: Image.asset(
              //           'assets/icons/ic_check_circle.png',
              //           width: 20,
              //           height: 20,
              //           color: AppColors.primary,
              //           errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             const Text(
              //               'Email đã đăng ký',
              //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
              //             ),
              //             const SizedBox(height: 4),
              //             Text(
              //               '${_inputController.text.isEmpty ? 'ngocanh@spei.vn' : _inputController.text} • Đã xác thực',
              //               style: const TextStyle(fontSize: 12, color: AppColors.subText),
              //             ),
              //             const SizedBox(height: 12),
              //             const Text(
              //               'Kênh đang chọn',
              //               style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 22),
              //
              // // Info Box
              // Container(
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: AppColors.blueBg,
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Image.asset(
              //         'assets/icons/ic_info.png',
              //         width: 18,
              //         height: 18,
              //         color: AppColors.bluePrimary,
              //         errorBuilder: (context, error, stackTrace) => const Icon(Icons.info_outline, color: AppColors.bluePrimary, size: 18),
              //       ),
              //       const SizedBox(width: 12),
              //       const Expanded(
              //         child: Text(
              //           'Mã OTP chỉ được gửi đến email đã đăng ký. Kiểm tra hộp thư đến và thư rác nếu chưa nhận được mã.',
              //           style: TextStyle(fontSize: 12, color: AppColors.bluePrimary, height: 1.4),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 22),
              
              // Button
              BlocConsumer<RecoveryCubit, RecoveryState>(
                listener: (context, state) {
                  if (state is RecoveryOtpRequested) {
                    context.push('/recovery/step2', extra: context.read<RecoveryCubit>());
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      if (state is RecoveryFailure) ...[
                        Container(
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
                                errorBuilder: (context, error, stackTrace) => const SizedBox(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  state.error,
                                  style: const TextStyle(fontSize: 12, color: AppColors.error, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      PrimaryButton(
                        text: 'Gửi OTP khôi phục',
                        iconPath: 'assets/icons/ic_arrow_right.png',
                        isLoading: state is RecoveryLoading,
                        isDisabled: !_isValid(),
                        onPressed: () {
                          context.read<RecoveryCubit>().requestRecoveryOtp(_inputController.text.trim());
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              
              // // Next Steps Box
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(16),
              //     border: Border.all(color: _kGreyLightE5E9E7),
              //   ),
              //   child: const Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Tiếp theo sẽ làm gì?',
              //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
              //       ),
              //       SizedBox(height: 16),
              //       Text(
              //         '1. Nhập mã OTP 6 chữ số nhận được.\n2. Xác minh danh tính của bạn.\n3. Tạo mật khẩu mới và đăng nhập lại.',
              //         style: TextStyle(fontSize: 13, color: AppColors.subText, height: 1.8),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 22),
              
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
              
              // // Footer Text
              // const Text(
              //   'Không tiết lộ tài khoản có tồn tại hay không sau khi gửi yêu cầu. Bản mẫu không gửi OTP thực tế.',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(fontSize: 10, color: AppColors.greyText, height: 1.5),
              // ),
              // const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
