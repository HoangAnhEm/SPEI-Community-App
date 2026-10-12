import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/di/di.dart';
import '../../../domain/entities/emission_details.dart';
import '../../../domain/repositories/emission_repository.dart';
import '../../blocs/emission/emission_cubit.dart';
import 'family_emission_history_screen.dart';

/// Màn hình Nhập dữ liệu phát thải tháng
class EmissionDataEntryScreen extends StatefulWidget {
  final int? year;
  final int? month;
  final String? initialCategory;

  const EmissionDataEntryScreen({
    super.key,
    this.year,
    this.month,
    this.initialCategory,
  });

  @override
  State<EmissionDataEntryScreen> createState() => _EmissionDataEntryScreenState();
}

class _EmissionDataEntryScreenState extends State<EmissionDataEntryScreen> {
  late int _year;
  late int _month;
  late String _selectedCategory;

  final TextEditingController _sourceLabelController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool _isLoading = false;

  final List<String> _categories = [
    EmissionCategory.electricity,
    EmissionCategory.gas,
    EmissionCategory.waste,
    EmissionCategory.refrigerant,
    EmissionCategory.transportation,
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = widget.year ?? now.year;
    _month = widget.month ?? now.month;
    _selectedCategory = widget.initialCategory ?? EmissionCategory.electricity;
  }

  @override
  void dispose() {
    _sourceLabelController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String _getCategoryUnit(String category) {
    switch (category) {
      case EmissionCategory.electricity:
        return 'kWh';
      case EmissionCategory.gas:
        return 'kg gas';
      case EmissionCategory.waste:
        return 'kg rác';
      case EmissionCategory.refrigerant:
        return 'kg môi chất lạnh';
      case EmissionCategory.transportation:
        return 'lít nhiên liệu';
      default:
        return 'đơn vị';
    }
  }

  Future<void> _handleSubmit() async {
    final quantity = double.tryParse(_quantityController.text.replaceAll(',', '.'));
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số lượng hợp lệ (> 0)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final sourceLabel = _sourceLabelController.text.trim();
    late final EmissionPayload payload;
    switch (_selectedCategory) {
      case EmissionCategory.electricity:
        payload = EmissionPayload.electricity(
          details: ElectricityDetails(
            inputType: 'kwh',
            inputValue: quantity,
            sourceLabel: sourceLabel.isNotEmpty ? sourceLabel : 'Điện sinh hoạt',
          ),
        );
        break;
      case EmissionCategory.gas:
        payload = EmissionPayload.gas(
          subCategory: 'lpg',
          details: GasDetails(
            gasType: 'lpg',
            weightKg: quantity,
            sourceLabel: sourceLabel.isNotEmpty ? sourceLabel : 'Bình gas gia đình',
          ),
        );
        break;
      case EmissionCategory.waste:
        payload = EmissionPayload.waste(
          subCategory: 'solid_waste',
          details: WasteDetails(
            unit: 'kg',
            quantity: quantity,
            sourceLabel: sourceLabel.isNotEmpty ? sourceLabel : 'Rác sinh hoạt',
          ),
        );
        break;
      case EmissionCategory.refrigerant:
        payload = EmissionPayload.refrigerant(
          subCategory: 'air_conditioner',
          details: RefrigerantDetails(
            refrigerantType: 'R32',
            quantity: quantity,
            sourceLabel: sourceLabel.isNotEmpty ? sourceLabel : 'Điều hòa không khí',
          ),
        );
        break;
      case EmissionCategory.transportation:
        payload = EmissionPayload.transportation(
          subCategory: 'gasoline_bike',
          details: TransportationDetails(
            inputType: 'liters',
            inputValue: quantity,
            sourceLabel: sourceLabel.isNotEmpty ? sourceLabel : 'Xe máy xăng',
          ),
        );
        break;
      default:
        payload = EmissionPayload.electricity(
          details: ElectricityDetails(
            inputType: 'kwh',
            inputValue: quantity,
            sourceLabel: sourceLabel,
          ),
        );
    }

    try {
      final request = RecordHouseholdEmissionRequest(
        periodYear: _year,
        periodMonth: _month,
        payload: payload,
      );

      await getIt<EmissionRepository>().recordHouseholdEmission(request);

      if (!mounted) return;
      await context.read<EmissionCubit>().loadEmissions(year: _year, month: _month);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã ghi nhận phát thải thành công vào hệ thống!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final curMM = _month.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
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
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF1E5128),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nhập dữ liệu phát thải',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2E1E),
                        ),
                      ),
                      Text(
                        'Tháng $curMM/$_year',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chọn phân loại phát thải',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2E1E),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Grid chọn category
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        final color = EmissionCategoryTheme.getColor(cat);
                        final icon = EmissionCategoryTheme.getIcon(cat);

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.12)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? color : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 18, color: color),
                                const SizedBox(width: 8),
                                Text(
                                  EmissionCategory.getLabel(cat),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? color
                                        : const Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Tên thiết bị / nguồn phát thải
                    const Text(
                      'Tên nguồn phát thải / thiết bị',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2E1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _sourceLabelController,
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Điện nhà chính, Điều hòa phòng khách...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Số lượng tiêu thụ
                    Text(
                      'Số lượng tiêu thụ (${_getCategoryUnit(_selectedCategory)})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2E1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _quantityController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0,00',
                        suffixText: _getCategoryUnit(_selectedCategory),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nút xác nhận lưu
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Lưu bản ghi phát thải',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
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
