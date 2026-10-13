import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/household_join_request.dart';
import '../../blocs/household/household_cubit.dart';
import '../../blocs/my_join_requests/my_join_requests_cubit.dart';
import '../../blocs/my_join_requests/my_join_requests_state.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_confirm_dialog.dart';

class MyJoinRequestsScreen extends StatefulWidget {
  const MyJoinRequestsScreen({super.key});

  @override
  State<MyJoinRequestsScreen> createState() => _MyJoinRequestsScreenState();
}

class _MyJoinRequestsScreenState extends State<MyJoinRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MyJoinRequestsCubit>().loadMyJoinRequests();
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
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
        label = 'Đang chờ duyệt';
        break;
      case 'approved':
        bgColor = const Color(0xFFDEF7EC);
        textColor = const Color(0xFF03543F);
        label = 'Đã được chấp nhận';
        break;
      case 'rejected':
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFC2410C);
        label = 'Đã bị từ chối';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        label = 'Đã hủy';
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
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

  void _showCancelDialog(BuildContext context, HouseholdJoinRequest request) {
    CustomConfirmDialog.show(
      context: context,
      title: 'Hủy yêu cầu tham gia?',
      content: 'Chủ hộ ${request.householdName} sẽ không còn thấy yêu cầu gia nhập này của bạn.',
      cancelText: 'Quay lại',
      confirmText: 'Hủy yêu cầu',
      isDestructive: true,
      onConfirm: () {
        context.read<MyJoinRequestsCubit>().cancelRequest(request.id);
      },
    );
  }

  void _showLeaveCurrentHouseholdDialog(String currentHouseholdName, String targetHouseholdName) {
    CustomConfirmDialog.show(
      context: context,
      title: 'Rời $currentHouseholdName?',
      content: 'Yêu cầu gia nhập $targetHouseholdName đã được chấp nhận. Bạn cần rời khỏi hộ hiện tại để chuyển sang hộ mới.',
      confirmText: 'Rời hộ hiện tại',
      onConfirm: () async {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final householdCubit = context.read<HouseholdCubit>();
        final success = await householdCubit.leaveHousehold();
        if (!mounted) return;
        if (success) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Đã rời khỏi $currentHouseholdName thành công')),
          );
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(householdCubit.state.errorMessage ?? 'Không thể rời hộ gia đình'),
              backgroundColor: const Color(0xFFC94A4A),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      body: SafeArea(
        child: BlocConsumer<MyJoinRequestsCubit, MyJoinRequestsState>(
          listener: (context, state) {
            if (state is MyJoinRequestsLoaded && state.actionMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage!)),
              );
            } else if (state is MyJoinRequestsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            final count = state is MyJoinRequestsLoaded ? state.requests.length : 0;

            return Column(
              children: [
                CustomAppBar(
                  title: 'Yêu cầu đã gửi',
                  subtitle: '$count yêu cầu • Theo dõi phản hồi từ chủ hộ',
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

  Widget _buildBody(BuildContext context, MyJoinRequestsState state, String? currentHouseholdName) {
    if (state is MyJoinRequestsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is MyJoinRequestsFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFC94A4A)),
              const SizedBox(height: 12),
              Text(
                state.error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.subText),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<MyJoinRequestsCubit>().loadMyJoinRequests(),
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

    final requests = state is MyJoinRequestsLoaded ? state.requests : <HouseholdJoinRequest>[];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<MyJoinRequestsCubit>().loadMyJoinRequests(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (requests.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0F5F2),
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
                        'Chưa có yêu cầu nào',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Các yêu cầu tham gia bạn gửi đến các hộ gia đình\nsẽ được hiển thị tại đây.',
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
                itemCount: requests.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final req = requests[index];
                  final householdTitle = req.householdName.isNotEmpty
                      ? req.householdName
                      : 'Hộ gia đình';

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8ECE5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBadge(req.status),
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
                          req.status == 'pending'
                              ? 'Gửi ngày ${_formatDate(req.createdAt)}'
                              : 'Gửi ngày ${_formatDate(req.createdAt)} • Cập nhật ${_formatDate(req.updatedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subText,
                          ),
                        ),

                        // Action theo từng trạng thái (Ảnh 4)
                        if (req.isPending) ...[
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: () => _showCancelDialog(context, req),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8DE)),
                              ),
                              child: const Center(
                                child: Text(
                                  'Hủy yêu cầu',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D4F3C),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else if (req.isRejected) ...[
                          const SizedBox(height: 10),
                          const Text(
                            'Yêu cầu chưa được chấp nhận. Bạn có thể tìm một hộ khác.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.subText,
                              height: 1.4,
                            ),
                          ),
                        ] else if (req.isApproved) ...[
                          // Nếu người dùng ĐÃ có hộ: hiển thị nhắc nhở và nút Rời hộ hiện tại trước
                          // Nếu người dùng CHƯA có hộ: không hiển thị nhắc nhở và nút này (theo yêu cầu 2)
                          if (currentHouseholdName != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF6E8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Bạn vẫn ở $currentHouseholdName. Yêu cầu đã duyệt nhưng bạn chưa gia nhập $householdTitle. Cần rời hộ cũ trước.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8A6D3B),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _showLeaveCurrentHouseholdDialog(currentHouseholdName, householdTitle),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: double.infinity,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8DE)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Rời hộ hiện tại trước',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D4F3C),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            // Nút: Tìm hộ bằng QR (Ảnh 4 cả 2 màn)
            InkWell(
              onTap: () {
                context.push('/family/scan-qr');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8DE)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.crop_free, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tìm hộ bằng QR',
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

            // Footer
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
