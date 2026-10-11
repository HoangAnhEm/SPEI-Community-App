import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../blocs/household/household_state.dart';
import '../../../widgets/custom_app_bar.dart';
import '../widgets/household_action_tile.dart';
import '../widgets/household_info_card.dart';
import '../widgets/household_member_list_card.dart';

class HouseholdOwnerView extends StatelessWidget {
  final HouseholdState state;

  const HouseholdOwnerView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final household = state.household!;
    final ownerName = household.owner?.fullName ?? '';

    return Column(
      children: [
        const CustomAppBar(
          title: 'Gia đình của tôi',
          subtitle: 'Cùng cả nhà vun đắp những thói quen xanh.',
          showBackButton: false,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card thông tin hộ
                HouseholdInfoCard(
                  householdName: household.name,
                  memberCount: household.memberCount,
                  ownerName: ownerName,
                  isOwner: true,
                ),
                const SizedBox(height: 20),

                // Danh sách thành viên
                HouseholdMemberListCard(
                  members: household.members,
                  currentUserId: state.currentUserId,
                ),
                const SizedBox(height: 20),

                // Nút + Mời người dùng
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng mời người dùng sẽ được phát triển tiếp theo')),
                    );
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
                        Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Mời người dùng',
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
                const SizedBox(height: 16),

                // 1. QR hộ gia đình
                HouseholdActionTile(
                  icon: const Icon(Icons.qr_code_2, color: AppColors.primary, size: 22),
                  title: 'QR hộ gia đình',
                  subtitle: 'Chia sẻ để người khác gửi yêu cầu',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng QR hộ gia đình sẽ được phát triển tiếp theo')),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 2. Lời mời đã gửi
                HouseholdActionTile(
                  icon: const Icon(Icons.send_outlined, color: AppColors.primary, size: 20),
                  title: 'Lời mời đã gửi',
                  subtitle: '${state.sentInvitationsCount} lời mời đang chờ • Xem và hủy',
                  onTap: () {
                    context.push('/family/invitations/sent');
                  },
                ),
                const SizedBox(height: 12),

                // 3. Yêu cầu tham gia
                HouseholdActionTile(
                  icon: const Icon(Icons.mail_outline, color: AppColors.primary, size: 22),
                  title: 'Yêu cầu tham gia',
                  subtitle: '${state.incomingJoinRequestsCount} yêu cầu mới • Chấp nhận hoặc từ chối',
                  onTap: () {
                    context.push('/family/join-requests');
                  },
                ),
                const SizedBox(height: 12),

                // 4. Quyền chủ hộ và xóa hộ
                HouseholdActionTile(
                  icon: const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 22),
                  title: 'Quyền chủ hộ và xóa hộ',
                  subtitle: 'Chuyển quyền trước khi rời hộ',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quản lý quyền chủ hộ và xóa hộ sẽ được phát triển tiếp theo')),
                    );
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
