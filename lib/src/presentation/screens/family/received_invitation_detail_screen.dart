import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/household_invitation.dart';
import '../../blocs/household/household_cubit.dart';
import '../../blocs/received_invitations/received_invitations_cubit.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_confirm_dialog.dart';

class ReceivedInvitationDetailScreen extends StatefulWidget {
  final HouseholdInvitation invitation;

  const ReceivedInvitationDetailScreen({
    super.key,
    required this.invitation,
  });

  @override
  State<ReceivedInvitationDetailScreen> createState() => _ReceivedInvitationDetailScreenState();
}

class _ReceivedInvitationDetailScreenState extends State<ReceivedInvitationDetailScreen> {
  bool _isLoading = false;

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

  void _handleAccept() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _isLoading = true);
    final success = await context.read<ReceivedInvitationsCubit>().acceptInvitation(widget.invitation.id);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Bạn đã gia nhập ${widget.invitation.householdName} thành công!'),
          backgroundColor: AppColors.primary,
        ),
      );
      router.pop();
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Không thể chấp nhận lời mời. Vui lòng thử lại.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleReject() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _isLoading = true);
    final success = await context.read<ReceivedInvitationsCubit>().rejectInvitation(widget.invitation.id);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Đã từ chối lời mời tham gia.'),
        ),
      );
      router.pop();
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Không thể từ chối lời mời. Vui lòng thử lại.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showLeaveCurrentHouseholdDialog(String currentHouseholdName) {
    CustomConfirmDialog.show(
      context: context,
      title: 'Rời $currentHouseholdName?',
      content: 'Bạn cần rời khỏi hộ hiện tại để có thể tham gia ${widget.invitation.householdName}.',
      confirmText: 'Rời hộ hiện tại',
      onConfirm: () async {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final householdCubit = context.read<HouseholdCubit>();
        setState(() => _isLoading = true);
        final success = await householdCubit.leaveHousehold();
        if (!mounted) return;
        setState(() => _isLoading = false);

        if (success) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Đã rời khỏi $currentHouseholdName thành công')),
          );
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(householdCubit.state.errorMessage ?? 'Không thể rời hộ gia đình'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final householdState = context.watch<HouseholdCubit>().state;
    final currentHousehold = householdState.household;
    final inv = widget.invitation;

    final inviterDisplayName = inv.inviterName.isNotEmpty ? inv.inviterName : 'Chủ hộ';
    final initials = _getInitials(inviterDisplayName);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Lời mời tham gia',
              subtitle: '$inviterDisplayName mời bạn cùng sống xanh.',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card chi tiết lời mời (Ảnh 1 bên phải)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.greenSurfacePale,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.amber100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Chờ bạn phản hồi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.amber700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            inv.householdName.isNotEmpty ? inv.householdName : 'Hộ gia đình',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Box Chủ hộ
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
                                      inviterDisplayName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Chủ hộ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.subText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Đã mời ngày ${_formatDate(inv.createdAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.subText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hết hạn ngày ${_formatDate(inv.expiresAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.subText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nhắc nhở và các nút tương tác tùy theo người dùng đã có hộ hay chưa
                    if (currentHousehold == null) ...[
                      // Trường hợp: Chưa có hộ (Ảnh 1 bên phải)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.greenBorderSoft),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Bạn chưa có hộ nên có thể chấp nhận lời mời ngay. Sau khi chấp nhận, bạn sẽ là thành viên ${inv.householdName}.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGreenMedium,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nút Chấp nhận lời mời (Khả dụng)
                      InkWell(
                        onTap: _isLoading ? null : _handleAccept,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Chấp nhận lời mời',
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
                      ),
                      const SizedBox(height: 12),

                      // Nút Từ chối lời mời
                      InkWell(
                        onTap: _isLoading ? null : _handleReject,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'Từ chối lời mời',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textGreenMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Trường hợp: ĐÃ có hộ (Ảnh 3)
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
                                'Bạn đang là thành viên ${currentHousehold.name}. Chưa thể chấp nhận lời mời này. Hãy chủ động rời hộ hiện tại trước; ứng dụng không tự rời hộ cho bạn.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.brownText,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nút Chấp nhận lời mời (BỊ DISABLE)
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: AppColors.textMuted, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Chấp nhận lời mời',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nút Rời hộ hiện tại trước
                      InkWell(
                        onTap: _isLoading ? null : () => _showLeaveCurrentHouseholdDialog(currentHousehold.name),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'Rời hộ hiện tại trước',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textGreenMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nút Từ chối lời mời
                      InkWell(
                        onTap: _isLoading ? null : _handleReject,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'Từ chối lời mời',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textGreenMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Bạn chỉ thuộc một hộ gia đình tại một thời điểm.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
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
