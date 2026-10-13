import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../blocs/household/household_state.dart';
import '../../../widgets/custom_app_bar.dart';
import '../widgets/household_action_tile.dart';

class HouseholdEmptyView extends StatelessWidget {
  final HouseholdState state;

  const HouseholdEmptyView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar(
          title: 'Cùng xây tổ ấm xanh',
          subtitle: 'Bạn chưa tham gia hộ gia đình nào.',
          showBackButton: false,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner minh họa mầm xanh
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3E4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icons/ic_sprout_smile.png',
                        width: 56,
                        height: 56,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.eco, size: 56, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bắt đầu hành trình xanh cùng cả nhà',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tạo hộ của bạn hoặc quét mã QR của một hộ để gửi yêu cầu tham gia.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.subText,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Nút 1: + Tạo hộ gia đình
                InkWell(
                  onTap: () {
                    context.push('/family/create');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tạo hộ gia đình',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Nút 2: Quét QR hộ gia đình
                InkWell(
                  onTap: () {
                    context.push('/family/scan-qr');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8DE)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Quét QR hộ gia đình',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D4F3C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Phần: Lời mời và yêu cầu của bạn
                const Text(
                  'Lời mời và yêu cầu của bạn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 12),

                // 1. Lời mời nhận được
                HouseholdActionTile(
                  icon: const Icon(Icons.mail_outline, color: AppColors.primary, size: 22),
                  title: 'Lời mời nhận được',
                  subtitle: '${state.receivedInvitationsCount} lời mời • Có thể chấp nhận ngay',
                  onTap: () {
                    context.push('/family/invitations/received');
                  },
                ),
                const SizedBox(height: 12),

                // 2. Yêu cầu đã gửi
                HouseholdActionTile(
                  icon: const Icon(Icons.send_outlined, color: AppColors.primary, size: 20),
                  title: 'Yêu cầu đã gửi',
                  subtitle: '${state.myJoinRequestsCount} yêu cầu • Theo dõi trạng thái',
                  onTap: () {
                    context.push('/family/join-requests/my');
                  },
                ),
                const SizedBox(height: 16),

                // Lưu ý màu xanh nhạt
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3E4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.people_outline, color: AppColors.primary, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Mỗi người chỉ tham gia một hộ tại một thời điểm. Gửi yêu cầu chưa có nghĩa là bạn đã vào hộ.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2D4F3C),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
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
    );
  }
}
