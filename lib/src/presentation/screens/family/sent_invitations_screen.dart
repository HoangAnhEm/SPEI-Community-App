import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/household_invitation.dart';
import '../../blocs/household/household_cubit.dart';
import '../../blocs/sent_invitations/sent_invitations_cubit.dart';
import '../../blocs/sent_invitations/sent_invitations_state.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_confirm_dialog.dart';

class SentInvitationsScreen extends StatefulWidget {
  const SentInvitationsScreen({super.key});

  @override
  State<SentInvitationsScreen> createState() => _SentInvitationsScreenState();
}

class _SentInvitationsScreenState extends State<SentInvitationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SentInvitationsCubit>().loadSentInvitations();
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y • $h:$min';
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = AppColors.amber100;
        textColor = AppColors.amber700;
        label = 'Chờ phản hồi';
        break;
      case 'accepted':
        bgColor = AppColors.emerald50;
        textColor = AppColors.emerald900;
        label = 'Đã chấp nhận';
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

  void _showRevokeDialog(
    BuildContext context,
    HouseholdInvitation invitation,
    String householdName,
  ) {
    final displayName = invitation.inviteeName.isNotEmpty
        ? invitation.inviteeName
        : 'người dùng';

    CustomConfirmDialog.show(
      context: context,
      title: 'Hủy lời mời $displayName?',
      content: '$displayName sẽ không thể dùng lời mời này để tham gia $householdName. Bạn có thể mời lại sau.',
      cancelText: 'Hủy',
      confirmText: 'Hủy lời mời',
      isDestructive: true,
      onConfirm: () {
        context.read<SentInvitationsCubit>().revokeInvitation(invitation.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final household = context.watch<HouseholdCubit>().state.household;
    final householdName = household?.name ?? 'Nhà Mầm xanh';

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: BlocConsumer<SentInvitationsCubit, SentInvitationsState>(
          listener: (context, state) {
            if (state is SentInvitationsLoaded && state.actionMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage!)),
              );
            } else if (state is SentInvitationsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            final pendingCount = state is SentInvitationsLoaded
                ? state.invitations.where((inv) => inv.isPending).length
                : 0;

            return Column(
              children: [
                CustomAppBar(
                  title: 'Lời mời đã gửi',
                  subtitle: '$householdName • $pendingCount lời mời đang chờ',
                  showBackButton: true,
                ),
                Expanded(
                  child: _buildBody(context, state, householdName),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SentInvitationsState state,
    String householdName,
  ) {
    if (state is SentInvitationsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is SentInvitationsFailure) {
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
                onPressed: () => context.read<SentInvitationsCubit>().loadSentInvitations(),
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

    final invitations = state is SentInvitationsLoaded ? state.invitations : <HouseholdInvitation>[];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<SentInvitationsCubit>().loadSentInvitations(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        'Các lời mời bạn gửi đến người dùng khác\nsẽ hiển thị tại đây.',
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
                  final displayName = invitation.inviteeName.isNotEmpty
                      ? invitation.inviteeName
                      : 'Người dùng';
                  final initials = _getInitials(displayName);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.greenSurfaceSoft,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textGreenMedium,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  if (invitation.inviteeId.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'ID: ${invitation.inviteeId}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.subText,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Đã mời ${_formatDate(invitation.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStatusBadge(invitation.status),
                        if (invitation.isPending) ...[
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: () => _showRevokeDialog(
                              context,
                              invitation,
                              householdName,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Center(
                                child: Text(
                                  'Hủy lời mời',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textGreenMedium,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            // Card thông tin ghi chú
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.greenSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.greenBorderSoft),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Lời mời chỉ có hiệu lực khi người nhận chấp nhận. Bạn có thể hủy khi lời mời còn đang chờ.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGreenMedium,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nút Mời người dùng khác
            InkWell(
              onTap: () {
                context.push('/family/invite-user');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 50,
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
                      'Mời người dùng khác',
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
            const SizedBox(height: 24),

            // Footer
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
