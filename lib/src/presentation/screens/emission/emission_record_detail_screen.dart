import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../src/core/constants/app_colors.dart';
import '../../../domain/entities/household_emission.dart';
import 'family_emission_history_screen.dart';

/// Màn hình Xem chi tiết bản ghi phát thải
class EmissionRecordDetailScreen extends StatelessWidget {
  final HouseholdEmission? record;

  const EmissionRecordDetailScreen({
    super.key,
    this.record,
  });

  @override
  Widget build(BuildContext context) {
    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết bản ghi')),
        body: const Center(child: Text('Không tìm thấy bản ghi phát thải')),
      );
    }

    final item = record!;
    final catColor = EmissionCategoryTheme.getColor(item.category);
    final catIcon = EmissionCategoryTheme.getIcon(item.category);
    final dt = item.createdAt;
    final createdDateStr =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

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
                  const Text(
                    'Chi tiết bản ghi phát thải',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E1E),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Card thông số chính
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
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
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: catColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(catIcon, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item.details.sourceLabel?.isNotEmpty == true
                                ? item.details.sourceLabel!
                                : item.categoryLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2E1E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.categoryLabel,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F8F3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${item.co2eKgFormatted} kg CO₂e',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF143E26),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card thông tin chi tiết
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin phát thải',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2E1E),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            'Kỳ ghi nhận',
                            'Tháng ${item.periodMonth.toString().padLeft(2, '0')}/${item.periodYear}',
                          ),
                          const Divider(height: 20),
                          _buildDetailRow('Phân loại', item.categoryLabel),
                          if (item.subCategoryLabel.isNotEmpty) ...[
                            const Divider(height: 20),
                            _buildDetailRow(
                                'Phân loại con', item.subCategoryLabel),
                          ],
                          const Divider(height: 20),
                          _buildDetailRow('Thời gian nhập', createdDateStr),
                          if (item.createdByName.isNotEmpty) ...[
                            const Divider(height: 20),
                            _buildDetailRow('Người nhập', item.createdByName),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nút chỉnh sửa
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pushReplacement('/emission/record-edit',
                              extra: item);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text(
                          'Chỉnh sửa bản ghi này',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B2E1E),
          ),
        ),
      ],
    );
  }
}
