import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/household_invitation.dart';
import '../../blocs/household/household_cubit.dart';
import '../../blocs/received_invitations/received_invitations_cubit.dart';
import '../../blocs/received_invitations/received_invitations_state.dart';
import '../../widgets/custom_app_bar.dart';

// Màu riêng của màn này
const Color _kGreenLightFBFDFB = Color(0xFFFBFDFB);

class ReceivedInvitationsScreen extends StatefulWidget {
  const ReceivedInvitationsScreen({super.key});

  @override
  State<ReceivedInvitationsScreen> createState() => _ReceivedInvitationsScreenState();
}

class _ReceivedInvitationsScreenState extends State<ReceivedInvitationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReceivedInvitationsCubit>().loadReceivedInvitations();
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y • $h:$min';
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = AppColors.amber100;
        textColor = AppColors.amber700;
        label = 'Lời mời đang chờ';
        break;
      case 'accepted':
        bgColor = AppColors.emerald50;
        textColor = AppColors.emerald900;
        label = 'Đã tham gia';
        break;
      case 'rejected':
        bgColor = AppColors.redSurface;
        textColor = AppColors.red900;
        label = 'Đã từ chối';
        break;
      case 'expired':
        bgColor = AppColors.gray100;
        textColor = AppColors.gray500;
        label = 'Hết hạn';
        break;
      case 'revoked':
        bgColor = AppColors.gray100;
        textColor = AppColors.gray500;
        label = 'Đã hủy';
        break;
      default:
        bgColor = AppColors.gray100;
        textColor = AppColors.gray500;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final householdState = context.watch<HouseholdCubit>().state;
    final currentHousehold = householdState.household;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: BlocConsumer<ReceivedInvitationsCubit, ReceivedInvitationsState>(
          listener: (context, state) {
            if (state is ReceivedInvitationsLoaded && state.actionMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage!)),
              );
            } else if (state is ReceivedInvitationsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            final count = state is ReceivedInvitationsLoaded
                ? state.invitations.length
                : 0;

            return Column(
              children: [
                CustomAppBar(
                  title: 'Lời mời nhận được',
                  subtitle: '$count lời mời từ các chủ hộ',
                  showBackButton: true,
                ),
                Expanded(
                  child: _buildBody(context, state, currentHousehold?.name),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReceivedInvitationsState state, String? currentHouseholdName) {
    if (state is ReceivedInvitationsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is ReceivedInvitationsFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                state.error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.subText),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<ReceivedInvitationsCubit>().loadReceivedInvitations(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final invitations = state is ReceivedInvitationsLoaded ? state.invitations : <HouseholdInvitation>[];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<ReceivedInvitationsCubit>().loadReceivedInvitations(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cảnh báo nếu người dùng đã có hộ gia đình (Ảnh 2)
            if (currentHouseholdName != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.amberSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.orange200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.amber600, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bạn đang ở $currentHouseholdName. Bạn có thể xem lời mời, nhưng cần rời hộ hiện tại trước khi chấp nhận.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.brownText,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (invitations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.greenSurfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inbox_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa có lời mời nào',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Các lời mời từ các chủ hộ khác sẽ hiển thị tại đây.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.subText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invitations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final invitation = invitations[index];
                  final householdTitle = invitation.householdName.isNotEmpty
                      ? invitation.householdName
                      : 'Hộ gia đình';
                  final inviter = invitation.inviterName.isNotEmpty
                      ? invitation.inviterName
                      : 'Chủ hộ';

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBadge(invitation.status),
                        const SizedBox(height: 10),
                        Text(
                          householdTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Chủ hộ $inviter mời bạn tham gia',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.subText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nhận ngày ${_formatDate(invitation.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hết hạn ngày ${_formatDate(invitation.expiresAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subText,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Action Box: Xem lời mời
                        InkWell(
                          onTap: () {
                            context.push(
                              '/family/invitations/received/detail',
                              extra: invitation,
                            ).then((_) {
                              if (context.mounted) {
                                context.read<ReceivedInvitationsCubit>().loadReceivedInvitations();
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: _kGreenLightFBFDFB,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.mail_outline, color: AppColors.primary, size: 22),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Xem lời mời',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Chấp nhận hoặc từ chối',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.subText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: AppColors.subText, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            // Card ghi chú cuối danh sách
            const Center(
              child: Text(
                'Chấp nhận một lời mời chỉ đưa bạn vào một hộ, không cho phép tham gia nhiều hộ cùng lúc.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.subText,
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
    );
  }
}
