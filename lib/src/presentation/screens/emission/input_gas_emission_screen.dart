import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/emission_month_picker_sheet.dart';
import '../../../domain/entities/emission_details.dart';
import '../../../domain/entities/household_emission.dart';
import 'emission_preview_screen.dart';
import 'package:spei_community/src/core/constants/app_colors.dart';

/// Màn hình nhập dữ liệu phát thải Gas nhà mình (gồm 2 cách: Từ bình & phần dùng, Nhập kg thực tế)
class InputGasEmissionScreen extends StatefulWidget {
  final int? initialYear;
  final int? initialMonth;
  final HouseholdEmission? editRecord;

  const InputGasEmissionScreen({
    super.key,
    this.initialYear,
    this.initialMonth,
    this.editRecord,
  });

  @override
  State<InputGasEmissionScreen> createState() => _InputGasEmissionScreenState();
}

class _InputGasEmissionScreenState extends State<InputGasEmissionScreen> {
  // 0: Nhập kg thực tế, 1: Từ bình & phần dùng (Mặc định 1 theo Ảnh 5)
  int _gasInputMode = 1;

  late int _selectedYear;
  late int _selectedMonth;

  final TextEditingController _sourceNameController =
      TextEditingController(text: 'Bếp gia đình');

  // Controllers cho chế độ "Từ bình & phần dùng"
  final TextEditingController _cylinderWeightController =
      TextEditingController(text: '12');
  final TextEditingController _percentUsedController =
      TextEditingController(text: '25');

  // Controller cho chế độ "Nhập kg thực tế"
  final TextEditingController _directKgController =
      TextEditingController(text: '3');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear =
        widget.editRecord?.periodYear ?? widget.initialYear ?? now.year;
    _selectedMonth =
        widget.editRecord?.periodMonth ?? widget.initialMonth ?? now.month;

    if (widget.editRecord != null) {
      final rec = widget.editRecord!;
      final details = rec.details;
      _sourceNameController.text =
          details.sourceLabel?.isNotEmpty == true
              ? details.sourceLabel!
              : 'Bếp gia đình';
      _gasInputMode = 0; // Chuyển sang chế độ nhập kg thực tế
      final weight = details is GasDetails
          ? details.weightKg
          : ((details.raw['weight_kg'] as num?)?.toDouble() ??
              (details.raw['input_value'] as num?)?.toDouble());
      if (weight != null) {
        _directKgController.text = weight == weight.roundToDouble()
            ? weight.toInt().toString()
            : weight.toString().replaceAll('.', ',');
      }
    }

    _cylinderWeightController.addListener(_onCalculatedChanged);
    _percentUsedController.addListener(_onCalculatedChanged);
  }

  @override
  void dispose() {
    _sourceNameController.dispose();
    _cylinderWeightController.dispose();
    _percentUsedController.dispose();
    _directKgController.dispose();
    super.dispose();
  }

  void _onCalculatedChanged() {
    setState(() {});
  }

  double get _calculatedGasKg {
    final weight =
        double.tryParse(_cylinderWeightController.text.replaceAll(',', '.')) ??
            0.0;
    final percent =
        double.tryParse(_percentUsedController.text.replaceAll(',', '.')) ??
            0.0;
    final result = (weight * percent) / 100.0;
    return result > 0 ? result : 0.0;
  }

  String get _calculatedGasKgString {
    final kg = _calculatedGasKg;
    if (kg == kg.roundToDouble()) {
      return kg.toInt().toString();
    }
    return kg.toStringAsFixed(1).replaceAll('.', ',');
  }

  String get _monthLabel =>
      'Tháng ${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear';

  Future<void> _pickMonth() async {
    final picked = await showEmissionMonthPickerSheet(
      context: context,
      initialYear: _selectedYear,
      initialMonth: _selectedMonth,
    );
    if (picked != null) {
      setState(() {
        _selectedYear = picked.year;
        _selectedMonth = picked.month;
      });
    }
  }

  void _handleContinue() {
    final weight = _gasInputMode == 1
        ? _calculatedGasKg
        : (double.tryParse(_directKgController.text.trim().replaceAll(',', '.')) ?? 0.0);

    if (weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập khối lượng gas hợp lệ (> 0 kg).')),
      );
      return;
    }

    final sourceName = _sourceNameController.text.trim();
    final weightDisplay = _gasInputMode == 1 ? _calculatedGasKgString : _directKgController.text.trim();

    final payload = EmissionPayload.gas(
      subCategory: 'lpg',
      details: GasDetails(
        sourceLabel: sourceName.isNotEmpty ? sourceName : null,
        gasType: 'lpg',
        weightKg: weight,
      ),
    );

    final args = EmissionPreviewArgs(
      year: _selectedYear,
      month: _selectedMonth,
      category: EmissionCategory.gas,
      subCategory: 'lpg',
      categoryTitle: 'Khí đốt (Gas)',
      sourceName: sourceName.isNotEmpty ? sourceName : null,
      inputMethodLabel: 'Gas — kg thực dùng',
      displayFields: [
        const MapEntry('Loại khí đốt', 'Bình gas hóa lỏng (LPG)'),
        MapEntry('Khối lượng thực dùng', '$weightDisplay kg'),
        if (_gasInputMode == 1)
          MapEntry('Tỷ lệ bình đã dùng', '${_percentUsedController.text.trim()}% bình ${_cylinderWeightController.text.trim()} kg'),
      ],
      payload: payload,
      isEdit: widget.editRecord != null,
      editingEmissionId: widget.editRecord?.id,
    );

    context.push('/emission/preview', extra: args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header: Gas nhà mình
            _buildHeader(context),

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
                    // 1. Banner thông báo trên đầu: "Không mặc định dùng hết cả bình"
                    _buildTopNoticeBanner(),
                    const SizedBox(height: 16),

                    // 2. Thẻ form: Lượng gas tháng này
                    _buildGasFormCard(),
                    const SizedBox(height: 16),

                    // 3. Card giải thích màu xanh dưới cùng: "Tìm số liệu chính xác hơn"
                    _buildGasInfoCallout(),
                    const SizedBox(height: 24),

                    // Nút Tiếp tục & xem ước tính
                    _buildBottomActionButton(),
                    const SizedBox(height: 8),

                    // Dòng phụ chú dưới nút
                    const Center(
                      child: Text(
                        'Hệ thống tính khi bạn tiếp tục. Kiểm tra kết quả trước khi xác nhận lưu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

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

  /// Header
  Widget _buildHeader(BuildContext context) {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gas nhà mình',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Ghi lượng gas thực tế đã tiêu thụ',
                  style: TextStyle(
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

  /// Banner thông báo đầu trang: "Không mặc định dùng hết cả bình"
  Widget _buildTopNoticeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueSurface,
        borderRadius: BorderRadius.circular(16),
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
              Expanded(
                child: Text(
                  'Không mặc định dùng hết cả bình',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Bình 12 kg không có nghĩa đã tiêu thụ 12 kg. Chỉ ghi lượng gas thực tế dùng, không gồm vỏ bình.',
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

  /// Thẻ form: Lượng gas tháng này
  Widget _buildGasFormCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lượng gas tháng này',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
          ),
          const SizedBox(height: 14),

          // Tháng ghi nhận
          const Text(
            'Tháng ghi nhận',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickMonth,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _monthLabel,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray800,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.greenPrimary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tên nguồn phát thải
          const Text(
            'Tên nguồn phát thải (không bắt buộc)',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _sourceNameController,
            style: const TextStyle(fontSize: 14.5, color: AppColors.gray800),
            decoration: InputDecoration(
              hintText: 'Ví dụ: Bếp gia đình',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gray200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gray200),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Có thể bỏ trống. Đặt tên để phân biệt các bản ghi cùng loại trong tháng.',
            style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
          ),
          const SizedBox(height: 18),

          // Segmented tab switch bên trong card: [Nhập kg thực tế] [Từ bình & phần dùng]
          Container(
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_gasInputMode != 0) {
                        setState(() => _gasInputMode = 0);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _gasInputMode == 0
                            ? AppColors.greenPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Nhập kg thực tế',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: _gasInputMode == 0
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: _gasInputMode == 0
                              ? Colors.white
                              : AppColors.gray600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_gasInputMode != 1) {
                        setState(() => _gasInputMode = 1);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _gasInputMode == 1
                            ? AppColors.greenPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Từ bình & phần dùng',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: _gasInputMode == 1
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: _gasInputMode == 1
                              ? Colors.white
                              : AppColors.gray600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (_gasInputMode == 1) ...[
            // Khối lượng gas trong bình đầy
            const Text(
              'Khối lượng gas trong bình đầy',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _cylinderWeightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
              decoration: InputDecoration(
                hintText: '12',
                suffixText: 'kg',
                suffixStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Khối lượng gas tịnh, không phải trọng lượng cả bình.',
              style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
            ),
            const SizedBox(height: 16),

            // Phần gas đã dùng trong tháng
            const Text(
              'Phần gas đã dùng trong tháng',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _percentUsedController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.gray800,
              ),
              decoration: InputDecoration(
                hintText: '25',
                suffixText: '%',
                suffixStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Phần tiêu thụ trong kỳ, không phải tổng phần đã dùng từ ngày mua.',
              style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
            ),
            const SizedBox(height: 18),

            // Gas thực tế đã tiêu thụ
            const Text(
              'Gas thực tế đã tiêu thụ',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 8),

            // Khối tính toán tự động
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.greenPrimary, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _calculatedGasKgString,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_cylinderWeightController.text} kg × ${_percentUsedController.text}% = $_calculatedGasKgString kg • Ước tính từ phần bình đã dùng.',
              style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
            ),
          ] else ...[
            // Chế độ Nhập kg trực tiếp
            const Text(
              'Khối lượng gas đã tiêu thụ',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _directKgController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                      ),
                    ),
                  ),
                  const Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Nhập số kg gas tiêu thụ thực tế trong tháng.',
              style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
            ),
          ],
        ],
      ),
    );
  }

  /// Card thông tin "Tìm số liệu chính xác hơn"
  Widget _buildGasInfoCallout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueSurface,
        borderRadius: BorderRadius.circular(16),
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
                'Tìm số liệu chính xác hơn',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Đối chiếu phiếu giao gas hoặc cân lượng gas còn đầu và cuối kỳ. Lượng tiêu thụ = tồn đầu kỳ + gas mua – tồn cuối kỳ.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.blueDark,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nếu có số kg thực tế, chọn “Nhập kg thực tế”. Chỉ dùng tỷ lệ khi có căn cứ; mua bình mới không đồng nghĩa dùng hết.',
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

  /// Nút bấm hoàn tất
  Widget _buildBottomActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Tiếp tục & xem ước tính',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
