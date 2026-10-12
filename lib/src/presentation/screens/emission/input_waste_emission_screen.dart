import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/emission_details.dart';
import 'widgets/emission_month_picker_sheet.dart';

/// Màn hình nhập dữ liệu phát thải Chất thải & nước thải (Ảnh 3)
class InputWasteEmissionScreen extends StatefulWidget {
  final int? initialYear;
  final int? initialMonth;

  const InputWasteEmissionScreen({
    super.key,
    this.initialYear,
    this.initialMonth,
  });

  @override
  State<InputWasteEmissionScreen> createState() =>
      _InputWasteEmissionScreenState();
}

class _InputWasteEmissionScreenState extends State<InputWasteEmissionScreen> {
  late int _selectedYear;
  late int _selectedMonth;

  final TextEditingController _sourceNameController =
      TextEditingController();
  final TextEditingController _quantityKgController =
      TextEditingController(text: '18');
  final TextEditingController _quantityM3Controller =
      TextEditingController(text: '2');

  late WasteTypeItem _selectedWasteType;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = widget.initialYear ?? now.year;
    _selectedMonth = widget.initialMonth ?? now.month;

    // Mặc định chọn Chất thải rắn sinh hoạt
    _selectedWasteType = WasteTypeItem.all.first;
  }

  @override
  void dispose() {
    _sourceNameController.dispose();
    _quantityKgController.dispose();
    _quantityM3Controller.dispose();
    super.dispose();
  }

  bool get _isWastewater => _selectedWasteType.key == 'wastewater';

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

  Future<void> _pickWasteType() async {
    final result = await context.push<WasteTypeItem>(
      '/emission/waste/select-type',
      extra: _selectedWasteType,
    );
    if (result != null) {
      setState(() {
        _selectedWasteType = result;
      });
    }
  }

  void _handleContinue() {
    final amount = _isWastewater
        ? '${_quantityM3Controller.text} m³'
        : '${_quantityKgController.text} kg';

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã ghi nhận $amount ${_selectedWasteType.name} cho $_monthLabel. Màn hình kết quả ước tính đang được hoàn thiện.',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    // Thẻ form: Chất thải tháng này
                    _buildWasteFormCard(),
                    const SizedBox(height: 16),

                    // Card giải thích màu xanh: "Tìm số liệu từ đâu?"
                    _buildWasteInfoCallout(),
                    const SizedBox(height: 16),

                    // Cảnh báo vàng: "Nguy hại không phải rác sinh hoạt"
                    _buildHazardousWarningBanner(),
                    const SizedBox(height: 16),

                    // Card khi chọn nước thải (Ảnh 3)
                    _buildWastewaterSectionCard(),
                    const SizedBox(height: 16),

                    const SizedBox(height: 14),

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chất thải & nước thải',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E1E),
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Chọn đúng loại và cách xử lý',
                  style: TextStyle(
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

  /// Thẻ form: Chất thải tháng này
  Widget _buildWasteFormCard() {
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
            'Chất thải tháng này',
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
            controller: _sourceNameController,
            style: const TextStyle(fontSize: 14.5, color: Color(0xFF1F2937)),
            decoration: InputDecoration(
              hintText: '',
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

          // Loại chất thải đã chọn
          const Text(
            'Loại chất thải đã chọn',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickWasteType,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedWasteType.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Chọn loại khác -> Rắn / nguy hại / nước thải',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),

          // Phương pháp xử lý
          const Text(
            'Phương pháp xử lý',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedWasteType.treatmentMethod,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF2E7D32),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Theo phương pháp tương ứng trong bảng đính kèm.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),

          // Khối lượng trong tháng (nếu không phải nước thải)
          if (!_isWastewater) ...[
            const Text(
              'Khối lượng trong tháng',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),

            // Khối nhập số lớn viền xanh đậm
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
                      controller: _quantityKgController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
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
                    'kg',
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
              'Cân chất thải đã phân loại hoặc dùng phiếu thu gom.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
            ),
          ],
        ],
      ),
    );
  }

  /// Card thông tin tìm số liệu từ đâu
  Widget _buildWasteInfoCallout() {
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
              Icon(Icons.info_outline, size: 20, color: Color(0xFF1B598E)),
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
            'Cân chất thải đã phân loại hoặc dùng phiếu thu gom. Chọn cách xử lý thực tế; nếu chưa biết, chưa áp hệ số.',
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

  /// Cảnh báo vàng: "Nguy hại không phải rác sinh hoạt"
  Widget _buildHazardousWarningBanner() {
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
                  'Nguy hại không phải rác sinh hoạt',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pin, bóng đèn, dầu thải và các loại nguy hại phải ghi riêng đúng mã, phương pháp xử lý. Không dùng hệ số của chúng cho rác sinh hoạt.',
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

  /// Card đặc thù cho Nước thải (Ảnh 3)
  Widget _buildWastewaterSectionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD3E7FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Khi chọn nước thải',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4E75),
                ),
              ),
              Text(
                'ĐƠN VỊ THAY ĐỔI THEO LOẠI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B5B84),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Loại trong bảng
          const Text(
            'Loại trong bảng',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              _selectedWasteType.name,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF1F2937)),
            ),
          ),
          const SizedBox(height: 14),

          // Phương pháp xử lý
          const Text(
            'Phương pháp xử lý',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedWasteType.treatmentMethod,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF2E7D32),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Lượng nước thải đã xử lý
          const Text(
            'Lượng nước thải đã xử lý',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityM3Controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                  'm³',
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
            'Chỉ áp dụng khi xác nhận nước thải đi qua hệ thống KCN phù hợp với bảng. Không dùng cho mọi nước thải gia đình, không suy lượng thải từ hóa đơn nước.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
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
          backgroundColor: const Color(0xFF2E7D32),
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
