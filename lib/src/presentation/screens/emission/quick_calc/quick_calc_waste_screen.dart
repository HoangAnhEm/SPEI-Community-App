import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../config/di/di.dart';
import '../../../../domain/entities/emission_details.dart';
import '../../../../domain/repositories/emission_repository.dart';
import '../widgets/emission_calculation_method_card.dart';

/// Màn hình Tính nhanh phát thải Chất thải & nước thải (Ảnh 4)
class QuickCalcWasteScreen extends StatefulWidget {
  const QuickCalcWasteScreen({super.key});

  @override
  State<QuickCalcWasteScreen> createState() => _QuickCalcWasteScreenState();
}

class _QuickCalcWasteScreenState extends State<QuickCalcWasteScreen> {
  late WasteTypeItem _selectedWasteType;
  final TextEditingController _quantityController =
      TextEditingController(text: '18');

  bool _isCalculating = false;
  double _calculatedCo2eKg = 8.95;

  @override
  void initState() {
    super.initState();
    _selectedWasteType = WasteTypeItem.all.first;
    _calculate();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  bool get _isWastewater => _selectedWasteType.key == 'wastewater';

  String get _co2eKgFormatted {
    if (_calculatedCo2eKg == _calculatedCo2eKg.roundToDouble()) {
      return _calculatedCo2eKg.toInt().toString();
    }
    return _calculatedCo2eKg.toStringAsFixed(2).replaceAll('.', ',');
  }

  Future<void> _calculate() async {
    setState(() => _isCalculating = true);

    final quantity = double.tryParse(
            _quantityController.text.trim().replaceAll(',', '.')) ??
        0.0;

    final payload = EmissionPayload.waste(
      subCategory: _selectedWasteType.key,
      details: WasteDetails(
        unit: _isWastewater ? 'm3' : 'kg',
        quantity: quantity,
        wasteType: _selectedWasteType.key,
        wasteCode: _selectedWasteType.wasteCode,
        treatmentMethod: _selectedWasteType.treatmentMethod,
        wasteTypeName: _selectedWasteType.name,
        emissionFactorUnit: _selectedWasteType.emissionFactorUnit,
      ),
    );

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
      // Fallback
      double estimate = 0.0;
      if (_isWastewater) {
        estimate = double.parse((quantity * 0.18574).toStringAsFixed(2));
      } else {
        estimate = double.parse(
            ((quantity / 1000.0) * _selectedWasteType.emissionFactor)
                .toStringAsFixed(2));
      }
      setState(() {
        _calculatedCo2eKg = estimate;
        _isCalculating = false;
      });
    }
  }

  void _showWasteTypePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn loại chất thải',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2E1E),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: WasteTypeItem.all.length,
                separatorBuilder: (_, index) =>
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                itemBuilder: (context, index) {
                  final item = WasteTypeItem.all[index];
                  final isSelected = item.key == _selectedWasteType.key;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF1B2E1E),
                      ),
                    ),
                    subtitle: Text(
                      'Xử lý: ${item.treatmentMethod} • Đơn vị: ${item.defaultUnit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle,
                            color: AppColors.primary, size: 20)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedWasteType = item;
                        if (item.key == 'wastewater') {
                          _quantityController.text = '2';
                        } else if (_quantityController.text == '2') {
                          _quantityController.text = '18';
                        }
                      });
                      _calculate();
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tính nhanh',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2E1E),
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Chọn loại và phương pháp xử lý',
                          style: TextStyle(
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

            // 2. Nội dung cuộn
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề phân loại
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
                            Icons.delete_outline_rounded,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Chất thải & nước thải',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2E1E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Card 1: Khung chọn loại & nhập liệu
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
                          // 1.1 Loại chất thải
                          const Text(
                            'Loại chất thải',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2E1E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _showWasteTypePicker,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedWasteType.name,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1B2E1E),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down,
                                      color: Color(0xFF2E7D32)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 1.2 Phương pháp xử lý
                          const Text(
                            'Phương pháp xử lý',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2E1E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedWasteType.treatmentMethod,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1B2E1E),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 1.3 Khối lượng / thể tích
                          Text(
                            _isWastewater
                                ? 'Lượng nước thải đã xử lý'
                                : 'Khối lượng chất thải',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2E1E),
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                    controller: _quantityController,
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
                                  ),
                                ),
                                Text(
                                  _isWastewater ? 'm³' : 'kg',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
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
                      category: 'waste',
                      subCategory: _selectedWasteType.key,
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
}
