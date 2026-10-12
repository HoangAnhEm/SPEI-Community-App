import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/media_service.dart';
import '../../../data/models/incident_model.dart';
import '../../../domain/entities/incident.dart';
import '../../blocs/incident/incident_cubit.dart';
import '../../blocs/incident/incident_state.dart';
import 'widgets/location_picker_sheet.dart';

/// Item lưu trữ minh chứng (có thể là tệp mới chọn từ máy hoặc URL đã lưu trước đó)
class EvidenceItem {
  final String? localPath;
  final String? networkUrl;
  final bool isVideo;
  final bool isExisting; // Đã lưu trước đó trên server (không cho xóa)

  const EvidenceItem({
    this.localPath,
    this.networkUrl,
    required this.isVideo,
    this.isExisting = false,
  });

  bool get isLocal => localPath != null;
}

/// Màn hình Tạo phản ánh mới (Ảnh 3) & Thêm minh chứng (Màn 4)
class CreateIncidentScreen extends StatefulWidget {
  final Incident? incidentToAppend;

  const CreateIncidentScreen({
    super.key,
    this.incidentToAppend,
  });

  @override
  State<CreateIncidentScreen> createState() => _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends State<CreateIncidentScreen> {
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  double _latitude = LocationService.defaultLat;
  double _longitude = LocationService.defaultLng;
  String _address = LocationService.defaultAddress;

  final List<EvidenceItem> _evidences = [];
  int _currentPreviewIndex = 0;

  bool get _isAddingEvidence => widget.incidentToAppend != null;

  @override
  void initState() {
    super.initState();
    final inc = widget.incidentToAppend;

    if (inc != null) {
      // Chế độ Thêm minh chứng
      _titleController = TextEditingController(text: inc.title);
      _descriptionController = TextEditingController(text: inc.description);
      _latitude = inc.latitude;
      _longitude = inc.longitude;
      _address = 'Đang tải địa chỉ...';

      // Nạp các bằng chứng cũ đã lưu
      for (final ev in inc.evidences) {
        _evidences.add(EvidenceItem(
          networkUrl: ev.fileUrl,
          isVideo: ev.isVideo,
          isExisting: true,
        ));
      }

      LocationService()
          .getAddressFromCoordinates(inc.latitude, inc.longitude)
          .then((addr) {
        if (mounted) setState(() => _address = addr);
      });
    } else {
      // Chế độ Tạo mới
      _titleController = TextEditingController(
          text: 'Rác thải không đúng nơi quy định');
      _descriptionController = TextEditingController(
          text:
              'Có túi rác và chai nhựa cạnh lối đi, gần khu vui chơi. Mong cộng đồng xem xét và hỗ trợ làm sạch.');

      // Lấy địa chỉ mặc định
      LocationService()
          .getAddressFromCoordinates(_latitude, _longitude)
          .then((addr) {
        if (mounted) setState(() => _address = addr);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Đếm số lượng ảnh và video hiện có
  int get _imageCount => _evidences.where((e) => !e.isVideo).length;
  int get _videoCount => _evidences.where((e) => e.isVideo).length;

  void _showMediaSourceDialog(bool isCamera) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCamera ? 'Chụp / Quay minh chứng' : 'Chọn từ thư viện',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2E1E),
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_camera_outlined,
                      color: Color(0xFF2E7D32)),
                ),
                title: Text(isCamera ? 'Chụp ảnh mới' : 'Chọn ảnh từ thư viện'),
                subtitle: Text('Đã có: $_imageCount/2 ảnh tối đa'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickMedia(
                    isVideo: false,
                    source:
                        isCamera ? ImageSource.camera : ImageSource.gallery,
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.videocam_outlined,
                      color: Color(0xFF2E7D32)),
                ),
                title: Text(isCamera ? 'Quay video mới' : 'Chọn video từ thư viện'),
                subtitle: Text('Đã có: $_videoCount/1 video tối đa'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickMedia(
                    isVideo: true,
                    source:
                        isCamera ? ImageSource.camera : ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickMedia({
    required bool isVideo,
    required ImageSource source,
  }) async {
    // 1. Kiểm tra giới hạn: Max 2 ảnh, 1 video
    if (isVideo && _videoCount >= 1) {
      _showWarningSnackBar('Bạn chỉ được đính kèm tối đa 1 video minh chứng.');
      return;
    }
    if (!isVideo && _imageCount >= 2) {
      _showWarningSnackBar('Bạn chỉ được đính kèm tối đa 2 ảnh minh chứng.');
      return;
    }

    try {
      // 2. Yêu cầu quyền Máy ảnh & Micro nếu chụp / quay trực tiếp
      if (source == ImageSource.camera) {
        final camStatus = await Permission.camera.request();
        if (!camStatus.isGranted) {
          _showWarningSnackBar('Vui lòng cấp quyền Máy ảnh để thực hiện chụp/quay.');
          return;
        }
        if (isVideo) {
          await Permission.microphone.request();
        }
      }

      if (isVideo) {
        final picked = await _picker.pickVideo(
          source: source,
        );
        if (picked != null) {
          setState(() {
            _evidences.add(EvidenceItem(
              localPath: picked.path,
              isVideo: true,
            ));
            _currentPreviewIndex = _evidences.length - 1;
          });
        }
      } else {
        final picked = await _picker.pickImage(
          source: source,
          imageQuality: 85,
        );
        if (picked != null) {
          setState(() {
            _evidences.add(EvidenceItem(
              localPath: picked.path,
              isVideo: false,
            ));
            _currentPreviewIndex = _evidences.length - 1;
          });
        }
      }
    } catch (e) {
      _showWarningSnackBar('Lỗi khi truy cập tệp hoặc máy ảnh: $e');
    }
  }

  void _removeEvidence(int index) {
    if (index < 0 || index >= _evidences.length) return;
    final item = _evidences[index];
    if (item.isExisting) {
      _showWarningSnackBar('Không thể xóa minh chứng đã gửi trước đó.');
      return;
    }

    setState(() {
      _evidences.removeAt(index);
      if (_currentPreviewIndex >= _evidences.length) {
        _currentPreviewIndex =
            _evidences.isNotEmpty ? _evidences.length - 1 : 0;
      }
    });
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFC53030),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleLocationPick() async {
    if (_isAddingEvidence) return; // Không cho phép đổi địa điểm khi thêm minh chứng

    final result = await LocationPickerSheet.show(
      context,
      initialLat: _latitude,
      initialLng: _longitude,
      initialAddress: _address,
    );

    if (result != null) {
      setState(() {
        _latitude = result.lat;
        _longitude = result.lng;
        _address = result.address;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (_isAddingEvidence) {
      // Chế độ Thêm minh chứng
      final newLocalFiles = _evidences
          .where((e) => e.isLocal && e.localPath != null)
          .map((e) => e.localPath!)
          .toList();

      if (newLocalFiles.isEmpty) {
        _showWarningSnackBar(
            'Vui lòng chọn ít nhất 1 ảnh hoặc video mới để bổ sung minh chứng.');
        return;
      }

      final inc = widget.incidentToAppend!;
      final success = await context.read<IncidentCubit>().addEvidence(
            incidentId: inc.id,
            filePaths: newLocalFiles,
          );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bổ sung minh chứng thành công!'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        final err = context.read<IncidentCubit>().state.submitErrorMessage;
        _showWarningSnackBar(err ?? 'Không thể gửi thêm minh chứng.');
      }
    } else {
      // Chế độ Tạo phản ánh mới
      if (_evidences.isEmpty) {
        _showWarningSnackBar(
            'Vui lòng đính kèm ít nhất 1 ảnh hoặc video minh chứng sự việc.');
        return;
      }
      if (title.length < 2) {
        _showWarningSnackBar('Tiêu đề phản ánh phải có ít nhất 2 ký tự.');
        return;
      }
      if (description.length < 5) {
        _showWarningSnackBar('Mô tả sự việc phải có ít nhất 5 ký tự.');
        return;
      }

      final filePaths = _evidences
          .where((e) => e.isLocal && e.localPath != null)
          .map((e) => e.localPath!)
          .toList();

      final request = CreateIncidentRequest(
        title: title,
        description: description,
        latitude: _latitude,
        longitude: _longitude,
        occurredAt: DateTime.now(),
        filePaths: filePaths,
      );

      final success =
          await context.read<IncidentCubit>().submitIncident(request);

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gửi phản ánh vi phạm thành công!'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        final err = context.read<IncidentCubit>().state.submitErrorMessage;
        _showWarningSnackBar(err ?? 'Không thể gửi phản ánh. Vui lòng thử lại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentCubit, IncidentState>(
      builder: (context, state) {
        final isSubmitting = state.isSubmitting;

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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isAddingEvidence
                                  ? 'Thêm minh chứng'
                                  : 'Gửi phản ánh',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2E1E),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isAddingEvidence
                                  ? 'Bổ sung ảnh / video cho phản ánh'
                                  : 'Cùng giữ khu phố xanh, sạch',
                              style: const TextStyle(
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

                // 2. Nội dung cuộn
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dòng mô tả hướng dẫn trên đầu
                        Text(
                          _isAddingEvidence
                              ? 'Bạn có thể tải thêm ảnh hoặc video mới để làm rõ sự việc vi phạm.'
                              : 'Ghi nhận vấn đề bạn quan sát được. Ban quản trị cộng đồng sẽ xem xét phản ánh của bạn.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Card: Ảnh sự việc (Minh chứng)
                        _buildEvidenceSection(),
                        const SizedBox(height: 18),

                        // Tiêu đề phản ánh
                        _buildDisabledWrapper(
                          isDisabled: _isAddingEvidence,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tiêu đề',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B2E1E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: TextField(
                                  controller: _titleController,
                                  enabled: !_isAddingEvidence,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    color: Color(0xFF1B2E1E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.description_outlined,
                                      color: Color(0xFF2E7D32),
                                      size: 20,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Địa điểm
                        _buildDisabledWrapper(
                          isDisabled: _isAddingEvidence,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Địa điểm',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B2E1E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _handleLocationPick,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: Color(0xFF2E7D32),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _address,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1B2E1E),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (!_isAddingEvidence)
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isAddingEvidence
                                    ? 'Địa điểm đã cố định theo phản ánh ban đầu.'
                                    : 'Địa điểm vi phạm • Bạn có thể chạm vào để chỉnh lại vị trí.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Mô tả sự việc
                        _buildDisabledWrapper(
                          isDisabled: _isAddingEvidence,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mô tả sự việc',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B2E1E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: TextField(
                                  controller: _descriptionController,
                                  enabled: !_isAddingEvidence,
                                  maxLines: 4,
                                  minLines: 3,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1B2E1E),
                                    height: 1.4,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                        'Mô tả chi tiết vi phạm, thời gian hoặc đặc điểm...',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nút hành động chính
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting ? null : _handleSubmit,
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : Icon(
                                    _isAddingEvidence
                                        ? Icons.cloud_upload_outlined
                                        : Icons.send_rounded,
                                    size: 18,
                                  ),
                            label: Text(
                              _isAddingEvidence
                                  ? 'Gửi thêm minh chứng'
                                  : 'Gửi phản ánh đến ban quản trị',
                              style: const TextStyle(
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
                        const SizedBox(height: 16),

                        // Ghi chú pháp lý / minh họa
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3ED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 18, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Không tự động chuyển đến cơ quan công quyền. Đây là kênh tiếp nhận và xử lý nội bộ của Ban quản trị cộng đồng.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Dòng chú thích minh họa ở chân trang
                        const Center(
                          child: Text(
                            'Bản mẫu giao diện • Dữ liệu minh họa',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildDisabledWrapper({
    required bool isDisabled,
    required Widget child,
  }) {
    if (!isDisabled) return child;
    return Opacity(
      opacity: 0.55,
      child: IgnorePointer(
        ignoring: true,
        child: child,
      ),
    );
  }

  Widget _buildEvidenceSection() {
    final count = _evidences.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Tiêu đề & Chỉ báo số lượng: 1/2, 2/3, 1/1 ...
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ảnh sự việc',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2E1E),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count > 0 ? '$count/3 minh chứng' : 'Tối đa 2 ảnh, 1 video',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Khung xem trước (Swipeable Carousel)
          if (_evidences.isEmpty)
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        size: 26,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Chưa có ảnh hoặc video minh chứng',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2E1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tối thiểu 1 ảnh/video, tối đa 2 ảnh 1 video',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  itemCount: _evidences.length,
                  onPageChanged: (i) =>
                      setState(() => _currentPreviewIndex = i),
                  itemBuilder: (context, index) {
                    final item = _evidences[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // Nếu là video thì hiển thị giao diện video phát được khi bấm
                        if (item.isVideo)
                          _buildVideoItem(item)
                        else if (item.isLocal)
                          Image.file(
                            File(item.localPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: const Color(0xFFE0E5DF),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else
                          Image.network(
                            item.networkUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: const Color(0xFFE0E5DF),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),

                        // Badge loại tệp góc trái trên: [Ảnh] hoặc [Video] hoặc [Đã lưu]
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.isExisting
                                  ? const Color(0xFF2E7D32).withValues(alpha: 0.9)
                                  : Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.isVideo
                                      ? Icons.videocam
                                      : Icons.image_outlined,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.isExisting
                                      ? 'Đã lưu'
                                      : (item.isVideo ? 'Video' : 'Ảnh'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Nút [X] xóa minh chứng ở góc phải trên (chỉ hiện cho tệp mới chọn)
                        if (!item.isExisting)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _removeEvidence(index),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.white,
                                  ),
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
            const SizedBox(height: 8),

            // Indicator dots dưới ảnh
            if (_evidences.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _evidences.length,
                  (idx) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPreviewIndex == idx ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPreviewIndex == idx
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 14),

          // 2 Nút hành động: [Chụp / quay] và [Thư viện]
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _showMediaSourceDialog(true),
                    icon: const Icon(Icons.camera_alt_outlined, size: 19),
                    label: const Text(
                      'Chụp / quay',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _showMediaSourceDialog(false),
                    icon: const Icon(Icons.photo_library_outlined, size: 19),
                    label: const Text(
                      'Thư viện',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F5E9),
                      foregroundColor: const Color(0xFF1E5128),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Dòng ghi chú nhỏ dưới nút
          Text(
            'Ảnh minh họa • Tránh chụp rõ mặt người hoặc thông tin riêng tư.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(EvidenceItem item) {
    String? fileName;
    String? fileSize;
    if (item.isLocal && item.localPath != null) {
      try {
        final file = File(item.localPath!);
        fileName = file.uri.pathSegments.last;
        final bytes = file.lengthSync();
        if (bytes < 1024 * 1024) {
          fileSize = '${(bytes / 1024).toStringAsFixed(1)} KB';
        } else {
          fileSize = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
      } catch (_) {}
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final path = item.localPath ?? item.networkUrl;
          if (path != null) {
            final success = await MediaService.openVideo(path);
            if (!success && mounted) {
              _showWarningSnackBar(
                  'Không thể mở video hoặc thiết bị chưa có trình phát video phù hợp.');
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF223726), Color(0xFF132016)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                right: -25,
                bottom: -25,
                child: Icon(
                  Icons.videocam_rounded,
                  size: 160,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nhấn để phát video minh chứng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (fileName != null || fileSize != null) ...[
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        [
                          ?fileName,
                          ?fileSize,
                        ].join(' • '),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
