import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../config/di/di.dart';
import '../../../../domain/entities/emission_details.dart';
import '../../../../domain/repositories/emission_repository.dart';
import '../widgets/emission_calculation_method_card.dart';

/// Màn hình Tính nhanh phát thải Môi chất làm lạnh (Ảnh 3 - Tủ lạnh & Điều hòa)
class QuickCalcRefrigerantScreen extends StatefulWidget {
  const QuickCalcRefrigerantScreen({super.key});

  @override
  State<QuickCalcRefrigerantScreen> createState() =>
      _QuickCalcRefrigerantScreenState();
}

class _QuickCalcRefrigerantScreenState
    extends State<QuickCalcRefrigerantScreen> {
  // 0: Tủ lạnh (R32), 1: Điều hòa (R600a)
  int _selectedTabIndex = 0;

  final TextEditingController _fridgeController = TextEditingController(
    text: '0,05',
  );
  final TextEditingController _acController = TextEditingController(
    text: '0,02',
  );

  bool _isCalculating = false;
  double _calculatedCo2eKg = 33.75;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _fridgeController.dispose();
    _acController.dispose();
    super.dispose();
  }

  String get _co2eKgFormatted {
    if (_calculatedCo2eKg == _calculatedCo2eKg.roundToDouble()) {
      return _calculatedCo2eKg.toInt().toString();
    }
    return _calculatedCo2eKg.toStringAsFixed(2).replaceAll('.', ',');
  }

  Future<void> _calculate() async {
    setState(() => _isCalculating = true);

    EmissionPayload payload;
    if (_selectedTabIndex == 0) {
      final kg =
          double.tryParse(_fridgeController.text.trim().replaceAll(',', '.')) ??
          0.0;
      payload = EmissionPayload.refrigerant(
        subCategory: 'refrigerator',
        details: RefrigerantDetails(refrigerantType: 'R32', quantity: kg),
      );
    } else {
      final kg =
          double.tryParse(_acController.text.trim().replaceAll(',', '.')) ??
          0.0;
      payload = EmissionPayload.refrigerant(
        subCategory: 'air_conditioner',
        details: RefrigerantDetails(refrigerantType: 'R600a', quantity: kg),
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
      // Fallback: R32 factor 675, R600a factor 3
      double estimate = 0.0;
      if (_selectedTabIndex == 0) {
        final kg =
            double.tryParse(
              _fridgeController.text.trim().replaceAll(',', '.'),
            ) ??
            0.0;
        estimate = double.parse((kg * 675.0).toStringAsFixed(2));
      } else {
        final kg =
            double.tryParse(_acController.text.trim().replaceAll(',', '.')) ??
            0.0;
        estimate = double.parse((kg * 3.0).toStringAsFixed(2));
      }
      setState(() {
        _calculatedCo2eKg = estimate;
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFridge = _selectedTabIndex == 0;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
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
                        color: AppColors.greenDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Môi chất làm lạnh',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ước tính từ lượng môi chất',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.gray500,
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
                            Image.asset(
                              'assets/icons/logo.png',
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Tab switch: [Tủ lạnh] [Điều hòa]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.segmentBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        label: 'Tủ lạnh',
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
                        label: 'Điều hòa',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề phân loại con
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.green50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isFridge
                                ? Icons.kitchen_outlined
                                : Icons.air_outlined,
                            color: AppColors.greenPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isFridge ? 'Tủ lạnh' : 'Điều hòa',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
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
                          // Dòng ghi chú trên đầu: Môi chất cố định
                          Text(
                            isFridge
                                ? 'Môi chất cố định: R32 • Giả định cách tính trong sản phẩm, không áp dụng cho mọi tủ lạnh.'
                                : 'Môi chất cố định: R600a • Giả định cách tính trong sản phẩm, không áp dụng cho mọi điều hòa.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.blueMedium,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Lượng môi chất rò rỉ / bổ sung',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                    controller: isFridge
                                        ? _fridgeController
                                        : _acController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  'kg',
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
                            isFridge
                                ? '50 g = 0,05 kg. Không nhập toàn bộ lượng nạp của thiết bị.'
                                : '20 g = 0,02 kg. Không suy lượng môi chất từ thời gian sử dụng.',
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
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.calculate_outlined,
                                      size: 20,
                                    ),
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
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.greenBorder),
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
                                  color: AppColors.greenDarker,
                                ),
                              ),
                              Icon(
                                Icons.eco_outlined,
                                size: 22,
                                color: AppColors.greenPrimary,
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
                                  color: AppColors.greenDeep,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'kg CO₂e',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greenDeep,
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
                          color: AppColors.gray500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 3: Cách hệ thống ước tính
                    EmissionCalculationMethodCard.fromCategory(
                      category: 'refrigerant',
                      subCategory: isFridge
                          ? 'refrigerator'
                          : 'air_conditioner',
                      refrigerantType: isFridge ? 'R32' : 'R600a',
                    ),
                    const SizedBox(height: 20),

                    // Nút Quay lại chọn loại
                    Center(
                      child: InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: AppColors.primary,
                              ),
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? AppColors.textGreenMedium
                  : AppColors.segmentUnselectedText,
            ),
          ),
        ),
      ),
    );
  }
}
