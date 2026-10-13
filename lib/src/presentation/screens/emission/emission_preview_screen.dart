import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/di/di.dart';
import '../../../domain/entities/emission_details.dart';
import '../../../domain/entities/emission_result.dart';
import '../../../domain/repositories/emission_repository.dart';
import '../../blocs/emission/emission_cubit.dart';
import '../common/custom_success_screen.dart';
import 'widgets/emission_calculation_method_card.dart';
import 'package:spei_community/src/core/constants/app_colors.dart';

// Màu riêng của màn này
const Color _kGreenDark1B5E20 = Color(0xFF1B5E20);
const Color _kGreenLightD3ECD7 = Color(0xFFD3ECD7);
const Color _kGreenLightEBF6EE = Color(0xFFEBF6EE);

/// Dữ liệu đầu vào truyền sang màn hình kiểm tra trước khi lưu
class EmissionPreviewArgs {
  final int year;
  final int month;
  final String category;
  final String? subCategory;
  final String categoryTitle;
  final String? sourceName;
  final String inputMethodLabel;
  final List<MapEntry<String, String>> displayFields;
  final EmissionPayload payload;
  final bool isEdit;
  final String? editingEmissionId;

  const EmissionPreviewArgs({
    required this.year,
    required this.month,
    required this.category,
    this.subCategory,
    required this.categoryTitle,
    this.sourceName,
    required this.inputMethodLabel,
    required this.displayFields,
    required this.payload,
    this.isEdit = false,
    this.editingEmissionId,
  });
}

/// Màn hình kiểm tra trước khi lưu (Ảnh 1)
class EmissionPreviewScreen extends StatefulWidget {
  final EmissionPreviewArgs args;

  const EmissionPreviewScreen({
    super.key,
    required this.args,
  });

  @override
  State<EmissionPreviewScreen> createState() => _EmissionPreviewScreenState();
}

class _EmissionPreviewScreenState extends State<EmissionPreviewScreen> {
  bool _isCalculating = true;
  String? _calcErrorMessage;
  EmissionResultResponse? _calcResult;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _calculateEmission();
  }

  /// Gọi API tính toán phát thải ước tính từ hệ thống
  Future<void> _calculateEmission() async {
    setState(() {
      _isCalculating = true;
      _calcErrorMessage = null;
    });

    try {
      final repo = getIt<EmissionRepository>();
      final result = await repo.calculateEmission(
        CalculateEmissionRequest(payload: widget.args.payload),
      );
      if (!mounted) return;
      setState(() {
        _calcResult = result;
        _isCalculating = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Nếu API tạm thời lỗi hoặc offline, fallback tính toán ước tính sơ bộ
      final fallbackCo2e = _fallbackEstimate(widget.args.payload);
      setState(() {
        _calcErrorMessage = e.toString().replaceFirst('Exception: ', '');
        _calcResult = EmissionResultResponse(
          category: widget.args.category,
          subCategory: widget.args.subCategory,
          co2eKg: fallbackCo2e,
          co2eTon: fallbackCo2e / 1000.0,
          details: widget.args.payload.details,
          rawDetails: widget.args.payload.details.toJson(),
          createdAt: DateTime.now(),
        );
        _isCalculating = false;
      });
    }
  }

  /// Tính toán dự phòng khi chưa có mạng hoặc backend tính toán trả lỗi
  double _fallbackEstimate(EmissionPayload payload) {
    try {
      final details = payload.details;
      if (details is ElectricityDetails) {
        if (details.isKwh) {
          return double.parse((details.inputValue * 0.6592).toStringAsFixed(2));
        } else {
          // ~2.100 VND / kWh -> nhân 0.6592
          final kwh = details.inputValue / 2100.0;
          return double.parse((kwh * 0.6592).toStringAsFixed(2));
        }
      } else if (details is TransportationDetails) {
        if (details.isLiters) {
          // Xăng ~ 2.3 kg CO2/lít
          return double.parse((details.inputValue * 2.3).toStringAsFixed(2));
        } else {
          // Điện sạc xe ~ 0.6592 kg CO2/kWh
          return double.parse((details.inputValue * 0.6592).toStringAsFixed(2));
        }
      } else if (details is GasDetails) {
        // Gas LPG ~ 3.0 kg CO2/kg
        return double.parse((details.weightKg * 2.983).toStringAsFixed(2));
      } else if (details is RefrigerantDetails) {
        // R32: GWP 675, R600a: GWP 3
        final factor = details.refrigerantType == 'R32' ? 675.0 : 3.0;
        return double.parse((details.quantity * factor).toStringAsFixed(2));
      } else if (details is WasteDetails) {
        if (details.unit == 'm3') {
          return double.parse((details.quantity * 0.18574).toStringAsFixed(2));
        } else {
          return double.parse(((details.quantity / 1000.0) * 497.24244).toStringAsFixed(2));
        }
      }
    } catch (_) {}
    return 0.0;
  }

  String get _co2eKgFormatted {
    if (_calcResult != null) {
      return _calcResult!.co2eKgFormatted.replaceAll('.', ',');
    }
    return '0,0';
  }

  /// Xác nhận lưu bản ghi phát thải
  Future<void> _handleSave() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final repo = getIt<EmissionRepository>();
      if (widget.args.isEdit && widget.args.editingEmissionId != null) {
        await repo.updateHouseholdEmission(
          emissionId: widget.args.editingEmissionId!,
          request: UpdateHouseholdEmissionRequest(
            periodYear: widget.args.year,
            periodMonth: widget.args.month,
            payload: widget.args.payload,
          ),
        );
      } else {
        await repo.recordHouseholdEmission(
          RecordHouseholdEmissionRequest(
            periodYear: widget.args.year,
            periodMonth: widget.args.month,
            payload: widget.args.payload,
          ),
        );
      }

      // Cập nhật lại lịch sử phát thải ở nền
      try {
        getIt<EmissionCubit>().loadEmissions(
          year: widget.args.year,
          month: widget.args.month,
        );
      } catch (_) {}

      if (!mounted) return;

      // Chuyển sang màn hình thành công dùng chung
      final monthStr = widget.args.month.toString().padLeft(2, '0');
      final successArgs = CustomSuccessArgs(
        title: widget.args.isEdit
            ? 'Cập nhật bản ghi thành công!'
            : 'Ghi nhận phát thải thành công!',
        subtitle: widget.args.isEdit
            ? 'Bản ghi phát thải ${widget.args.categoryTitle} tháng $monthStr/${widget.args.year} đã được cập nhật thành công.'
            : 'Dữ liệu phát thải ${widget.args.categoryTitle} tháng $monthStr/${widget.args.year} của gia đình bạn đã được ghi nhận vào hệ thống.',
        cardTag: 'Phát thải gia đình',
        cardHighlightText: '$_co2eKgFormatted kg CO₂e',
        cardDescription: widget.args.isEdit
            ? 'Dữ liệu phát thải mới đã được đồng bộ vào hệ thống.'
            : 'Bản ghi đã được lưu vào hệ thống để theo dõi và tính điểm mầm xanh.',
        buttonText: 'Về phát thải gia đình',
        onButtonPressedWithContext: (ctx) {
          ctx.go('/emission/history', extra: {
            'year': widget.args.year,
            'month': widget.args.month,
          });
        },
      );

      context.go('/common-success', extra: successArgs);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.red600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthStr = widget.args.month.toString().padLeft(2, '0');
    final subtitleHeader =
        '${widget.args.categoryTitle} • Tháng $monthStr/${widget.args.year}';

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, subtitleHeader),

            // Step Indicator: (✔) Nhập dữ liệu  >  Kiểm tra & lưu
            _buildStepIndicator(),

            // Nội dung cuộn
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Box 1: Dữ liệu sắp ghi nhận
                    _buildPendingDataCard(),
                    const SizedBox(height: 16),

                    // Box 2: Kết quả ước tính từ hệ thống
                    _buildEstimatedResultCard(),
                    const SizedBox(height: 16),

                    // Box 3: Cách hệ thống ước tính (Ảnh 2)
                    _buildCalculationMethodCard(),
                    const SizedBox(height: 16),

                    // Box 4: Kiểm tra trước khi xác nhận
                    _buildPreConfirmationNotice(),
                    const SizedBox(height: 24),

                    // Nút Xác nhận lưu dữ liệu tháng
                    _buildSaveButton(),
                    const SizedBox(height: 8),

                    // Chú thích dưới nút
                    const Center(
                      child: Text(
                        'Xác nhận tạo bản ghi mới. Khi mở từ Chỉnh sửa, chỉ cập nhật đúng bản ghi đang chọn.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Footer ghi chú
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

  /// Header màn hình
  Widget _buildHeader(BuildContext context, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Nút quay lại bo tròn
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
                color: AppColors.greenDark,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Tiêu đề & phụ đề
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kiểm tra trước khi lưu',
                  style: TextStyle(
                    fontSize: 19.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),

          // Logo avatar tròn
          Container(
            width: 44,
            height: 44,
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
                    Image.asset('assets/icons/logo.png', fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step Indicator: (✔) Nhập dữ liệu  >  Kiểm tra & lưu
  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Row(
            children: const [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: AppColors.greenPrimary,
              ),
              SizedBox(width: 6),
              Text(
                'Nhập dữ liệu',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.gray400,
            ),
          ),
          const Text(
            'Kiểm tra & lưu',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Box 1: Dữ liệu sắp ghi nhận
  Widget _buildPendingDataCard() {
    final monthStr = widget.args.month.toString().padLeft(2, '0');
    final sourceName = widget.args.sourceName?.trim();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dữ liệu sắp ghi nhận',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
          const SizedBox(height: 16),

          // Các trường chung
          _buildInfoRow('Tháng', '$monthStr/${widget.args.year}'),
          const SizedBox(height: 10),
          _buildInfoRow('Loại phát thải', widget.args.categoryTitle),
          const SizedBox(height: 10),
          _buildInfoRow('Tên nguồn', (sourceName != null && sourceName.isNotEmpty) ? sourceName : '—'),
          const SizedBox(height: 10),
          _buildInfoRow('Cách nhập', widget.args.inputMethodLabel),

          // Đường phân cách nhẹ
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: AppColors.gray100),
          ),

          // Các trường chi tiết theo loại
          for (int i = 0; i < widget.args.displayFields.length; i++) ...[
            _buildInfoRow(
              widget.args.displayFields[i].key,
              widget.args.displayFields[i].value,
            ),
            if (i < widget.args.displayFields.length - 1)
              const SizedBox(height: 10),
          ],

          const SizedBox(height: 16),

          // Nút quay lại sửa dữ liệu
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.arrow_back,
                    size: 15,
                    color: AppColors.greenPrimary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Chỉnh sửa dữ liệu',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greenPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dòng hiển thị Key - Value
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.gray500,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Box 2: Kết quả ước tính từ hệ thống
  Widget _buildEstimatedResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _kGreenLightEBF6EE,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kGreenLightD3ECD7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kết quả ước tính từ hệ thống',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.greenDark,
            ),
          ),
          const SizedBox(height: 8),

          if (_isCalculating)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.greenPrimary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Đang tính toán phát thải...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.greenPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              '$_co2eKgFormatted kg CO₂e ước tính',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _kGreenDark1B5E20,
                letterSpacing: -0.2,
              ),
            ),

          if (_calcErrorMessage != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '(Ước tính sơ bộ - $_calcErrorMessage)',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.amber700,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _calculateEmission,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      'Thử lại',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greenPrimary,
                        fontWeight: FontWeight.bold,
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
  }

  /// Box 3: Cách hệ thống ước tính (Ảnh 2)
  Widget _buildCalculationMethodCard() {
    String? inputType;
    String? refrigerantType;

    final details = widget.args.payload.details;
    if (details is ElectricityDetails) {
      inputType = details.inputType;
    } else if (details is TransportationDetails) {
      inputType = details.inputType;
    } else if (details is RefrigerantDetails) {
      refrigerantType = details.refrigerantType;
    }

    return EmissionCalculationMethodCard.fromCategory(
      category: widget.args.category,
      subCategory: widget.args.subCategory,
      inputType: inputType,
      refrigerantType: refrigerantType,
    );
  }

  /// Box 4: Kiểm tra trước khi xác nhận
  Widget _buildPreConfirmationNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.blueBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.blueMedium,
              ),
              SizedBox(width: 8),
              Text(
                'Kiểm tra trước khi xác nhận',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Kiểm tra tháng, loại, tên nguồn nếu có và lượng ghi nhận trước khi lưu. Mỗi lần thêm mới tạo một bản ghi riêng.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.blueDark,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Nút Xác nhận lưu dữ liệu tháng
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                widget.args.isEdit
                    ? 'Xác nhận cập nhật bản ghi'
                    : 'Xác nhận lưu dữ liệu tháng',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
