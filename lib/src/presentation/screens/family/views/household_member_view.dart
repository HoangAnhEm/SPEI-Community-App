import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../blocs/household/household_cubit.dart';
import '../../../blocs/household/household_state.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_confirm_dialog.dart';
import '../widgets/household_action_tile.dart';
import '../widgets/household_info_card.dart';
import '../widgets/household_member_list_card.dart';

class HouseholdMemberView extends StatelessWidget {
  final HouseholdState state;

  const HouseholdMemberView({super.key, required this.state});

  void _showLeaveHouseholdDialog(BuildContext context, String householdName, String ownerName) {
    CustomConfirmDialog.show(
      context: context,
      title: 'Rời $householdName?',
      content: 'Bạn sẽ không còn là thành viên của hộ do $ownerName làm chủ hộ. Sau khi rời, bạn có thể tạo hộ hoặc tham gia một hộ khác.',
      confirmText: 'Rời hộ gia đình',
      onConfirm: () async {
        final success = await context.read<HouseholdCubit>().leaveHousehold();
        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bạn đã rời khỏi hộ gia đình thành công')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.read<HouseholdCubit>().state.errorMessage ?? 'Không thể rời hộ gia đình')),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final household = state.household!;
    final ownerName = household.owner?.fullName ?? '';

    return Column(
      children: [
        CustomAppBar(
          title: 'Gia đình của tôi',
          subtitle: 'Bạn đang là thành viên của ${household.name}.',
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
                  isOwner: false,
                ),
                const SizedBox(height: 20),

                // Danh sách thành viên
                HouseholdMemberListCard(
                  members: household.members,
                  currentUserId: state.currentUserId,
                ),
                const SizedBox(height: 20),

                // 1. Lời mời nhận được
                HouseholdActionTile(
                  icon: const Icon(Icons.mail_outline, color: AppColors.primary, size: 22),
                  title: 'Lời mời nhận được',
                  subtitle: '${state.receivedInvitationsCount} lời mời từ hộ khác',
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
                const SizedBox(height: 12),

                // 3. Tìm hộ bằng QR
                HouseholdActionTile(
                  icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 22),
                  title: 'Tìm hộ bằng QR',
                  subtitle: 'Có thể gửi yêu cầu cho hộ khác',
                  onTap: () {
                    context.push('/family/scan-qr');
                  },
                ),
                const SizedBox(height: 16),

                // Lưu ý màu vàng nhạt
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.amberSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppColors.brownText, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bạn có thể nhận lời mời và gửi yêu cầu đến hộ khác. Cần rời hộ hiện tại trước khi tham gia hộ mới.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.oliveText,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Nút Rời hộ gia đình
                HouseholdActionTile(
                  icon: const Icon(Icons.logout, color: AppColors.error, size: 22),
                  title: 'Rời ${household.name}',
                  isDestructive: true,
                  onTap: () => _showLeaveHouseholdDialog(context, household.name, ownerName),
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
