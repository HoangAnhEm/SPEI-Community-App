import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import 'widgets/qr_code_display.dart';

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key});

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> {
  bool _isCopied = false;

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'TL';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'TL';
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;
    const darkTextColor = AppColors.darkText;
    const subTextColor = AppColors.subText;

    final authState = context.watch<AuthBloc>().state;
    String fullName = 'Nguyễn Thị Lan';
    String email = 'lan.nguyen@example.com';
    String userId = '7b2e6c90-4a18-4f5d-9c31-8e0a6d2f714b';

    if (authState is AuthAuthenticated) {
      if (authState.user.fullName.isNotEmpty) fullName = authState.user.fullName;
      if (authState.user.email.isNotEmpty) email = authState.user.email;
      if (authState.user.id.isNotEmpty) userId = authState.user.id;
    }

    final initials = _getInitials(fullName);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'QR của tôi',
              subtitle: 'Đưa mã này cho chủ hộ để tìm và mời bạn.',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Mini Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6E8CD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: darkTextColor,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QR Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QrCodeDisplay(
                            data: userId,
                            size: 210,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'QR minh họa • Chưa mã hóa để quét thực tế',
                            style: TextStyle(
                              fontSize: 11,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full User ID Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ID người dùng • đầy đủ',
                            style: TextStyle(
                              fontSize: 11,
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            userId,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: darkTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Copy Action Button
                    PrimaryButton(
                      text: 'Sao chép ID người dùng',
                      iconPath: 'assets/icons/ic_check.png',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: userId));
                        setState(() {
                          _isCopied = true;
                        });
                      },
                    ),

                    // Success Alert Box (only visible when _isCopied is true)
                    if (_isCopied) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC2DFC0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Đã sao chép ID người dùng',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Security / Identifier Note
                    const Center(
                      child: Text(
                        'Mã này giúp nhận diện bạn, không chứa mật khẩu hay mã OTP.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: subTextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

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
