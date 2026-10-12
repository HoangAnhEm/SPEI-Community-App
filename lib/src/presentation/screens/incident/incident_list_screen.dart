import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/incident.dart';
import '../../blocs/incident/incident_cubit.dart';
import '../../blocs/incident/incident_state.dart';

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
      backgroundColor: const Color(0xFFF9FAF7),
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
                          color: Color(0xFF1E5128),
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
                            color: Color(0xFF1B2E1E),
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Cập nhật từ ban quản trị cộng đồng',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF6B7280),
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
                        activeColor: const Color(0xFFE8F5E9),
                        textColor: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context,
                        label: 'Đã gửi (${state.countSubmitted})',
                        filterKey: IncidentStatus.submitted.value,
                        isSelected: state.selectedFilter ==
                            IncidentStatus.submitted.value,
                        activeColor: const Color(0xFFE8F1FD),
                        textColor: const Color(0xFF1E60AA),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context,
                        label: 'Đang kiểm tra (${state.countUnderReview})',
                        filterKey: IncidentStatus.underReview.value,
                        isSelected: state.selectedFilter ==
                            IncidentStatus.underReview.value,
                        activeColor: const Color(0xFFFEF3E2),
                        textColor: const Color(0xFFB45309),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context,
                        label: 'Đã chuyển CQCN (${state.countForwarded})',
                        filterKey: IncidentStatus.forwarded.value,
                        isSelected: state.selectedFilter ==
                            IncidentStatus.forwarded.value,
                        activeColor: const Color(0xFFF3E8FF),
                        textColor: const Color(0xFF7E22CE),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context,
                        label: 'Đang xử lý (${state.countInProgress})',
                        filterKey: IncidentStatus.inProgress.value,
                        isSelected: state.selectedFilter ==
                            IncidentStatus.inProgress.value,
                        activeColor: const Color(0xFFE0F2FE),
                        textColor: const Color(0xFF0369A1),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        context,
                        label: 'Đã giải quyết (${state.countResolved})',
                        filterKey: IncidentStatus.resolved.value,
                        isSelected: state.selectedFilter ==
                            IncidentStatus.resolved.value,
                        activeColor: const Color(0xFFEBF5EE),
                        textColor: const Color(0xFF2E7D32),
                      ),
                      if (state.countClosed > 0) ...[
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          context,
                          label: 'Đóng hồ sơ (${state.countClosed})',
                          filterKey: IncidentStatus.closed.value,
                          isSelected: state.selectedFilter ==
                              IncidentStatus.closed.value,
                          activeColor: const Color(0xFFF1F5F9),
                          textColor: const Color(0xFF475569),
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
                          activeColor: const Color(0xFFFDE8E8),
                          textColor: const Color(0xFFC53030),
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
                                  color: Color(0xFF6B7280), fontSize: 14),
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
                                    color: const Color(0xFFF1F5F0),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.assignment_outlined,
                                    size: 40,
                                    color: Color(0xFF8BA58D),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Chưa có phản ánh nào',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B2E1E),
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
                                    color: Color(0xFF6B7280),
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
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Bản mẫu giao diện • Dữ liệu minh họa',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
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
          color: isSelected ? activeColor : const Color(0xFFF0F2ED),
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
            color: isSelected ? textColor : const Color(0xFF4B5563),
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
                      color: Color(0xFF1B2E1E),
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
                    color: Color(0xFF6B7280),
                  ),
                ),
                const Text(
                  ' • ',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  _formatDate(item.occurredAt.toLocal()),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: Color(0xFF9CA3AF),
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
          bg: const Color(0xFFE8F1FD),
          text: const Color(0xFF1E60AA),
        );
      case IncidentStatus.underReview:
        return (
          bg: const Color(0xFFFEF3E2),
          text: const Color(0xFFB45309),
        );
      case IncidentStatus.forwarded:
        return (
          bg: const Color(0xFFF3E8FF),
          text: const Color(0xFF7E22CE),
        );
      case IncidentStatus.inProgress:
        return (
          bg: const Color(0xFFE0F2FE),
          text: const Color(0xFF0369A1),
        );
      case IncidentStatus.resolved:
        return (
          bg: const Color(0xFFEBF5EE),
          text: const Color(0xFF2E7D32),
        );
      case IncidentStatus.closed:
        return (
          bg: const Color(0xFFF1F5F9),
          text: const Color(0xFF475569),
        );
      case IncidentStatus.rejected:
        return (
          bg: const Color(0xFFFDE8E8),
          text: const Color(0xFFC53030),
        );
    }
  }
}
