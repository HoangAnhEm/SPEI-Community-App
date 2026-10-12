import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/incident.dart';
import '../../blocs/incident/incident_cubit.dart';
import '../../blocs/incident/incident_state.dart';
import 'widgets/location_picker_sheet.dart';

/// Màn hình Chi tiết 1 Incident (Ảnh 2)
class IncidentDetailScreen extends StatefulWidget {
  final String incidentId;
  final Incident? initialIncident;

  const IncidentDetailScreen({
    super.key,
    required this.incidentId,
    this.initialIncident,
  });

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y • $h:$min';
  }

  String _resolvedAddress = 'Đang nhận diện địa chỉ...';
  bool _isLoadingAddress = true;
  int _currentEvidenceIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final incident = widget.initialIncident ??
          context.read<IncidentCubit>().state.selectedIncident;
      if (incident != null) {
        _resolveAddress(incident.latitude, incident.longitude);
      } else {
        context
            .read<IncidentCubit>()
            .loadIncidentDetail(widget.incidentId)
            .then((loaded) {
          if (loaded != null) {
            _resolveAddress(loaded.latitude, loaded.longitude);
          }
        });
      }
    });
  }

  Future<void> _resolveAddress(double lat, double lng) async {
    setState(() => _isLoadingAddress = true);
    final addr = await LocationService().getAddressFromCoordinates(lat, lng);
    if (!mounted) return;
    setState(() {
      _resolvedAddress = addr;
      _isLoadingAddress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentCubit, IncidentState>(
      builder: (context, state) {
        Incident? incident = widget.initialIncident;
        for (final item in state.incidents) {
          if (item.id == widget.incidentId) {
            incident = item;
            break;
          }
        }
        incident ??= state.selectedIncident;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAF7),
          body: SafeArea(
            child: Column(
              children: [
                // 1. Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chi tiết phản ánh',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2E1E),
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Chi tiết và trạng thái phản ánh',
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

                // 2. Nội dung chi tiết cuộn
                Expanded(
                  child: incident == null
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMainCard(context, incident),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                ),

                // 3. Nút "+ Thêm minh chứng" ở đáy
                if (incident != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push(
                            '/incidents/add-evidence',
                            extra: incident,
                          );
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'Thêm minh chứng',
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

                // 4. Chú thích chân trang
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
      },
    );
  }

  Widget _buildMainCard(BuildContext context, Incident incident) {
    final statusColors = _getStatusColors(incident.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: CHI TIẾT • Mã phản ánh + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHI TIẾT • ${incident.reportCode}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: statusColors.bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  incident.status.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tiêu đề phản ánh
          Text(
            incident.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E1E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          // Minh chứng Media (Ảnh / Video)
          _buildEvidenceMedia(context, incident),
          const SizedBox(height: 16),

          // Địa chỉ (click mở popup bản đồ)
          InkWell(
            onTap: () {
              LocationViewerSheet.show(
                context,
                lat: incident.latitude,
                lng: incident.longitude,
                address: _resolvedAddress,
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoadingAddress
                              ? 'Đang nhận diện địa chỉ...'
                              : _resolvedAddress,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2E1E),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Chạm để xem vị trí trên bản đồ',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.map_outlined,
                    size: 18,
                    color: Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nội dung mô tả sự việc
          Text(
            incident.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 18),

          // Tiến trình phản ánh
          const Text(
            'Tiến trình phản ánh',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E1E),
            ),
          ),
          const SizedBox(height: 16),
          _buildVerticalTimeline(incident),
          const SizedBox(height: 20),

          // Box ghi chú từ Ban quản trị (thay thế dòng disclaimer)
          _buildAdminNotesCard(incident),
        ],
      ),
    );
  }

  Widget _buildEvidenceMedia(BuildContext context, Incident incident) {
    if (incident.evidences.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_outlined, size: 40, color: Color(0xFFA5B8A8)),
              SizedBox(height: 6),
              Text(
                'Chưa có ảnh hoặc video đính kèm',
                style: TextStyle(fontSize: 13, color: Color(0xFF7A8C7D)),
              ),
            ],
          ),
        ),
      );
    }

    final evidences = incident.evidences;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: PageView.builder(
              itemCount: evidences.length,
              onPageChanged: (i) => setState(() => _currentEvidenceIndex = i),
              itemBuilder: (context, index) {
                final ev = evidences[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      ev.fileUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE5EAE4),
                        child: Center(
                          child: Icon(
                            ev.isVideo ? Icons.videocam : Icons.broken_image,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    if (ev.isVideo)
                      Center(
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${index + 1}/${evidences.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        if (evidences.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              evidences.length,
              (idx) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentEvidenceIndex == idx ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentEvidenceIndex == idx
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Timeline bám sát 3 bước model: pending -> investigating -> resolved (hoặc rejected)
  Widget _buildVerticalTimeline(Incident incident) {
    final isInvestigating = incident.status.isInvestigating;
    final isResolved = incident.status.isResolved;
    final isRejected = incident.status.isRejected;

    final createdTimeStr = _formatDateTime(incident.createdAt.toLocal());
    final nowTimeStr = _formatDate(DateTime.now());

    return Column(
      children: [
        // Bước 1: Đã tiếp nhận (pending)
        _buildTimelineStep(
          title: 'Đã tiếp nhận',
          timeSubtitle: createdTimeStr,
          statusNote: 'Phản ánh đã được ghi nhận trên hệ thống',
          state: TimelineState.completed,
          isFirst: true,
          isLast: false,
        ),

        // Bước 2: Đang xử lý (investigating)
        _buildTimelineStep(
          title: 'Đang xử lý',
          timeSubtitle: (isInvestigating || isResolved || isRejected)
              ? 'Ban quản trị đang phối hợp xác minh'
              : 'Chờ phân công xử lý',
          statusNote: (isInvestigating)
              ? 'Đang kiểm tra hiện trường và phối hợp khắc phục'
              : null,
          state: (isResolved || isRejected)
              ? TimelineState.completed
              : (isInvestigating ? TimelineState.inProgress : TimelineState.future),
          isFirst: false,
          isLast: false,
        ),

        // Bước 3: Hoàn tất (resolved) HOẶC Từ chối (rejected)
        if (isRejected)
          _buildTimelineStep(
            title: 'Từ chối giải quyết',
            timeSubtitle: nowTimeStr,
            statusNote: 'Phản ánh không hợp lệ hoặc không thuộc thẩm quyền',
            state: TimelineState.rejected,
            isFirst: false,
            isLast: true,
          )
        else
          _buildTimelineStep(
            title: isResolved ? 'Hoàn tất xử lý' : 'Hoàn tất',
            timeSubtitle: isResolved ? nowTimeStr : 'Chờ cập nhật kết quả',
            statusNote: isResolved
                ? 'Vấn đề vi phạm môi trường đã được xử lý xong'
                : null,
            state: isResolved ? TimelineState.completed : TimelineState.future,
            isFirst: false,
            isLast: true,
          ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String timeSubtitle,
    String? statusNote,
    required TimelineState state,
    required bool isFirst,
    required bool isLast,
  }) {
    Color dotColor;
    Color lineColor;

    switch (state) {
      case TimelineState.completed:
        dotColor = const Color(0xFF2E7D32);
        lineColor = const Color(0xFF2E7D32);
        break;
      case TimelineState.inProgress:
        dotColor = const Color(0xFFB45309);
        lineColor = Colors.grey.shade300;
        break;
      case TimelineState.rejected:
        dotColor = const Color(0xFFC53030);
        lineColor = const Color(0xFFC53030);
        break;
      case TimelineState.future:
        dotColor = const Color(0xFFD1D5DB);
        lineColor = Colors.grey.shade300;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột timeline dot & line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      if (state == TimelineState.inProgress)
                        BoxShadow(
                          color: dotColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Cột thông tin bước
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: state == TimelineState.future
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF1B2E1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeSubtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (statusNote != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      statusNote,
                      style: TextStyle(
                        fontSize: 12,
                        color: dotColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Khung ghi chú phản hồi từ Ban quản trị
  Widget _buildAdminNotesCard(Incident incident) {
    final notes = incident.adminNotes?.trim();
    final hasNotes = notes != null && notes.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasNotes ? const Color(0xFFF3F7F2) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasNotes ? const Color(0xFFD6EADB) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasNotes ? Icons.rate_review_outlined : Icons.info_outline,
            size: 20,
            color: hasNotes ? const Color(0xFF2E7D32) : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasNotes
                      ? 'Ý kiến xử lý từ Ban quản trị'
                      : 'Thông tin theo dõi phản ánh',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: hasNotes
                        ? const Color(0xFF1E5128)
                        : const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasNotes
                      ? notes
                      : 'Phản ánh của bạn đã được ghi nhận trên hệ thống. Mọi cập nhật giải quyết và ý kiến phản hồi sẽ được hiển thị tại đây.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: hasNotes
                        ? const Color(0xFF2D4B32)
                        : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ({Color bg, Color text}) _getStatusColors(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.pending:
        return (
          bg: const Color(0xFFE8F1FD),
          text: const Color(0xFF1E60AA),
        );
      case IncidentStatus.investigating:
        return (
          bg: const Color(0xFFFEF3E2),
          text: const Color(0xFFB45309),
        );
      case IncidentStatus.resolved:
        return (
          bg: const Color(0xFFEBF5EE),
          text: const Color(0xFF2E7D32),
        );
      case IncidentStatus.rejected:
        return (
          bg: const Color(0xFFFDE8E8),
          text: const Color(0xFFC53030),
        );
    }
  }
}

enum TimelineState { completed, inProgress, future, rejected }
