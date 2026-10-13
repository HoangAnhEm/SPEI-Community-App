import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/di/di.dart';
import '../../../domain/entities/emission_details.dart';
import '../../../domain/entities/household_emission.dart';
import '../../../domain/repositories/emission_repository.dart';
import '../../blocs/emission/emission_cubit.dart';
import 'package:spei_community/src/core/constants/app_colors.dart';

/// Màn hình Chỉnh sửa bản ghi phát thải
class EmissionRecordEditScreen extends StatefulWidget {
  final HouseholdEmission? record;

  const EmissionRecordEditScreen({
    super.key,
    this.record,
  });

  @override
  State<EmissionRecordEditScreen> createState() =>
      _EmissionRecordEditScreenState();
}

class _EmissionRecordEditScreenState extends State<EmissionRecordEditScreen> {
  late final TextEditingController _sourceLabelController;
  late final TextEditingController _valueController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _sourceLabelController = TextEditingController(
      text: r?.details.sourceLabel ?? '',
    );
    _valueController = TextEditingController(
      text: r != null ? r.co2eKgFormatted : '',
    );
  }

  @override
  void dispose() {
    _sourceLabelController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final r = widget.record;
    if (r == null) {
      context.pop();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = RecordHouseholdEmissionRequest(
        periodYear: r.periodYear,
        periodMonth: r.periodMonth,
        payload: EmissionPayload(
          category: r.category,
          subCategory: r.subCategory,
          details: r.details,
        ),
      );

      await getIt<EmissionRepository>().recordHouseholdEmission(request);

      if (!mounted) return;
      await context
          .read<EmissionCubit>()
          .loadEmissions(year: r.periodYear, month: r.periodMonth);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật bản ghi phát thải thành công!'),
          backgroundColor: AppColors.greenPrimary,
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
    final item = widget.record;

    return Scaffold(
      backgroundColor: AppColors.surfaceOffWhite,
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
                        color: AppColors.greenDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Chỉnh sửa bản ghi phát thải',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.greenSurfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.greenBorderPale),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.greenPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Phân loại: ${item?.categoryLabel ?? "Phát thải gia đình"}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.greenDeep,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tên vị trí / thiết bị
                    const Text(
                      'Tên thiết bị / vị trí',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
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

                    // Lượng phát thải ước tính (kg CO2e)
                    const Text(
                      'Lượng phát thải (kg CO₂e)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _valueController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0,00',
                        suffixText: 'kg CO₂e',
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

                    // Nút lưu
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenPrimary,
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
                                'Lưu thay đổi',
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
