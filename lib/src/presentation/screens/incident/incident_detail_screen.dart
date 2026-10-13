import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/incident.dart';
import '../../blocs/incident/incident_cubit.dart';
import '../../blocs/incident/incident_state.dart';
import '../../widgets/custom_app_bar.dart';
import 'widgets/app_video_player.dart';
import 'widgets/location_picker_sheet.dart';

// Màu riêng của màn này
const Color _kGreenDark2D4B32 = Color(0xFF2D4B32);
const Color _kGreenLightE5EAE4 = Color(0xFFE5EAE4);
const Color _kGreenLightF3F7F2 = Color(0xFFF3F7F2);
const Color _kGreenLightF5F7F3 = Color(0xFFF5F7F3);
const Color _kGrey7A8C7D = Color(0xFF7A8C7D);
const Color _kGreyA5B8A8 = Color(0xFFA5B8A8);

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
          backgroundColor: AppColors.surfaceLight,
          body: SafeArea(
            child: Column(
              children: [
                // 1. Header
                CustomAppBar(
                  title: 'Chi tiết phản ánh',
                  subtitle: 'Chi tiết và trạng thái phản ánh',
                  showBackButton: true,
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
                  color: AppColors.gray500,
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
              color: AppColors.textPrimary,
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
                      color: AppColors.greenPrimary,
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
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Chạm để xem vị trí trên bản đồ',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.greenPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.map_outlined,
                    size: 18,
                    color: AppColors.greenPrimary,
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
              color: AppColors.gray700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.neutral100),
          const SizedBox(height: 18),

          // Tiến trình phản ánh
          const Text(
            'Tiến trình phản ánh',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
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
          color: _kGreenLightF5F7F3,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_outlined, size: 40, color: _kGreyA5B8A8),
              SizedBox(height: 6),
              Text(
                'Chưa có ảnh hoặc video đính kèm',
                style: TextStyle(fontSize: 13, color: _kGrey7A8C7D),
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
                if (ev.isVideo) {
                  return AppVideoPlayer(
                    networkUrl: ev.fileUrl,
                    badgeLabel: 'Video',
                  );
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      ev.fileUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: _kGreenLightE5EAE4,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
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

  /// Timeline bám sát 5 bước vòng đời Backend (hoặc bước từ chối)
  Widget _buildVerticalTimeline(Incident incident) {
    final createdTimeStr = _formatDateTime(incident.createdAt.toLocal());
    final currentStep = incident.step; // 1..5 hoặc -1 nếu rejected
    final isRejected = incident.status.isRejected;
    final isClosed = incident.status.isClosed;

    // Định nghĩa 5 mốc tiến trình chuẩn của hệ thống
    final stepDefs = [
      (
        step: 1,
        title: 'Đã gửi',
        desc: 'Phản ánh đã được ghi nhận trên hệ thống',
        time: createdTimeStr,
      ),
      (
        step: 2,
        title: 'Đang kiểm tra',
        desc: currentStep >= 2
            ? 'Ban quản trị tiếp nhận và xác thực thông tin'
            : 'Chờ kiểm tra thông tin',
        time: null,
      ),
      (
        step: 3,
        title: 'Đã chuyển cơ quan chức năng',
        desc: currentStep >= 3
            ? 'Hồ sơ đã được chuyển tiếp đến cơ quan có thẩm quyền'
            : 'Chờ chuyển tiếp hồ sơ',
        time: null,
      ),
      (
        step: 4,
        title: 'Đang xử lý',
        desc: currentStep >= 4
            ? 'Cơ quan chức năng đang xử lý tại hiện trường'
            : 'Chờ tiến hành xử lý',
        time: null,
      ),
      (
        step: 5,
        title: isClosed ? 'Đóng hồ sơ' : 'Đã giải quyết',
        desc: currentStep >= 5
            ? (incident.adminNotes ?? 'Vấn đề vi phạm môi trường đã được giải quyết')
            : 'Chờ kết quả giải quyết',
        time: null,
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < stepDefs.length; i++) ...[
          () {
            final def = stepDefs[i];
            TimelineState stepState;
            if (isRejected) {
              stepState = def.step == 1
                  ? TimelineState.completed
                  : TimelineState.future;
            } else if (def.step < currentStep) {
              stepState = TimelineState.completed;
            } else if (def.step == currentStep) {
              stepState = TimelineState.inProgress;
            } else {
              stepState = TimelineState.future;
            }

            return _buildTimelineStep(
              title: def.title,
              timeSubtitle: def.desc,
              statusNote: def.time,
              state: stepState,
              isFirst: i == 0,
              isLast: i == stepDefs.length - 1 && !isRejected,
            );
          }(),
        ],
        if (isRejected)
          _buildTimelineStep(
            title: 'Từ chối giải quyết',
            timeSubtitle: incident.adminNotes ??
                'Phản ánh không hợp lệ hoặc không thuộc thẩm quyền xử lý',
            statusNote: 'Hồ sơ đã bị từ chối',
            state: TimelineState.rejected,
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
        dotColor = AppColors.greenPrimary;
        lineColor = AppColors.greenPrimary;
        break;
      case TimelineState.inProgress:
        dotColor = AppColors.amber700;
        lineColor = Colors.grey.shade300;
        break;
      case TimelineState.rejected:
        dotColor = AppColors.redDark;
        lineColor = AppColors.redDark;
        break;
      case TimelineState.future:
        dotColor = AppColors.gray300;
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
                          ? AppColors.gray400
                          : AppColors.textPrimary,
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
        color: hasNotes ? _kGreenLightF3F7F2 : AppColors.neutral10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasNotes ? AppColors.greenBorder : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasNotes ? Icons.rate_review_outlined : Icons.info_outline,
            size: 20,
            color: hasNotes ? AppColors.greenPrimary : AppColors.gray500,
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
                        ? AppColors.greenDark
                        : AppColors.gray700,
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
                        ? _kGreenDark2D4B32
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

enum TimelineState { completed, inProgress, future, rejected }
