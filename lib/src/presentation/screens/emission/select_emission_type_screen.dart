import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/emission_details.dart';

/// Item model cho danh sách loại phát thải
class EmissionTypeOption {
  final String categoryKey;
  final String title;
  final String subtitle;
  final IconData icon;

  const EmissionTypeOption({
    required this.categoryKey,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Màn hình "Chọn loại phát thải"
/// Được điều hướng tới từ nút "+ Nhập dữ liệu tháng ..." tại màn Phát thải gia đình.
class SelectEmissionTypeScreen extends StatefulWidget {
  final int? year;
  final int? month;
  final String? initialCategory;

  const SelectEmissionTypeScreen({
    super.key,
    this.year,
    this.month,
    this.initialCategory,
  });

  @override
  State<SelectEmissionTypeScreen> createState() => _SelectEmissionTypeScreenState();
}

class _SelectEmissionTypeScreenState extends State<SelectEmissionTypeScreen> {
  late int _year;
  late int _month;

  final List<EmissionTypeOption> _options = const [
    EmissionTypeOption(
      categoryKey: EmissionCategory.electricity,
      title: 'Điện gia đình',
      subtitle: 'kWh / VNĐ',
      icon: Icons.bolt_outlined,
    ),
    EmissionTypeOption(
      categoryKey: EmissionCategory.transportation,
      title: 'Phương tiện',
      subtitle: 'Xe xăng · lít / Xe điện · kWh',
      icon: Icons.directions_car_outlined,
    ),
    EmissionTypeOption(
      categoryKey: EmissionCategory.refrigerant,
      title: 'Môi chất làm lạnh',
      subtitle: 'Tủ lạnh / Điều hòa · kg',
      icon: Icons.kitchen_outlined,
    ),
    EmissionTypeOption(
      categoryKey: EmissionCategory.gas,
      title: 'Gas',
      subtitle: 'kg',
      icon: Icons.local_fire_department_outlined,
    ),
    EmissionTypeOption(
      categoryKey: EmissionCategory.waste,
      title: 'Chất thải & nước thải',
      subtitle: 'kg / m³',
      icon: Icons.delete_outline_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = widget.year ?? now.year;
    _month = widget.month ?? now.month;
  }

  void _onSelectOption(EmissionTypeOption option) {
    // Lưu ý từ user: "màn này sẽ nav đi nhiều màn khác tuỳ lựa chọn nhưng chưa code vội"
    // Tạm thời hiển thị SnackBar thông báo phản hồi thao tác người dùng.
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã chọn ${option.title} (Tháng $_month/$_year). Biểu mẫu nhập liệu sẽ sớm được cập nhật.',
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
            // Header: [Nút quay lại] [Chọn loại phát thải] [Logo avatar]
            _buildHeader(context),

            // Nội dung cuộn
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card thông tin: "Bắt đầu từ hoạt động của bạn"
                    _buildInfoCalloutCard(),

                    const SizedBox(height: 18),

                    // Danh sách 5 loại phát thải
                    ..._options.map((option) => _buildOptionCard(option)),

                    const SizedBox(height: 48),

                    // Footer ghi chú: "Bản mẫu giao diện • Dữ liệu minh họa"
                    const Center(
                      child: Text(
                        'Bản mẫu giao diện • Dữ liệu minh họa',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Header chuẩn theo Thiết kế
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Nút quay lại bo tròn trắng
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

          // Tiêu đề
          const Expanded(
            child: Text(
              'Chọn loại phát thải',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2E1E),
                letterSpacing: -0.3,
              ),
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

  /// 2. Hộp thông báo màu xanh dương nhạt (Info Callout)
  Widget _buildInfoCalloutCard() {
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
                'Bắt đầu từ hoạt động của bạn',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B4E75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Điện, di chuyển hay sinh hoạt đều có loại số liệu riêng. Chọn một nguồn bên dưới để mở biểu mẫu phù hợp.',
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF2B5B84),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Thẻ card lựa chọn loại phát thải
  Widget _buildOptionCard(EmissionTypeOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onSelectOption(option),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon trong khối vuông xanh nhạt bo góc
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF6EE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDBEEDB)),
                  ),
                  child: Center(
                    child: Icon(
                      option.icon,
                      color: const Color(0xFF2E7D32),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Tiêu đề & phụ đề
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Icon chevron điều hướng bên phải (>)
                const Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
