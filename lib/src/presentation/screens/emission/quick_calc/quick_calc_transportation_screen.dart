import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../config/di/di.dart';
import '../../../../domain/entities/emission_details.dart';
import '../../../../domain/repositories/emission_repository.dart';
import '../widgets/emission_calculation_method_card.dart';

/// Màn hình Tính nhanh phát thải Phương tiện (M30 - Xe xăng & M31 - Xe điện)
class QuickCalcTransportationScreen extends StatefulWidget {
  const QuickCalcTransportationScreen({super.key});

  @override
  State<QuickCalcTransportationScreen> createState() =>
      _QuickCalcTransportationScreenState();
}

class _QuickCalcTransportationScreenState
    extends State<QuickCalcTransportationScreen> {
  // 0: Xe xăng, 1: Xe điện
  int _selectedTabIndex = 0;

  final TextEditingController _gasolineController = TextEditingController(
    text: '12,5',
  );
  final TextEditingController _evController = TextEditingController(text: '30');

  bool _isCalculating = false;
  double _calculatedCo2eKg = 28.9;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _gasolineController.dispose();
    _evController.dispose();
    super.dispose();
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
      final liters =
          double.tryParse(
            _gasolineController.text.trim().replaceAll(',', '.'),
          ) ??
          0.0;
      payload = EmissionPayload.transportation(
        subCategory: 'gasoline_bike',
        details: TransportationDetails(inputType: 'liters', inputValue: liters),
      );
    } else {
      final kwh =
          double.tryParse(_evController.text.trim().replaceAll(',', '.')) ??
          0.0;
      payload = EmissionPayload.transportation(
        subCategory: 'electric_bike',
        details: TransportationDetails(inputType: 'kwh', inputValue: kwh),
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
        final liters =
            double.tryParse(
              _gasolineController.text.trim().replaceAll(',', '.'),
            ) ??
            0.0;
        estimate = double.parse((liters * 2.31).toStringAsFixed(1));
      } else {
        final kwh =
            double.tryParse(_evController.text.trim().replaceAll(',', '.')) ??
            0.0;
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
    final isGasoline = _selectedTabIndex == 0;
    final subtitle = isGasoline
        ? 'Ước tính từ nhiên liệu tiêu thụ'
        : 'Ước tính từ điện năng sạc';

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tính nhanh',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
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

            // 2. Tab switch: [Xe xăng] [Xe điện]
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
                        label: 'Xe xăng',
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
                        label: 'Xe điện',
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
                    // Tiêu đề loại phát thải
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.green50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.directions_car_outlined,
                            color: AppColors.greenPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Phương tiện',
                          style: TextStyle(
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
                          Text(
                            isGasoline
                                ? 'Lượng xăng tiêu thụ'
                                : 'Điện năng dùng để sạc',
                            style: const TextStyle(
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
                                    controller: isGasoline
                                        ? _gasolineController
                                        : _evController,
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
                                  isGasoline ? 'lít' : 'kWh',
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
                            isGasoline
                                ? 'Nhập lượng xăng thực dùng, không nhập quãng đường.'
                                : 'Nhập điện lấy từ nguồn sạc, không nhập dung lượng pin.',
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
                      category: 'transportation',
                      subCategory: isGasoline
                          ? 'gasoline_bike'
                          : 'electric_bike',
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
