import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/household/household_cubit.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../profile/widgets/qr_code_display.dart';

class HouseholdQrScreen extends StatefulWidget {
  const HouseholdQrScreen({super.key});

  @override
  State<HouseholdQrScreen> createState() => _HouseholdQrScreenState();
}

class _HouseholdQrScreenState extends State<HouseholdQrScreen> {
  bool _isCopied = false;

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'NX';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'NX';
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;
    const darkTextColor = AppColors.darkText;
    const subTextColor = AppColors.subText;

    final householdState = context.watch<HouseholdCubit>().state;
    final household = householdState.household;

    final householdName = household?.name ?? 'Nhà Mầm xanh';
    final ownerName = household?.owner?.fullName ?? '';
    final memberCount = household?.memberCount ?? 1;
    final householdId = household?.id ?? '';

    final initials = _getInitials(householdName);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'QR hộ gia đình',
              subtitle: 'Chia sẻ mã này để gửi yêu cầu tham gia.',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Household Mini Card
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
                              color: AppColors.greenBorderLight,
                              borderRadius: BorderRadius.circular(12),
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
                                  householdName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: darkTextColor,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  ownerName.isNotEmpty
                                      ? 'Chủ hộ: $ownerName • $memberCount thành viên'
                                      : '$memberCount thành viên',
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
                            data: householdId,
                            size: 210,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'QR hộ gia đình • Quét để gửi yêu cầu gia nhập',
                            style: TextStyle(
                              fontSize: 11,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full Household ID Card
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
                            'ID hộ gia đình • đầy đủ',
                            style: TextStyle(
                              fontSize: 11,
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            householdId,
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
                      text: 'Sao chép ID hộ gia đình',
                      iconPath: 'assets/icons/ic_check.png',
                      onPressed: () {
                        if (householdId.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: householdId));
                          setState(() {
                            _isCopied = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép ID hộ gia đình vào bộ nhớ tạm'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      },
                    ),

                    // Success Alert Box
                    if (_isCopied) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greenSoft),
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
                                'Đã sao chép ID hộ gia đình',
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

                    // Note
                    const Center(
                      child: Text(
                        'Mã này giúp người khác tìm và gửi yêu cầu tham gia vào hộ gia đình của bạn.',
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
