import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_lookup_result.dart';
import '../../blocs/household/household_cubit.dart';
import '../../blocs/invite_user/invite_user_cubit.dart';
import '../../blocs/invite_user/invite_user_state.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/segmented_tab_bar.dart';

class InviteUserScreen extends StatefulWidget {
  const InviteUserScreen({super.key});

  @override
  State<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0; // 0: Phone, 1: Email, 2: QR Code

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idInputController = TextEditingController();

  late final MobileScannerController _scannerController;
  late final AnimationController _laserAnimController;
  late final Animation<double> _laserAnimation;

  bool _isAnalyzingImage = false;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _laserAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _laserAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserAnimController.dispose();
    _scannerController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idInputController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _onQrDetected(String rawCode) {
    if (_hasScanned) return;
    final trimmed = rawCode.trim();
    if (trimmed.isEmpty) return;

    _hasScanned = true;
    context.read<InviteUserCubit>().searchUser(userId: trimmed);

    // Cho phép quét lại sau 2 giây nếu muốn
    Future.delayed(const Duration(seconds: 2), () {
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

      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

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
            content: Text('Không tìm thấy mã QR trong ảnh đã chọn. Vui lòng thử ảnh khác hoặc nhập ID.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đọc ảnh: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppColors.error,
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

  void _handleSearch() {
    FocusScope.of(context).unfocus();
    final cubit = context.read<InviteUserCubit>();

    if (_selectedTabIndex == 0) {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập số điện thoại người dùng')),
        );
        return;
      }
      cubit.searchUser(phoneNumber: phone);
    } else if (_selectedTabIndex == 1) {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập email người dùng')),
        );
        return;
      }
      cubit.searchUser(email: email);
    } else {
      final id = _idInputController.text.trim();
      if (id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập ID người dùng')),
        );
        return;
      }
      cubit.searchUser(userId: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final household = context.watch<HouseholdCubit>().state.household;
    final householdName = household?.name ?? 'Nhà Mầm xanh';

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: BlocConsumer<InviteUserCubit, InviteUserState>(
          listener: (context, state) {
            if (state.inviteStatus == SendInviteStatus.success && state.inviteMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.inviteMessage!),
                  backgroundColor: AppColors.primary,
                ),
              );
            } else if (state.inviteStatus == SendInviteStatus.failure && state.inviteMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.inviteMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state.searchStatus == UserSearchStatus.failure && state.searchError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.searchError!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                CustomAppBar(
                  title: 'Mời vào $householdName',
                  subtitle: 'Tìm tài khoản SPEI của người bạn muốn mời.',
                  showBackButton: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tab Selector dạng viên thuốc
                        _buildTabSelector(),
                        const SizedBox(height: 20),

                        // Nội dung theo Tab
                        if (_selectedTabIndex == 0)
                          _buildPhoneTab(state)
                        else if (_selectedTabIndex == 1)
                          _buildEmailTab(state)
                        else
                          _buildQrTab(state),

                        // Kết quả tìm kiếm
                        if (state.searchStatus == UserSearchStatus.loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          )
                        else if (state.searchedUser != null)
                          _buildSearchResultSection(state, state.searchedUser!),

                        const SizedBox(height: 16),

                        // Card gợi ý quét QR (ở Tab 0 & Tab 1)
                        if (_selectedTabIndex != 2) ...[
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = 2;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.greenSurface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.greenBorderSoft),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.qr_code_2, color: AppColors.primary, size: 22),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Bạn có thể quét QR của người dùng thay vì nhập số điện thoại hoặc email.',
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
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Footer
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return SegmentedTabBar(
      tabs: const ['Số điện thoại', 'Email', 'Quét QR'],
      selectedIndex: _selectedTabIndex,
      onChanged: (i) => setState(() => _selectedTabIndex = i),
    );
  }

  Widget _buildPhoneTab(InviteUserState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số điện thoại người dùng',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '0908 123 456',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSearchButton(state),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmailTab(InviteUserState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email người dùng',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'ha.pham@example.com',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSearchButton(state),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSearchButton(InviteUserState state) {
    final isLoading = state.searchStatus == UserSearchStatus.loading;

    return InkWell(
      onTap: isLoading ? null : _handleSearch,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: isLoading
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
                    Icon(Icons.search, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tìm người dùng',
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
    );
  }

  Widget _buildQrTab(InviteUserState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Khung Camera Scanner
        Container(
          width: double.infinity,
          height: 350,
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
                      color: AppColors.textNearBlack,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.videocam_off_outlined,
                            size: 48,
                            color: AppColors.orangeAccent,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Camera không khả dụng',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Cấp quyền máy ảnh hoặc nhập ID / chọn ảnh bên dưới.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textGreenGreyMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),
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
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Cấp quyền máy ảnh',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
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

                // Corner Reticle
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    children: [
                      Positioned(top: 0, left: 0, child: _buildCorner(isTop: true, isLeft: true)),
                      Positioned(top: 0, right: 0, child: _buildCorner(isTop: true, isLeft: false)),
                      Positioned(bottom: 0, left: 0, child: _buildCorner(isTop: false, isLeft: true)),
                      Positioned(bottom: 0, right: 0, child: _buildCorner(isTop: false, isLeft: false)),
                      AnimatedBuilder(
                        animation: _laserAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: 200 * _laserAnimation.value,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.green400,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.green400.withValues(alpha: 0.8),
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
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.greenNight.withValues(alpha: 0.85),
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
        const SizedBox(height: 12),

        // Card lưu ý chỉ quét QR người dùng từ mục QR của tôi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.qr_code_2, color: AppColors.primary, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Chỉ quét QR người dùng từ mục "QR của tôi".',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textGreenMedium,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Thành phần: Hoặc nhập ID người dùng
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hoặc nhập ID người dùng:',
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
                  fillColor: AppColors.surfacePale,
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
                onTap: _handleSearch,
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
        const SizedBox(height: 12),

        // Nút Mở thư viện ảnh
        InkWell(
          onTap: _isAnalyzingImage ? null : _pickImageFromGallery,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
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
                            color: AppColors.textGreenMedium,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSearchResultSection(InviteUserState state, UserLookupResult user) {
    final initials = _getInitials(user.fullName);
    final isSending = state.inviteStatus == SendInviteStatus.loading;
    final subInfo = user.phoneNumber?.isNotEmpty == true
        ? user.phoneNumber!
        : (user.email?.isNotEmpty == true ? user.email! : user.userId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kết quả tìm kiếm',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin người dùng
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
                          user.fullName.isNotEmpty ? user.fullName : 'Người dùng',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subInfo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Thông điệp mời hoặc lý do từ API
              if (user.canInvite) ...[
                const Text(
                  'Lời mời tham gia sẽ được gửi đến tài khoản này.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.subText,
                    height: 1.4,
                  ),
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user.reason ?? 'Không thể mời người dùng này vào hộ gia đình.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Nút Gửi lời mời / Đã gửi lời mời / Xem lời mời đã gửi
              if (!state.hasInvited) ...[
                InkWell(
                  onTap: (user.canInvite && !isSending)
                      ? () => context.read<InviteUserCubit>().sendInvite(user.userId)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: user.canInvite ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.send_outlined,
                                  color: user.canInvite ? Colors.white : AppColors.textMuted,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Gửi lời mời',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: user.canInvite ? Colors.white : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ] else ...[
                // Trạng thái đã gửi lời mời
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: AppColors.textGreenMedium, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Đã gửi lời mời',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textGreenMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    context.push('/family/invitations/sent');
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'Xem lời mời đã gửi',
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    const double size = 26;
    const double thickness = 3.0;
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
