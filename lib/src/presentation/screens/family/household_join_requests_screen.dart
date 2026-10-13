import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/household_join_request.dart';
import '../../blocs/household/household_cubit.dart';
import '../../blocs/household_join_requests/household_join_requests_cubit.dart';
import '../../blocs/household_join_requests/household_join_requests_state.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_confirm_dialog.dart';

class HouseholdJoinRequestsScreen extends StatefulWidget {
  const HouseholdJoinRequestsScreen({super.key});

  @override
  State<HouseholdJoinRequestsScreen> createState() => _HouseholdJoinRequestsScreenState();
}

class _HouseholdJoinRequestsScreenState extends State<HouseholdJoinRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HouseholdJoinRequestsCubit>().loadJoinRequests();
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
        label = 'Chờ duyệt';
        break;
      case 'approved':
        bgColor = AppColors.emerald50;
        textColor = AppColors.emerald900;
        label = 'Đã chấp nhận';
        break;
      case 'rejected':
        bgColor = AppColors.redSurface;
        textColor = AppColors.red900;
        label = 'Đã từ chối';
        break;
      case 'cancelled':
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

  void _showApproveDialog(
    BuildContext context,
    HouseholdJoinRequest request,
    String householdName,
    int memberCount,
  ) {
    final displayName = request.userFullName.isNotEmpty
        ? request.userFullName
        : 'người dùng';

    CustomConfirmDialog.show(
      context: context,
      title: 'Chấp nhận $displayName?',
      content: '$displayName hiện chưa có hộ và sẽ trở thành thành viên $householdName. Hộ sẽ có ${memberCount + 1} người.',
      cancelText: 'Hủy',
      confirmText: 'Chấp nhận tham gia',
      isDestructive: false,
      onConfirm: () {
        context.read<HouseholdJoinRequestsCubit>().approveRequest(request.id);
      },
    );
  }

  void _showRejectDialog(
    BuildContext context,
    HouseholdJoinRequest request,
    String householdName,
  ) {
    final displayName = request.userFullName.isNotEmpty
        ? request.userFullName
        : 'người dùng';

    CustomConfirmDialog.show(
      context: context,
      title: 'Từ chối yêu cầu của $displayName?',
      content: '$displayName sẽ nhận trạng thái từ chối và chưa được tham gia $householdName qua yêu cầu này.',
      cancelText: 'Hủy',
      confirmText: 'Từ chối yêu cầu',
      isDestructive: true,
      onConfirm: () {
        context.read<HouseholdJoinRequestsCubit>().rejectRequest(request.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final household = context.watch<HouseholdCubit>().state.household;
    final householdName = household?.name ?? 'Nhà Mầm xanh';
    final memberCount = household?.memberCount ?? 1;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: BlocConsumer<HouseholdJoinRequestsCubit, HouseholdJoinRequestsState>(
          listener: (context, state) {
            if (state is HouseholdJoinRequestsLoaded && state.actionMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage!)),
              );
            } else if (state is HouseholdJoinRequestsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            final pendingCount = state is HouseholdJoinRequestsLoaded
                ? state.requests.where((req) => req.isPending).length
                : 0;

            return Column(
              children: [
                CustomAppBar(
                  title: 'Yêu cầu tham gia',
                  subtitle: '$householdName • $pendingCount yêu cầu cần xem xét',
                  showBackButton: true,
                ),
                Expanded(
                  child: _buildBody(context, state, householdName, memberCount),
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
    HouseholdJoinRequestsState state,
    String householdName,
    int memberCount,
  ) {
    if (state is HouseholdJoinRequestsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is HouseholdJoinRequestsFailure) {
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
                onPressed: () => context.read<HouseholdJoinRequestsCubit>().loadJoinRequests(),
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

    final requests = state is HouseholdJoinRequestsLoaded ? state.requests : <HouseholdJoinRequest>[];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<HouseholdJoinRequestsCubit>().loadJoinRequests(),
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
                        'Chưa có yêu cầu nào',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hiện chưa có ai gửi yêu cầu tham gia\nvào hộ gia đình của bạn.',
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
                  final request = requests[index];
                  final displayName = request.userFullName.isNotEmpty
                      ? request.userFullName
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
                                  if (request.userId.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'ID: ${request.userId}',
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
                          'Gửi ngày ${_formatDate(request.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStatusBadge(request.status),
                        if (request.isPending) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showRejectDialog(
                                    context,
                                    request,
                                    householdName,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Từ chối',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textGreenMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showApproveDialog(
                                    context,
                                    request,
                                    householdName,
                                    memberCount,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Chấp nhận',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            // Card thông tin chỉ chủ hộ
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
                  Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Chỉ chủ hộ có thể chấp nhận hoặc từ chối yêu cầu vào hộ.',
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
            const SizedBox(height: 24),

            // Footer
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
