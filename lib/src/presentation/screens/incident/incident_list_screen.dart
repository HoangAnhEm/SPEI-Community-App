import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/incident.dart';
import '../../blocs/incident/incident_cubit.dart';
import '../../blocs/incident/incident_state.dart';

// Màu riêng của màn này
const Color _kGreen8BA58D = Color(0xFF8BA58D);
const Color _kGreenLightF0F2ED = Color(0xFFF0F2ED);

/// Màn hình Danh sách phản ánh của nhà (Ảnh 1)
class IncidentListScreen extends StatefulWidget {
  final bool showBackButton;

  const IncidentListScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {
  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<IncidentCubit>();
      if (cubit.state.status == IncidentListStatus.initial) {
        cubit.loadMyIncidents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  if (widget.showBackButton) ...[
                    InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.go('/');
                        }
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.greenDark,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phản ánh của nhà',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Cập nhật từ ban quản trị cộng đồng',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/circle_center_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/icons/logo.png',
                                fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Tab lọc theo trạng thái
            BlocBuilder<IncidentCubit, IncidentState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      _buildFilterPill(
                        context,
                        label: 'Tất cả (${state.countAll})',
                        filterKey: 'all',
                        isSelected: state.selectedFilter == 'all',
                        activeColor: AppColors.green50,
                        textColor: AppColors.greenPrimary,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context,
                        label: 'Đã gửi (${state.countSubmitted})',
                        filterKey: IncidentStatus.submitted.value,
                        isSelected: state.selectedFilter ==
                            IncidentStatus.submitted.value,
                        activeColor: AppColors.blueSurfaceLight,
                        textColor: AppColors.blueStatus,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context,
                        label: 'Đang kiểm tra (${state.countUnderReview})',
                        filterKey: IncidentStatus.underReview.value,
                        isSelected: state.selectedFilter ==
                            IncidentStatus.underReview.value,
                        activeColor: AppColors.orangeSurface,
                        textColor: AppColors.amber700,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context,
                        label: 'Đã chuyển CQCN (${state.countForwarded})',
                        filterKey: IncidentStatus.forwarded.value,
                        isSelected: state.selectedFilter ==
                            IncidentStatus.forwarded.value,
                        activeColor: AppColors.purple100,
                        textColor: AppColors.purple700,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context,
                        label: 'Đang xử lý (${state.countInProgress})',
                        filterKey: IncidentStatus.inProgress.value,
                        isSelected: state.selectedFilter ==
                            IncidentStatus.inProgress.value,
                        activeColor: AppColors.sky100,
                        textColor: AppColors.sky700,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context,
                        label: 'Đã giải quyết (${state.countResolved})',
                        filterKey: IncidentStatus.resolved.value,
                        isSelected: state.selectedFilter ==
                            IncidentStatus.resolved.value,
                        activeColor: AppColors.greenSurface,
                        textColor: AppColors.greenPrimary,
                      ),
                      if (state.countClosed > 0) ...[
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          context,
                          label: 'Đóng hồ sơ (${state.countClosed})',
                          filterKey: IncidentStatus.closed.value,
                          isSelected: state.selectedFilter ==
                              IncidentStatus.closed.value,
                          activeColor: AppColors.slate100,
                          textColor: AppColors.slate600,
                        ),
                      ],
                      if (state.countRejected > 0) ...[
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          context,
                          label: 'Từ chối (${state.countRejected})',
                          filterKey: IncidentStatus.rejected.value,
                          isSelected: state.selectedFilter ==
                              IncidentStatus.rejected.value,
                          activeColor: AppColors.redSurface,
                          textColor: AppColors.redDark,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            // 3. Danh sách phản ánh
            Expanded(
              child: BlocBuilder<IncidentCubit, IncidentState>(
                builder: (context, state) {
                  if (state.status == IncidentListStatus.loading &&
                      state.incidents.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state.status == IncidentListStatus.error &&
                      state.incidents.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              state.errorMessage ??
                                  'Không thể tải danh sách phản ánh',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.gray500, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<IncidentCubit>()
                                  .loadMyIncidents(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list = state.filteredIncidents;

                  if (list.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () =>
                          context.read<IncidentCubit>().loadMyIncidents(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 48),
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSage,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.assignment_outlined,
                                    size: 40,
                                    color: _kGreen8BA58D,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Chưa có phản ánh nào',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  state.selectedFilter == 'all'
                                      ? 'Bạn chưa gửi phản ánh vi phạm môi trường nào.'
                                      : 'Không có phản ánh nào ở trạng thái này.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        context.read<IncidentCubit>().loadMyIncidents(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: list.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return _buildIncidentCard(context, item);
                      },
                    ),
                  );
                },
              ),
            ),

            // 4. Nút "+ Gửi phản ánh mới" cố định ở đáy
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/incidents/create');
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Gửi phản ánh mới',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            // 5. Chú thích chân trang
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(
    BuildContext context, {
    required String label,
    required String filterKey,
    required bool isSelected,
    required Color activeColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: () {
        context.read<IncidentCubit>().setFilter(filterKey);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : _kGreenLightF0F2ED,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? textColor.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? textColor : AppColors.gray600,
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentCard(BuildContext context, Incident item) {
    final statusColorData = _getStatusColors(item.status);

    return InkWell(
      onTap: () {
        context.read<IncidentCubit>().selectIncident(item);
        context.push('/incidents/${item.id}', extra: item);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColorData.bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item.status.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColorData.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Mã phản ánh & Ngày ghi nhận
            Row(
              children: [
                Text(
                  item.reportCode,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                  ),
                ),
                const Text(
                  ' • ',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.gray400,
                  ),
                ),
                Text(
                  _formatDate(item.occurredAt.toLocal()),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: AppColors.gray400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ({Color bg, Color text}) _getStatusColors(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.submitted:
        return (
          bg: AppColors.blueSurfaceLight,
          text: AppColors.blueStatus,
        );
      case IncidentStatus.underReview:
        return (
          bg: AppColors.orangeSurface,
          text: AppColors.amber700,
        );
      case IncidentStatus.forwarded:
        return (
          bg: AppColors.purple100,
          text: AppColors.purple700,
        );
      case IncidentStatus.inProgress:
        return (
          bg: AppColors.sky100,
          text: AppColors.sky700,
        );
      case IncidentStatus.resolved:
        return (
          bg: AppColors.greenSurface,
          text: AppColors.greenPrimary,
        );
      case IncidentStatus.closed:
        return (
          bg: AppColors.slate100,
          text: AppColors.slate600,
        );
      case IncidentStatus.rejected:
        return (
          bg: AppColors.redSurface,
          text: AppColors.redDark,
        );
    }
  }
}
