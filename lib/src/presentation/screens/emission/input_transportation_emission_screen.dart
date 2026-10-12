import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/emission_month_picker_sheet.dart';

/// Màn hình nhập dữ liệu phát thải Phương tiện (gồm 2 chế độ: Xe xăng & Xe điện)
class InputTransportationEmissionScreen extends StatefulWidget {
  final int? initialYear;
  final int? initialMonth;

  const InputTransportationEmissionScreen({
    super.key,
    this.initialYear,
    this.initialMonth,
  });

  @override
  State<InputTransportationEmissionScreen> createState() =>
      _InputTransportationEmissionScreenState();
}

class _InputTransportationEmissionScreenState
    extends State<InputTransportationEmissionScreen> {
  // 0: Xe xăng, 1: Xe điện
  int _selectedTabIndex = 0;

  late int _selectedYear;
  late int _selectedMonth;

  // Controllers cho Xe xăng
  final TextEditingController _gasolineSourceController =
      TextEditingController(text: 'Xe của bố');
  final TextEditingController _gasolineLitersController =
      TextEditingController(text: '12.5');

  // Controllers cho Xe điện
  final TextEditingController _evSourceController =
      TextEditingController(text: 'Xe của con');
  final TextEditingController _evKwhController =
      TextEditingController(text: '30');

  String _selectedEvChargingSource =
      'Trạm sạc / nguồn điện chưa tính ở điện nhà';

  final List<String> _evChargingSources = [
    'Trạm sạc / nguồn điện chưa tính ở điện nhà',
    'Đồng hồ sạc riêng tại nhà',
    'Sạc tại cơ quan / điểm công cộng',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = widget.initialYear ?? now.year;
    _selectedMonth = widget.initialMonth ?? now.month;

    _gasolineLitersController.addListener(_onInputChanged);
    _evKwhController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _gasolineSourceController.dispose();
    _gasolineLitersController.dispose();
    _evSourceController.dispose();
    _evKwhController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {});
  }

  String get _monthLabel =>
      'Tháng ${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear';

  bool get _isGasolineValid {
    final text = _gasolineLitersController.text.replaceAll(',', '.').trim();
    final val = double.tryParse(text);
    return val != null && val >= 0;
  }

  bool get _isEvValid {
    final text = _evKwhController.text.replaceAll(',', '.').trim();
    final val = double.tryParse(text);
    return val != null && val >= 0;
  }

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
    if (_selectedTabIndex == 0 && !_isGasolineValid) {
      return;
    }
    if (_selectedTabIndex == 1 && !_isEvValid) {
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedTabIndex == 0
              ? 'Đã ghi nhận ${_gasolineLitersController.text} lít xăng cho $_monthLabel. Màn hình kết quả ước tính đang được hoàn thiện.'
              : 'Đã ghi nhận ${_evKwhController.text} kWh sạc xe cho $_monthLabel. Màn hình kết quả ước tính đang được hoàn thiện.',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasGasolineError = _selectedTabIndex == 0 && !_isGasolineValid;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Toggle tab switch: [Xe xăng] [Xe điện]
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
                        'Ghi lượng xăng đã tiêu thụ, không phải quãng đường hay số tiền đổ xăng.',
                      ),
                      const SizedBox(height: 16),

                      // 2. Thẻ form: Xăng đã tiêu thụ
                      _buildGasolineFormCard(),
                      const SizedBox(height: 16),

                      // 3. Card giải thích màu xanh: "Tìm số liệu từ đâu?"
                      _buildGasolineInfoCallout(),
                    ] else ...[
                      // 1. Cảnh báo vàng: Nhắc nhở khi nhập liệu xe điện
                      _buildEvWarningBanner(),
                      const SizedBox(height: 16),

                      // 2. Thẻ form: Điện sạc xe
                      _buildEvFormCard(),
                      const SizedBox(height: 16),

                      // 3. Card giải thích: "Tìm số kWh sạc ở đâu?"
                      _buildEvInfoCallout(),
                    ],

                    const SizedBox(height: 24),

                    // Nút Tiếp tục & xem ước tính
                    _buildBottomActionButton(),
                    const SizedBox(height: 8),

                    // Thông báo lỗi nếu có hoặc dòng hướng dẫn
                    if (hasGasolineError)
                      const Center(
                        child: Text(
                          'Sửa lượng xăng để tiếp tục ghi nhận tháng.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: Text(
                          'Hệ thống tính khi bạn tiếp tục. Kiểm tra kết quả trước khi xác nhận lưu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Footer
                    const Center(
                      child: Text(
                        'Bản mẫu giao diện • Dữ liệu minh họa',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
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
        ? 'Ghi nhận nhiên liệu trong tháng'
        : 'Điện dùng để sạc xe trong tháng';

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
                color: Color(0xFF1E5128),
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
                  'Phương tiện',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E1E),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
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

  /// Switch tab chế độ [Xe xăng] | [Xe điện]
  Widget _buildTopTabSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF2EC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  if (_selectedTabIndex != 0) {
                    setState(() => _selectedTabIndex = 0);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 0
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Xe xăng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedTabIndex == 0
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: _selectedTabIndex == 0
                          ? Colors.white
                          : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  if (_selectedTabIndex != 1) {
                    setState(() => _selectedTabIndex = 1);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 1
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Xe điện',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedTabIndex == 1
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: _selectedTabIndex == 1
                          ? Colors.white
                          : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
            color: Color(0xFFE8F3E8),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/ic_sprout_smile.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.eco_rounded,
                color: Color(0xFF2E7D32),
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
              color: Color(0xFF2E4032),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Thẻ form Chế độ 1: Xe xăng (Ảnh 3)
  Widget _buildGasolineFormCard() {
    final isError = !_isGasolineValid;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xăng đã tiêu thụ',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 14),

          // Tháng ghi nhận
          const Text(
            'Tháng ghi nhận',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
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
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _monthLabel,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF2E7D32),
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
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _gasolineSourceController,
            style: const TextStyle(fontSize: 14.5, color: Color(0xFF1F2937)),
            decoration: InputDecoration(
              hintText: 'Ví dụ: Xe của bố',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Có thể bỏ trống. Đặt tên để phân biệt các bản ghi cùng loại trong tháng.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),

          // Lượng xăng tiêu thụ
          const Text(
            'Lượng xăng tiêu thụ',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),

          // Khối nhập số lớn
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isError
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFE5E7EB),
                width: isError ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _gasolineLitersController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isError
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF1B2E1E),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                  ),
                ),
                const Text(
                  'lít',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (isError)
            const Text(
              'Số lít không hợp lệ. Nhập số từ 0 trở lên, ví dụ 12,5; không nhập chữ hoặc số âm.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFFDC2626),
                height: 1.3,
              ),
            )
          else
            const Text(
              'Có thể nhập phần thập phân bằng dấu phẩy.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
            ),
        ],
      ),
    );
  }

  /// Card thông tin tìm số liệu từ đâu (Xe xăng)
  Widget _buildGasolineInfoCallout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E8F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Color(0xFF1B598E),
              ),
              SizedBox(width: 8),
              Text(
                'Tìm số liệu từ đâu?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B4E75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Dựa vào hóa đơn đổ xăng và lượng còn trong bình: lượng đầu kỳ + lượng mua – lượng cuối kỳ. Lượng mua không luôn bằng lượng đã tiêu thụ.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF2B5B84),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Cảnh báo vàng: Nhắc nhở khi nhập liệu xe điện (Ảnh 4)
  Widget _buildEvWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF6E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: Color(0xFFD97706),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nhắc nhở khi nhập liệu xe điện',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Nếu điện sạc đã được tính trong Điện gia đình thì không cần nhập riêng xe điện. Chỉ nhập riêng khi điện sạc chưa được tính chung.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF92400E),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Thẻ form Chế độ 2: Xe điện (Ảnh 4)
  Widget _buildEvFormCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điện sạc xe',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 14),

          // Tháng ghi nhận
          const Text(
            'Tháng ghi nhận',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
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
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _monthLabel,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF2E7D32),
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
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _evSourceController,
            style: const TextStyle(fontSize: 14.5, color: Color(0xFF1F2937)),
            decoration: InputDecoration(
              hintText: 'Ví dụ: Xe của con',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Có thể bỏ trống. Đặt tên để phân biệt các bản ghi cùng loại trong tháng.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),

          // Điện năng sạc trong tháng
          const Text(
            'Điện năng sạc trong tháng',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),

          // Khối nhập số lớn
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF2E7D32),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _evKwhController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E1E),
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
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Nhập điện lấy từ nguồn sạc, không nhập dung lượng pin.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),

          // Nguồn sạc
          const Text(
            'Nguồn sạc',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedEvChargingSource,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF2E7D32),
                ),
                items: _evChargingSources.map((source) {
                  return DropdownMenuItem<String>(
                    value: source,
                    child: Text(
                      source,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null) {
                    setState(() {
                      _selectedEvChargingSource = newVal;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card thông tin tìm số kWh sạc ở đâu (Xe điện)
  Widget _buildEvInfoCallout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E8F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Color(0xFF1B598E),
              ),
              SizedBox(width: 8),
              Text(
                'Tìm số kWh sạc ở đâu?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B4E75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Xem đồng hồ riêng cho bộ sạc hoặc lịch sử kWh trong ứng dụng/trạm sạc. Cộng các lượt sạc của tháng ${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2B5B84),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nếu điện sạc đã được tính trong điện gia đình, bỏ qua ghi nhận riêng xe điện.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF2B5B84),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Nút bấm hoàn tất
  Widget _buildBottomActionButton() {
    final hasGasolineError = _selectedTabIndex == 0 && !_isGasolineValid;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: hasGasolineError ? null : _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFC7D3C5),
          disabledForegroundColor: Colors.white70,
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
