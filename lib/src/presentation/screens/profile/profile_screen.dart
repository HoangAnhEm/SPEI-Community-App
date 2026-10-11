import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_confirm_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
    String phone = '0912 345 678';
    String userId = '7b2e6c90-4a18-4f5d-9c31-8e0a6d2f714b';

    if (authState is AuthAuthenticated) {
      if (authState.user.fullName.isNotEmpty) fullName = authState.user.fullName;
      if (authState.user.email.isNotEmpty) email = authState.user.email;
      if (authState.user.phone.isNotEmpty) phone = authState.user.phone;
      if (authState.user.id.isNotEmpty) userId = authState.user.id;
    }

    final initials = _getInitials(fullName);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Tài khoản của tôi',
              subtitle: 'Thông tin giúp cả nhà nhận ra bạn.',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Avatar Card
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
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6E8CD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: darkTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Cùng SPEI gieo mầm sống xanh',
                                  style: TextStyle(
                                    fontSize: 13,
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

                    // Notice Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/icons/ic_shield_check.png',
                            width: 20,
                            height: 20,
                            color: AppColors.primary,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.lock_outline, size: 20, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Thông tin tài khoản hiện chỉ để xem. Bạn chưa thể thay đổi tên, email, số điện thoại hoặc ID.',
                              style: TextStyle(
                                fontSize: 12,
                                color: darkTextColor,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // User Details Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem('Họ và tên', fullName),
                          const SizedBox(height: 16),
                          _buildDetailItem('Email', email),
                          const SizedBox(height: 16),
                          _buildDetailItem('Số điện thoại', phone),
                          const SizedBox(height: 16),
                          _buildDetailItem('ID người dùng', userId),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action: QR của tôi
                    _buildActionCard(
                      icon: const Icon(Icons.qr_code_2, color: AppColors.primary, size: 24),
                      title: 'QR của tôi',
                      subtitle: 'Hiển thị và sao chép ID người dùng',
                      onTap: () {
                        context.push('/profile/qr');
                      },
                    ),
                    const SizedBox(height: 12),

                    // Action: Đổi mật khẩu
                    _buildActionCard(
                      icon: Image.asset(
                        'assets/icons/ic_shield_check.png',
                        width: 22,
                        height: 22,
                        color: AppColors.primary,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
                      ),
                      title: 'Đổi mật khẩu',
                      subtitle: 'Bảo vệ tài khoản của bạn',
                      onTap: () {
                        context.push('/profile/change-password');
                      },
                    ),
                    const SizedBox(height: 12),

                    // Action: Đăng xuất
                    _buildActionCard(
                      icon: const Icon(Icons.logout, color: Color(0xFFC94A4A), size: 22),
                      title: 'Đăng xuất',
                      titleColor: const Color(0xFFC94A4A),
                      onTap: () {
                        _showLogoutDialog(context, fullName);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Footer
                    const Center(
                      child: Text(
                        'Bản mẫu giao diện • Dữ liệu minh họa',
                        style: TextStyle(fontSize: 10, color: AppColors.greyText),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.subText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required Widget icon,
    required String title,
    String? subtitle,
    Color titleColor = AppColors.darkText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: titleColor == const Color(0xFFC94A4A)
                      ? const Color(0xFFFEEFEF)
                      : AppColors.successBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.greyText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, String fullName) {
    CustomConfirmDialog.show(
      context: context,
      title: 'Đăng xuất khỏi SPEI?',
      content: 'Bạn sẽ cần đăng nhập lại để tiếp tục sử dụng tài khoản $fullName.',
      confirmText: 'Đăng xuất',
      onConfirm: () {
        context.read<AuthBloc>().add(AuthLogoutRequested());
      },
    );
  }
}
