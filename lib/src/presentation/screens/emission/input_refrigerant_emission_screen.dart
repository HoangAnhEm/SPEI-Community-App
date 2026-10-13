import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/emission_month_picker_sheet.dart';
import '../../../domain/entities/emission_details.dart';
import '../../../domain/entities/household_emission.dart';
import 'emission_preview_screen.dart';
import 'package:spei_community/src/core/constants/app_colors.dart';
import '../../widgets/segmented_tab_bar.dart';

/// Màn hình nhập dữ liệu phát thải Môi chất làm lạnh (gồm 2 chế độ: Tủ lạnh & Điều hòa)
class InputRefrigerantEmissionScreen extends StatefulWidget {
  final int? initialYear;
  final int? initialMonth;
  final HouseholdEmission? editRecord;

  const InputRefrigerantEmissionScreen({
    super.key,
    this.initialYear,
    this.initialMonth,
    this.editRecord,
  });

  @override
  State<InputRefrigerantEmissionScreen> createState() =>
      _InputRefrigerantEmissionScreenState();
}

class _InputRefrigerantEmissionScreenState
    extends State<InputRefrigerantEmissionScreen> {
  // 0: Tủ lạnh, 1: Điều hòa
  int _selectedTabIndex = 0;

  late int _selectedYear;
  late int _selectedMonth;

  // Controllers cho Tủ lạnh
  final TextEditingController _fridgeSourceController =
      TextEditingController(text: 'Tủ lạnh phòng bếp');
  final TextEditingController _fridgeKgController =
      TextEditingController(text: '0,05');

  // Controllers cho Điều hòa
  final TextEditingController _acSourceController =
      TextEditingController(text: 'Điều hòa phòng ngủ');
  final TextEditingController _acKgController =
      TextEditingController(text: '0,02');

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
      final qty = details is RefrigerantDetails
          ? details.quantity
          : ((details.raw['quantity'] as num?)?.toDouble() ??
              (details.raw['input_value'] as num?)?.toDouble());
      final refType = details is RefrigerantDetails
          ? details.refrigerantType
          : (details.raw['refrigerant_type'] as String?);
      final qtyStr = qty != null
          ? (qty == qty.roundToDouble()
              ? qty.toInt().toString()
              : qty.toString().replaceAll('.', ','))
          : '';
      if (rec.subCategory == 'air_conditioner' || refType == 'R600a') {
        _selectedTabIndex = 1;
        _acSourceController.text =
            details.sourceLabel?.isNotEmpty == true
                ? details.sourceLabel!
                : 'Điều hòa phòng ngủ';
        if (qtyStr.isNotEmpty) {
          _acKgController.text = qtyStr;
        }
      } else {
        _selectedTabIndex = 0;
        _fridgeSourceController.text =
            details.sourceLabel?.isNotEmpty == true
                ? details.sourceLabel!
                : 'Tủ lạnh phòng bếp';
        if (qtyStr.isNotEmpty) {
          _fridgeKgController.text = qtyStr;
        }
      }
    }

    _fridgeKgController.addListener(_onInputChanged);
    _acKgController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _fridgeSourceController.dispose();
    _fridgeKgController.dispose();
    _acSourceController.dispose();
    _acKgController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {});
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
    if (_selectedTabIndex == 0) {
      // Tủ lạnh (R32)
      final kg = double.tryParse(_fridgeKgController.text.trim().replaceAll(',', '.')) ?? 0.0;
      if (kg <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập lượng rò rỉ/bổ sung hợp lệ (> 0 kg).')),
        );
        return;
      }

      final sourceName = _fridgeSourceController.text.trim();
      final payload = EmissionPayload.refrigerant(
        subCategory: 'refrigerator',
        details: RefrigerantDetails(
          sourceLabel: sourceName.isNotEmpty ? sourceName : null,
          refrigerantType: 'R32',
          quantity: kg,
        ),
      );

      final args = EmissionPreviewArgs(
        year: _selectedYear,
        month: _selectedMonth,
        category: EmissionCategory.refrigerant,
        subCategory: 'refrigerator',
        categoryTitle: 'Môi chất làm lạnh',
        sourceName: sourceName.isNotEmpty ? sourceName : null,
        inputMethodLabel: 'Tủ lạnh — R32',
        displayFields: [
          const MapEntry('Thiết bị', 'Tủ lạnh'),
          const MapEntry('Môi chất giả định', 'R32'),
          MapEntry('Lượng rò rỉ / bổ sung', '${_fridgeKgController.text.trim()} kg'),
        ],
        payload: payload,
        isEdit: widget.editRecord != null,
        editingEmissionId: widget.editRecord?.id,
      );

      context.push('/emission/preview', extra: args);
    } else {
      // Điều hòa (R600a)
      final kg = double.tryParse(_acKgController.text.trim().replaceAll(',', '.')) ?? 0.0;
      if (kg <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập lượng rò rỉ/bổ sung hợp lệ (> 0 kg).')),
        );
        return;
      }

      final sourceName = _acSourceController.text.trim();
      final payload = EmissionPayload.refrigerant(
        subCategory: 'air_conditioner',
        details: RefrigerantDetails(
          sourceLabel: sourceName.isNotEmpty ? sourceName : null,
          refrigerantType: 'R600a',
          quantity: kg,
        ),
      );

      final args = EmissionPreviewArgs(
        year: _selectedYear,
        month: _selectedMonth,
        category: EmissionCategory.refrigerant,
        subCategory: 'air_conditioner',
        categoryTitle: 'Môi chất làm lạnh',
        sourceName: sourceName.isNotEmpty ? sourceName : null,
        inputMethodLabel: 'Điều hòa — R600a',
        displayFields: [
          const MapEntry('Thiết bị', 'Điều hòa'),
          const MapEntry('Môi chất giả định', 'R600a'),
          MapEntry('Lượng rò rỉ / bổ sung', '${_acKgController.text.trim()} kg'),
        ],
        payload: payload,
        isEdit: widget.editRecord != null,
        editingEmissionId: widget.editRecord?.id,
      );

      context.push('/emission/preview', extra: args);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Toggle tab switch: [Tủ lạnh] [Điều hòa]
            _buildTopTabSwitch(),

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
                    if (_selectedTabIndex == 0) ...[
                      // 1. Cảnh báo vàng: Tính dựa trên môi chất R32
                      _buildFridgeWarningBanner(),
                      const SizedBox(height: 16),

                      // 2. Thẻ form: Môi chất trong kỳ (Tủ lạnh)
                      _buildFridgeFormCard(),
                      const SizedBox(height: 16),

                      // 3. Card giải thích màu xanh: "Nhờ kỹ thuật viên xác nhận"
                      _buildFridgeInfoCallout(),
                    ] else ...[
                      // 1. Cảnh báo vàng: Tính với môi chất R600a
                      _buildAcWarningBanner(),
                      const SizedBox(height: 16),

                      // 2. Thẻ form: Môi chất trong kỳ (Điều hòa)
                      _buildAcFormCard(),
                      const SizedBox(height: 16),

                      // 3. Card giải thích màu xanh: "Tìm khối lượng ở đâu?"
                      _buildAcInfoCallout(),
                    ],

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
    final subtitle = _selectedTabIndex == 0
        ? 'Nhập lượng rò rỉ/bổ sung có căn cứ'
        : 'Nhập lượng rò rỉ/bổ sung theo căn cứ';

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
                  'Môi chất làm lạnh',
                  style: TextStyle(
                    fontSize: 20,
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

  /// Switch tab chế độ [Tủ lạnh] | [Điều hòa]
  Widget _buildTopTabSwitch() {
    return SegmentedTabBar(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      tabs: const ['Tủ lạnh', 'Điều hòa'],
      selectedIndex: _selectedTabIndex,
      onChanged: (i) => setState(() => _selectedTabIndex = i),
    );
  }

  /// Cảnh báo vàng Tủ lạnh (Ảnh 1)
  Widget _buildFridgeWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: AppColors.amber600,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Phát thải tủ lạnh được tính dựa trên môi chất R32',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amber700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'R32 là giả định của cách tính trong sản phẩm này. Bạn chỉ cần nhập lượng rò rỉ/bổ sung có căn cứ; không cần chọn môi chất.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.amber800,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Cảnh báo vàng Điều hòa (Ảnh 2)
  Widget _buildAcWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: AppColors.amber600,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cách tính với môi chất R600a',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amber700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Cách tính này sử dụng R600a. Nhập khối lượng rò rỉ/bổ sung có căn cứ; không cần chọn môi chất.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.amber800,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Thẻ form Chế độ 1: Tủ lạnh (Ảnh 1)
  Widget _buildFridgeFormCard() {
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
            'Môi chất trong kỳ',
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
            controller: _fridgeSourceController,
            style: const TextStyle(fontSize: 14.5, color: AppColors.gray800),
            decoration: InputDecoration(
              hintText: 'Ví dụ: Tủ lạnh phòng bếp',
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

          // Lượng rò rỉ / bổ sung trong tháng
          const Text(
            'Lượng rò rỉ / bổ sung trong tháng',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),

          // Khối nhập số lớn viền xanh đậm
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.greenPrimary,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fridgeKgController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
            'Chỉ ghi lượng có căn cứ trong kỳ, không ghi toàn bộ lượng nạp của thiết bị.',
            style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  /// Card hướng dẫn Tủ lạnh (Ảnh 1)
  Widget _buildFridgeInfoCallout() {
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
                'Nhờ kỹ thuật viên xác nhận',
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
            'Tìm lượng rò rỉ/bổ sung trên phiếu sửa chữa. Ví dụ 50 g ÷ 1.000 = 0,05 kg.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.blueDark,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sử dụng bình thường không đồng nghĩa với tiêu thụ môi chất. Không có rò rỉ/bổ sung đã xác nhận? Ghi 0; chưa biết thì không ước đoán.',
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

  /// Thẻ form Chế độ 2: Điều hòa (Ảnh 2)
  Widget _buildAcFormCard() {
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
            'Môi chất trong kỳ',
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
            controller: _acSourceController,
            style: const TextStyle(fontSize: 14.5, color: AppColors.gray800),
            decoration: InputDecoration(
              hintText: 'Ví dụ: Điều hòa phòng ngủ',
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

          // Lượng rò rỉ / bổ sung trong tháng
          const Text(
            'Lượng rò rỉ / bổ sung trong tháng',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),

          // Khối nhập số lớn viền xanh đậm
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.greenPrimary,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _acKgController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
            'Không dùng toàn bộ lượng nạp trên nhãn hoặc lượng dùng khi máy vận hành bình thường.',
            style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  /// Card hướng dẫn Điều hòa (Ảnh 2)
  Widget _buildAcInfoCallout() {
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
                'Tìm khối lượng ở đâu?',
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
            'Nhờ kỹ thuật viên xác nhận số gram môi chất bổ sung trong kỳ. Ví dụ 20 g ÷ 1.000 = 0,02 kg.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.blueDark,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Không có lượng rò rỉ/bổ sung thì ghi 0; không suy lượng môi chất từ thời gian dùng máy.',
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
