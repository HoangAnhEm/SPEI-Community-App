import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../config/di/di.dart';
import '../../../../domain/entities/emission_details.dart';
import '../../../../domain/repositories/emission_repository.dart';
import '../widgets/emission_calculation_method_card.dart';

/// Màn hình Tính nhanh phát thải Điện gia đình (M28 - kWh & M29 - VNĐ)
class QuickCalcElectricityScreen extends StatefulWidget {
  const QuickCalcElectricityScreen({super.key});

  @override
  State<QuickCalcElectricityScreen> createState() =>
      _QuickCalcElectricityScreenState();
}

class _QuickCalcElectricityScreenState
    extends State<QuickCalcElectricityScreen> {
  // 0: Số điện (kWh), 1: Tiền điện (VNĐ)
  int _selectedTabIndex = 0;

  final TextEditingController _kwhController =
      TextEditingController(text: '250');
  final TextEditingController _vndController =
      TextEditingController(text: '500.000');

  bool _isCalculating = false;
  double _calculatedCo2eKg = 164.8;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _kwhController.dispose();
    _vndController.dispose();
    super.dispose();
  }

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

  double _parseVnd(String text) {
    final cleaned = text.replaceAll('.', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  String get _co2eKgFormatted {
    if (_calculatedCo2eKg == _calculatedCo2eKg.roundToDouble()) {
      return _calculatedCo2eKg.toInt().toString();
    }
    return _calculatedCo2eKg.toStringAsFixed(1).replaceAll('.', ',');
  }

  Future<void> _calculate() async {
    setState(() => _isCalculating = true);

    EmissionPayload payload;
    if (_selectedTabIndex == 0) {
      final kwh =
          double.tryParse(_kwhController.text.trim().replaceAll(',', '.')) ??
              0.0;
      payload = EmissionPayload.electricity(
        details: ElectricityDetails(
          inputType: 'kwh',
          inputValue: kwh,
        ),
      );
    } else {
      final money = _parseVnd(_vndController.text);
      payload = EmissionPayload.electricity(
        details: ElectricityDetails(
          inputType: 'money_vnd',
          inputValue: money,
        ),
      );
    }

    try {
      final repo = getIt<EmissionRepository>();
      final result = await repo.calculateEmission(
        CalculateEmissionRequest(payload: payload),
      );
      if (!mounted) return;
      setState(() {
        _calculatedCo2eKg = result.co2eKg;
        _isCalculating = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Fallback tính toán
      double estimate = 0.0;
      if (_selectedTabIndex == 0) {
        final kwh =
            double.tryParse(_kwhController.text.trim().replaceAll(',', '.')) ??
                0.0;
        estimate = double.parse((kwh * 0.6592).toStringAsFixed(1));
      } else {
        final money = _parseVnd(_vndController.text);
        final kwh = money / 2100.0;
        estimate = double.parse((kwh * 0.6592).toStringAsFixed(1));
      }
      setState(() {
        _calculatedCo2eKg = estimate;
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKwh = _selectedTabIndex == 0;
    final subtitle =
        isKwh ? 'Ước tính từ lượng điện sử dụng' : 'Ước tính từ tiền điện';

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
                        const Text(
                          'Tính nhanh',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2E1E),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF6B7280),
                            height: 1.25,
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

            // 2. Tab switch: [Số điện (kWh)] [Tiền điện (VNĐ)]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3EE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        label: 'Số điện (kWh)',
                        isSelected: _selectedTabIndex == 0,
                        onTap: () {
                          if (_selectedTabIndex != 0) {
                            setState(() => _selectedTabIndex = 0);
                            _calculate();
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        label: 'Tiền điện (VNĐ)',
                        isSelected: _selectedTabIndex == 1,
                        onTap: () {
                          if (_selectedTabIndex != 1) {
                            setState(() => _selectedTabIndex = 1);
                            _calculate();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Nội dung cuộn
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề loại phát thải
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.bolt,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Điện gia đình',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2E1E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Card 1: Khung nhập liệu
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
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
                          Text(
                            isKwh ? 'Điện năng tiêu thụ' : 'Tiền điện',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2E1E),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                    controller: isKwh
                                        ? _kwhController
                                        : _vndController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B2E1E),
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    onChanged: (val) {
                                      if (!isKwh) {
                                        final numVal = _parseVnd(val);
                                        if (numVal > 0) {
                                          final formatted =
                                              _formatVnd(numVal.toInt());
                                          if (formatted != val) {
                                            _vndController.value =
                                                TextEditingValue(
                                              text: formatted,
                                              selection:
                                                  TextSelection.collapsed(
                                                offset: formatted.length,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                                Text(
                                  isKwh ? 'kWh' : 'VNĐ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isKwh
                                ? 'Nhập số kWh, không nhập số tiền thanh toán.'
                                : 'Chỉ nhập tiền điện. Hệ thống tự quy đổi theo giá định biểu giá mẫu đã cấu hình.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade600,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isCalculating ? null : _calculate,
                              icon: _isCalculating
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
                                  : const Icon(Icons.calculate_outlined,
                                      size: 20),
                              label: const Text(
                                'Tính phát thải',
                                style: TextStyle(
                                  fontSize: 15,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Phát thải ước tính
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF5EE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD6EADB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Phát thải ước tính',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E3A24),
                                ),
                              ),
                              Icon(
                                Icons.eco_outlined,
                                size: 22,
                                color: Color(0xFF2E7D32),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _co2eKgFormatted,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF143E26),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'kg CO₂e',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF143E26),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Kết quả tính thử • Không lưu lịch sử',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 3: Cách hệ thống ước tính
                    EmissionCalculationMethodCard.fromCategory(
                      category: 'electricity',
                      inputType: isKwh ? 'kwh' : 'money_vnd',
                    ),
                    const SizedBox(height: 20),

                    // Nút Quay lại chọn loại
                    Center(
                      child: InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Quay lại chọn loại',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dòng chú thích minh họa ở cuối trang
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
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E5128) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }
}
