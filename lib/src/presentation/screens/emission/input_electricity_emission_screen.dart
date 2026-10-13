import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/emission_month_picker_sheet.dart';
import '../../../domain/entities/emission_details.dart';
import '../../../domain/entities/household_emission.dart';
import 'emission_preview_screen.dart';
import 'package:spei_community/src/core/constants/app_colors.dart';
import '../../widgets/segmented_tab_bar.dart';

/// Màn hình nhập dữ liệu phát thải Điện gia đình (gồm 2 chế độ: Số điện kWh & Tiền điện VNĐ)
class InputElectricityEmissionScreen extends StatefulWidget {
  final int? initialYear;
  final int? initialMonth;
  final HouseholdEmission? editRecord;

  const InputElectricityEmissionScreen({
    super.key,
    this.initialYear,
    this.initialMonth,
    this.editRecord,
  });

  @override
  State<InputElectricityEmissionScreen> createState() =>
      _InputElectricityEmissionScreenState();
}

class _InputElectricityEmissionScreenState
    extends State<InputElectricityEmissionScreen> {
  // 0: Số điện (kWh), 1: Tiền điện (VNĐ)
  int _selectedTabIndex = 0;

  late int _selectedYear;
  late int _selectedMonth;

  // Controllers cho Tab 0: Số điện
  final TextEditingController _sourceNameKwhController =
      TextEditingController(text: 'Điện nhà chính');
  final TextEditingController _kwhController =
      TextEditingController(text: '250');

  // Controllers cho Tab 1: Tiền điện
  final TextEditingController _sourceNameVndController =
      TextEditingController(text: 'Điện nhà chính');
  final TextEditingController _totalPaymentController =
      TextEditingController(text: '550.000');
  final TextEditingController _taxFeeController =
      TextEditingController(text: '50.000');

  String _formatVnd(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear =
        widget.editRecord?.periodYear ?? widget.initialYear ?? now.year;
    _selectedMonth =
        widget.editRecord?.periodMonth ?? widget.initialMonth ?? now.month;

    if (widget.editRecord != null) {
      final details = widget.editRecord!.details;
      final inputType = details is ElectricityDetails
          ? details.inputType
          : (details.raw['input_type'] as String? ?? 'kwh');
      final inputValue = details is ElectricityDetails
          ? details.inputValue
          : (details.raw['input_value'] as num?)?.toDouble();

      if (inputType == 'money_vnd') {
        _selectedTabIndex = 1;
        _sourceNameVndController.text =
            details.sourceLabel?.isNotEmpty == true
                ? details.sourceLabel!
                : 'Điện nhà chính';
        if (inputValue != null) {
          _totalPaymentController.text = _formatVnd(inputValue.toInt());
        }
      } else {
        _selectedTabIndex = 0;
        _sourceNameKwhController.text =
            details.sourceLabel?.isNotEmpty == true
                ? details.sourceLabel!
                : 'Điện nhà chính';
        if (inputValue != null) {
          _kwhController.text = inputValue == inputValue.roundToDouble()
              ? inputValue.toInt().toString()
              : inputValue.toString().replaceAll('.', ',');
        }
      }
    }

    _totalPaymentController.addListener(_onPaymentChanged);
    _taxFeeController.addListener(_onPaymentChanged);
  }

  @override
  void dispose() {
    _sourceNameKwhController.dispose();
    _kwhController.dispose();
    _sourceNameVndController.dispose();
    _totalPaymentController.dispose();
    _taxFeeController.dispose();
    super.dispose();
  }

  void _onPaymentChanged() {
    setState(() {});
  }

  double _parseVnd(String text) {
    final cleaned = text.replaceAll('.', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  double get _calculatedPreTaxAmount {
    final total = _parseVnd(_totalPaymentController.text);
    final tax = _parseVnd(_taxFeeController.text);
    final diff = total - tax;
    return diff > 0 ? diff : 0;
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
    final sourceName = _selectedTabIndex == 0
        ? _sourceNameKwhController.text.trim()
        : _sourceNameVndController.text.trim();
    if (_selectedTabIndex == 0) {
      // Số điện kWh
      final kwhText = _kwhController.text.trim().replaceAll(',', '.');
      final kwh = double.tryParse(kwhText) ?? 0.0;
      if (kwh <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập lượng điện tiêu thụ hợp lệ (> 0 kWh).')),
        );
        return;
      }

      final payload = EmissionPayload.electricity(
        details: ElectricityDetails(
          sourceLabel: sourceName.isNotEmpty ? sourceName : null,
          inputType: 'kwh',
          inputValue: kwh,
        ),
      );

      final args = EmissionPreviewArgs(
        year: _selectedYear,
        month: _selectedMonth,
        category: EmissionCategory.electricity,
        subCategory: 'grid',
        categoryTitle: 'Điện gia đình',
        sourceName: sourceName.isNotEmpty ? sourceName : null,
        inputMethodLabel: 'Số điện (kWh)',
        displayFields: [
          MapEntry('Trên hóa đơn', '${_kwhController.text.trim()} kWh'),
          MapEntry('Lượng ghi nhận', '${_kwhController.text.trim()} kWh'),
        ],
        payload: payload,
        isEdit: widget.editRecord != null,
        editingEmissionId: widget.editRecord?.id,
      );

      context.push('/emission/preview', extra: args);
    } else {
      // Tiền điện VNĐ
      final moneyText = _totalPaymentController.text.trim().replaceAll('.', '').replaceAll(',', '.');
      final amount = double.tryParse(moneyText) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập tổng tiền thanh toán hợp lệ (> 0 VNĐ).')),
        );
        return;
      }

      final payload = EmissionPayload.electricity(
        details: ElectricityDetails(
          sourceLabel: sourceName.isNotEmpty ? sourceName : null,
          inputType: 'money_vnd',
          inputValue: amount,
        ),
      );

      final args = EmissionPreviewArgs(
        year: _selectedYear,
        month: _selectedMonth,
        category: EmissionCategory.electricity,
        subCategory: 'grid',
        categoryTitle: 'Điện gia đình',
        sourceName: sourceName.isNotEmpty ? sourceName : null,
        inputMethodLabel: 'Tiền điện (VNĐ)',
        displayFields: [
          MapEntry('Tổng tiền thanh toán', '${_totalPaymentController.text.trim()} VNĐ'),
          const MapEntry('Cách quy đổi', 'Theo biểu giá bậc thang điện sinh hoạt'),
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

            // Toggle tab switch: [Số điện (kWh)] [Tiền điện (VNĐ)]
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
                      // 1. Dòng mascot & lời khuyên thân thiện
                      _buildFriendlyMascotTip(
                        'Một con số nhỏ, một bước xanh. Mình bắt đầu từ hóa đơn điện nhé!',
                      ),
                      const SizedBox(height: 16),

                      // 2. Thẻ form: Điện nhà mình
                      _buildKwhFormCard(),
                      const SizedBox(height: 16),

                      // 3. Card giải thích màu xanh: "Tìm số ở đâu trên hóa đơn?"
                      _buildKwhInfoCallout(),
                    ] else ...[
                      // 1. Card thông báo trên đầu: "Chỉ cần tổng tiền và thuế/phí trên hóa đơn"
                      _buildVndNoticeBanner(),
                      const SizedBox(height: 16),

                      // 2. Thẻ form: Nhập từ tiền điện
                      _buildVndFormCard(),
                      const SizedBox(height: 16),

                      // 3. Card giải thích: "Hệ thống xử lý tiền điện thế nào?"
                      _buildVndInfoCallout(),
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

  /// Header chuẩn giao diện
  Widget _buildHeader(BuildContext context) {
    final subtitle = _selectedTabIndex == 0
        ? 'Ghi nhận điện sử dụng theo tháng'
        : 'Quy đổi từ tiền điện • Chỉ ước tính';

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
                  'Điện gia đình',
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

  /// Switch tab chế độ [Số điện (kWh)] | [Tiền điện (VNĐ)]
  Widget _buildTopTabSwitch() {
    return SegmentedTabBar(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      tabs: const ['Số điện (kWh)', 'Tiền điện (VNĐ)'],
      selectedIndex: _selectedTabIndex,
      onChanged: (i) => setState(() => _selectedTabIndex = i),
    );
  }

  /// Dòng mascot xanh & lời khuyên thân thiện
  Widget _buildFriendlyMascotTip(String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.greenTint,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/ic_sprout_smile.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.eco_rounded,
                color: AppColors.greenPrimary,
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textGreenGrey,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Thẻ form Chế độ 1: Số điện (kWh)
  Widget _buildKwhFormCard() {
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
            'Điện nhà mình',
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
            controller: _sourceNameKwhController,
            style: const TextStyle(fontSize: 14.5, color: AppColors.gray800),
            decoration: InputDecoration(
              hintText: 'Ví dụ: Điện nhà chính',
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

          // Điện năng trên hóa đơn
          const Text(
            'Điện năng trên hóa đơn',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),

          // Khối nhập số lớn
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
                    controller: _kwhController,
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
                  'kWh',
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
            'Nhập sản lượng, không nhập số tiền thanh toán.',
            style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  /// Card hướng dẫn tìm số trên hóa đơn (Tab 0)
  Widget _buildKwhInfoCallout() {
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
                'Tìm số ở đâu trên hóa đơn?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tìm dòng “Điện năng tiêu thụ” hoặc “Sản lượng” trong kỳ ${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.blueDark,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'HÓA ĐƠN ĐIỆN • VÍ DỤ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.blueMedium,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Điện năng tiêu thụ: 250 kWh',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.blueDeep,
            ),
          ),
        ],
      ),
    );
  }

  /// Banner thông báo đầu trang Tiền điện (Tab 1)
  Widget _buildVndNoticeBanner() {
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
                  'Chỉ cần tổng tiền và thuế/phí trên hóa đơn',
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
            'Hệ thống tự ước tính theo biểu giá được cấu hình. Không cần chọn biểu giá hay nhập đơn giá bình quân trước thuế/phí.',
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

  /// Thẻ form Chế độ 2: Tiền điện (VNĐ)
  Widget _buildVndFormCard() {
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
            'Nhập từ tiền điện',
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
            controller: _sourceNameVndController,
            style: const TextStyle(fontSize: 14.5, color: AppColors.gray800),
            decoration: InputDecoration(
              hintText: 'Ví dụ: Điện nhà chính',
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

          // Tổng tiền thanh toán
          const Text(
            'Tổng tiền thanh toán',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _totalPaymentController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
            decoration: InputDecoration(
              hintText: '550.000',
              suffixText: 'VNĐ',
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
          const SizedBox(height: 16),

          // Thuế và phí trên hóa đơn
          const Text(
            'Thuế và phí trên hóa đơn',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _taxFeeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.gray800,
            ),
            decoration: InputDecoration(
              hintText: '50.000',
              suffixText: 'VNĐ',
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
            'Không bắt buộc; nếu không có, để trống hoặc nhập 0.',
            style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
          ),
          const SizedBox(height: 18),

          // Tiền điện trước thuế/phí - tự tính
          const Text(
            'Tiền điện trước thuế/phí - tự tính',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),

          // Khối tính toán tự động viền xanh đậm
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
                  _formatVnd(_calculatedPreTaxAmount.toInt()),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'VNĐ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tiền trước thuế/phí được xác định từ tổng tiền và các khoản thuế/phí bạn nhập.',
            style: TextStyle(fontSize: 11.5, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  /// Card giải thích xử lý tiền điện (Tab 1)
  Widget _buildVndInfoCallout() {
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
                  'Hệ thống xử lý tiền điện thế nào?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Hệ thống quy đổi tiền điện theo biểu giá được cấu hình khi bạn tiếp tục. Không cần nhập nguồn biểu giá hoặc đơn giá.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.blueDark,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Kết quả ước tính sẽ xuất hiện ở bước kiểm tra, sau khi hệ thống xử lý dữ liệu.',
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
