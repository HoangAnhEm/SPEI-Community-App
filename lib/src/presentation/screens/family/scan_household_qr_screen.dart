import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class ScanHouseholdQrScreen extends StatefulWidget {
  const ScanHouseholdQrScreen({super.key});

  @override
  State<ScanHouseholdQrScreen> createState() => _ScanHouseholdQrScreenState();
}

class _ScanHouseholdQrScreenState extends State<ScanHouseholdQrScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final TextEditingController _idInputController = TextEditingController();

  bool _hasScanned = false;
  bool _isAnalyzingImage = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    _idInputController.dispose();
    super.dispose();
  }

  void _onQrDetected(String rawCode) {
    if (_hasScanned) return;
    final trimmed = rawCode.trim();
    if (trimmed.isEmpty) return;

    _hasScanned = true;
    context.push('/family/lookup-result', extra: trimmed).then((_) {
      // Khi quay lại từ màn kết quả, cho phép quét tiếp
      if (mounted) {
        setState(() {
          _hasScanned = false;
        });
      }
    });
  }

  Future<void> _pickImageFromGallery() async {
    if (_isAnalyzingImage) return;

    setState(() {
      _isAnalyzingImage = true;
    });

    try {
      // Yêu cầu quyền truy cập thư viện ảnh nếu cần
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          final photoStatus = await Permission.photos.request();
          if (photoStatus.isPermanentlyDenied) {
            _showPermissionSettingsDialog('Quyền truy cập ảnh', 'Vui lòng cấp quyền truy cập thư viện ảnh trong Cài đặt để chọn ảnh mã QR.');
            return;
          }
        } else {
          final storageStatus = await Permission.storage.request();
          if (storageStatus.isPermanentlyDenied) {
            _showPermissionSettingsDialog('Quyền truy cập bộ nhớ', 'Vui lòng cấp quyền truy cập bộ nhớ trong Cài đặt để chọn ảnh mã QR.');
            return;
          }
        }
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final photoStatus = await Permission.photos.request();
        if (photoStatus.isPermanentlyDenied) {
          _showPermissionSettingsDialog('Quyền truy cập ảnh', 'Vui lòng cấp quyền truy cập thư viện ảnh trong Cài đặt để chọn ảnh mã QR.');
          return;
        }
      }

      // Mở thư viện ảnh thật bằng ImagePicker
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        // Người dùng đã hủy chọn ảnh
        return;
      }

      // Phân tích mã QR từ ảnh đã chọn
      final BarcodeCapture? barcodes = await _scannerController.analyzeImage(pickedFile.path);

      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
        final code = barcodes.barcodes.first.rawValue;
        if (code != null && code.trim().isNotEmpty) {
          _onQrDetected(code.trim());
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy mã QR trong ảnh đã chọn. Vui lòng chọn ảnh khác hoặc nhập ID.'),
            backgroundColor: Color(0xFFC94A4A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đọc ảnh: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: const Color(0xFFC94A4A),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzingImage = false;
        });
      }
    }
  }

  void _showPermissionSettingsDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Mở cài đặt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _idInputController.text = data.text!.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Quét mã hộ gia đình',
              subtitle: 'Đưa QR của hộ vào khung để xem thông tin trước khi gửi yêu cầu.',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Khung quét Camera thật bằng MobileScanner (Ảnh 1)
                    Container(
                      width: double.infinity,
                      height: 380,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Camera Live Stream Scanner
                            MobileScanner(
                              controller: _scannerController,
                              onDetect: (capture) {
                                final List<Barcode> barcodes = capture.barcodes;
                                for (final barcode in barcodes) {
                                  final code = barcode.rawValue;
                                  if (code != null && code.trim().isNotEmpty) {
                                    _onQrDetected(code.trim());
                                    break;
                                  }
                                }
                              },
                              errorBuilder: (context, error, child) {
                                return Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: const Color(0xFF1E2822),
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.videocam_off_outlined,
                                        size: 52,
                                        color: Color(0xFFF39C12),
                                      ),
                                      const SizedBox(height: 14),
                                      const Text(
                                        'Không có quyền hoặc camera không khả dụng',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Vui lòng cấp quyền máy ảnh để quét mã QR hoặc dùng nút "Mở thư viện ảnh" hay nhập ID bên dưới.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFFB0C4B8),
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      InkWell(
                                        onTap: () async {
                                          final status = await Permission.camera.request();
                                          if (status.isPermanentlyDenied) {
                                            openAppSettings();
                                          } else if (status.isGranted) {
                                            _scannerController.start();
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Cấp quyền máy ảnh',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            // Watermark căn giữa mờ mờ
                            Center(
                              child: Opacity(
                                opacity: 0.12,
                                child: const Icon(
                                  Icons.qr_code_2,
                                  size: 150,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            // Khung ngắm quét (Reticle 4 góc)
                            SizedBox(
                              width: 220,
                              height: 220,
                              child: Stack(
                                children: [
                                  // 4 Corner Brackets
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: _buildCorner(isTop: true, isLeft: true),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: _buildCorner(isTop: true, isLeft: false),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: _buildCorner(isTop: false, isLeft: true),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: _buildCorner(isTop: false, isLeft: false),
                                  ),

                                  // Tia laser xanh quét chuyển động lên xuống
                                  AnimatedBuilder(
                                    animation: _animation,
                                    builder: (context, child) {
                                      return Positioned(
                                        top: 220 * _animation.value,
                                        left: 10,
                                        right: 10,
                                        child: Container(
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF66BB6A),
                                            borderRadius: BorderRadius.circular(2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF66BB6A).withValues(alpha: 0.8),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Label badge: Giữ mã rõ nét trong khung
                            Positioned(
                              bottom: 24,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B3828).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                ),
                                child: const Text(
                                  'Giữ mã rõ nét trong khung',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card lưu ý xanh nhạt (Ảnh 1)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3E4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.qr_code_2, color: AppColors.primary, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Chỉ quét QR từ mục "QR hộ gia đình". Quét mã chưa gửi yêu cầu tham gia.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2D4F3C),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Thành phần: Hoặc nhập ID hộ gia đình (Theo yêu cầu 1)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8DE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Hoặc nhập ID hộ gia đình:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              InkWell(
                                onTap: _pasteFromClipboard,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Row(
                                    children: [
                                      Icon(Icons.content_paste, size: 14, color: AppColors.primary),
                                      SizedBox(width: 4),
                                      Text(
                                        'Dán',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _idInputController,
                            decoration: InputDecoration(
                              hintText: 'Ví dụ: b65d2031-7e92-4a08-9c16-5f2e8d43a701',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                              filled: true,
                              fillColor: const Color(0xFFF7F9F6),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              final text = _idInputController.text.trim();
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vui lòng nhập ID hộ gia đình')),
                                );
                                return;
                              }
                              _onQrDetected(text);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Text(
                                  'Xác nhận mã QR',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nút: Mở thư viện ảnh (kèm icon, mở thư viện thật - Theo yêu cầu 2)
                    InkWell(
                      onTap: _isAnalyzingImage ? null : _pickImageFromGallery,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8DE)),
                        ),
                        child: Center(
                          child: _isAnalyzingImage
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Mở thư viện ảnh',
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

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    const double size = 30;
    const double thickness = 3.5;
    const color = Colors.white;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          isTop: isTop,
          isLeft: isLeft,
          thickness: thickness,
          color: color,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final double thickness;
  final Color color;

  _CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.thickness,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
