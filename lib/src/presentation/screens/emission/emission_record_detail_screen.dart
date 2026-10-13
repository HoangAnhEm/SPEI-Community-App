import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../src/core/constants/app_colors.dart';
import '../../../config/di/di.dart';
import '../../../domain/entities/emission_details.dart';
import '../../../domain/entities/household_emission.dart';
import '../../../domain/repositories/emission_repository.dart';
import '../../blocs/emission/emission_cubit.dart';
import '../common/custom_success_screen.dart';
import 'widgets/emission_calculation_method_card.dart';

// Màu riêng của màn này
const Color _kGreyLightEEEEEE = Color(0xFFEEEEEE);
const Color _kRedFCA5A5 = Color(0xFFFCA5A5);
const Color _kRedLightFEF2F2 = Color(0xFFFEF2F2);

/// Màn hình Chi tiết bản ghi phát thải đã lưu (M36 / Ảnh 2)
class EmissionRecordDetailScreen extends StatefulWidget {
  final HouseholdEmission? record;

  const EmissionRecordDetailScreen({
    super.key,
    this.record,
  });

  @override
  State<EmissionRecordDetailScreen> createState() =>
      _EmissionRecordDetailScreenState();
}

class _EmissionRecordDetailScreenState extends State<EmissionRecordDetailScreen> {
  bool _isDeleting = false;

  void _navigateToEdit(HouseholdEmission record) {
    final extra = {
      'editRecord': record,
      'year': record.periodYear,
      'month': record.periodMonth,
    };
    switch (record.category) {
      case 'electricity':
        context.push('/emission/input/electricity', extra: extra);
        break;
      case 'transportation':
        context.push('/emission/input/transportation', extra: extra);
        break;
      case 'gas':
        context.push('/emission/input/gas', extra: extra);
        break;
      case 'refrigerant':
        context.push('/emission/input/refrigerant', extra: extra);
        break;
      case 'waste':
        context.push('/emission/input/waste', extra: extra);
        break;
      default:
        context.push('/emission/input/electricity', extra: extra);
        break;
    }
  }

  Future<void> _handleDelete(HouseholdEmission item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xác nhận xóa bản ghi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa bản ghi phát thải ${item.categoryLabel} này? Thao tác này không thể hoàn tác.',
          style: const TextStyle(fontSize: 14, color: AppColors.gray600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.gray500)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Xóa bản ghi'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isDeleting = true);

    try {
      final repo = getIt<EmissionRepository>();
      await repo.deleteHouseholdEmission(item.id);

      // Cập nhật lại danh sách phát thải ở nền
      try {
        getIt<EmissionCubit>().loadEmissions(
          year: item.periodYear,
          month: item.periodMonth,
        );
      } catch (_) {}

      if (!mounted) return;

      final monthStr = item.periodMonth.toString().padLeft(2, '0');
      final successArgs = CustomSuccessArgs(
        title: 'Xóa bản ghi thành công!',
        subtitle:
            'Bản ghi phát thải ${item.categoryLabel} tháng $monthStr/${item.periodYear} đã được xóa khỏi hệ thống.',
        cardTag: 'Phát thải gia đình',
        cardHighlightText: '${item.co2eKgFormatted} kg CO₂e',
        cardDescription: 'Dữ liệu phát thải của hộ gia đình đã được cập nhật lại.',
        buttonText: 'Về lịch sử phát thải',
        onButtonPressedWithContext: (ctx) {
          ctx.go('/emission/history', extra: {
            'year': item.periodYear,
            'month': item.periodMonth,
          });
        },
      );

      context.go('/common-success', extra: successArgs);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.red600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String _getMethodLabel(HouseholdEmission item) {
    final details = item.details;
    switch (item.category) {
      case 'electricity':
        final isMoney = details is ElectricityDetails
            ? details.isMoney
            : details.raw['input_type'] == 'money_vnd';
        return isMoney ? 'Tiền điện (VNĐ)' : 'Số điện (kWh)';
      case 'transportation':
        final isElectric = item.subCategory == 'electric_bike' ||
            (details is TransportationDetails
                ? details.isKwh
                : details.raw['input_type'] == 'kwh');
        return isElectric ? 'Xe điện (kWh)' : 'Xe xăng (lít)';
      case 'gas':
        return 'Số kg gas thực dùng';
      case 'refrigerant':
        final refType = details is RefrigerantDetails
            ? details.refrigerantType
            : (details.raw['refrigerant_type'] as String? ??
                (item.subCategory == 'refrigerator' ? 'R32' : 'R600a'));
        return '${item.subCategoryLabel} ($refType)';
      case 'waste':
        final tMethod = details is WasteDetails
            ? details.treatmentMethod
            : details.raw['treatment_method'] as String?;
        return tMethod?.isNotEmpty == true
            ? '${item.subCategoryLabel} ($tMethod)'
            : item.subCategoryLabel;
      default:
        return item.categoryLabel;
    }
  }

  String _getAmountLabel(HouseholdEmission item) {
    final details = item.details;
    switch (item.category) {
      case 'electricity':
        final isMoney = details is ElectricityDetails
            ? details.isMoney
            : details.raw['input_type'] == 'money_vnd';
        final val = details is ElectricityDetails
            ? details.inputValue
            : (details.raw['input_value'] as num?)?.toDouble();
        if (isMoney) {
          return '${_formatNumber(val)} VNĐ';
        }
        return '${_formatNumber(val)} kWh';
      case 'transportation':
        final isElectric = item.subCategory == 'electric_bike' ||
            (details is TransportationDetails
                ? details.isKwh
                : details.raw['input_type'] == 'kwh');
        final val = details is TransportationDetails
            ? details.inputValue
            : (details.raw['input_value'] as num?)?.toDouble();
        return '${_formatNumber(val)} ${isElectric ? 'kWh' : 'lít'}';
      case 'gas':
        final val = details is GasDetails
            ? details.weightKg
            : ((details.raw['weight_kg'] as num?)?.toDouble() ??
                (details.raw['input_value'] as num?)?.toDouble());
        return '${_formatNumber(val)} kg';
      case 'refrigerant':
        final val = details is RefrigerantDetails
            ? details.quantity
            : ((details.raw['quantity'] as num?)?.toDouble() ??
                (details.raw['input_value'] as num?)?.toDouble());
        return '${_formatNumber(val)} kg';
      case 'waste':
        final val = details is WasteDetails
            ? details.quantity
            : ((details.raw['quantity'] as num?)?.toDouble() ??
                (details.raw['input_value'] as num?)?.toDouble());
        final unit = details is WasteDetails
            ? details.unit
            : (details.raw['unit'] as String? ??
                (item.subCategory == 'wastewater' ? 'm³' : 'kg'));
        return '${_formatNumber(val)} $unit';
      default:
        return '0';
    }
  }

  String _formatNumber(double? val) {
    if (val == null) return '0';
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toString().replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết bản ghi')),
        body: const Center(child: Text('Không tìm thấy bản ghi phát thải')),
      );
    }

    final item = widget.record!;
    final monthStr = item.periodMonth.toString().padLeft(2, '0');
    final dt = item.createdAt;
    final createdDateOnlyStr =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final sourceName = item.details.sourceLabel?.isNotEmpty == true
        ? item.details.sourceLabel!
        : item.categoryLabel;

    return Scaffold(
      backgroundColor: AppColors.surfaceOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header trên cùng (Ảnh 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/emission/history', extra: {
                          'year': item.periodYear,
                          'month': item.periodMonth,
                        });
                      }
                    },
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
                          'Chi tiết bản ghi',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.categoryLabel} • Tháng $monthStr/${item.periodYear}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.gray500,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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

            // 2. Nội dung chính
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge: (✔) Đã ghi nhận
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check,
                              size: 14, color: AppColors.greenPrimary),
                          SizedBox(width: 4),
                          Text(
                            'Đã ghi nhận',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greenPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Box 1: Phát thải của bản ghi (Ảnh 2)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
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
                                'Phát thải của bản ghi',
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
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                item.co2eKgFormatted.replaceAll('.', ','),
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
                    const SizedBox(height: 16),

                    // Box 2: Dữ liệu đã lưu (Ảnh 2)
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
                          const Text(
                            'Dữ liệu đã lưu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Loại phát thải', item.categoryLabel),
                          const SizedBox(height: 14),
                          _buildInfoRow('Tên nguồn', sourceName),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                              'Tháng ghi nhận', '$monthStr/${item.periodYear}'),
                          const SizedBox(height: 14),
                          _buildInfoRow('Ngày nhập', createdDateOnlyStr),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: _kGreyLightEEEEEE),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                              'Phương thức', _getMethodLabel(item)),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                              'Lượng ghi nhận', _getAmountLabel(item)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Box 3: Cách hệ thống ước tính (Ảnh 2)
                    EmissionCalculationMethodCard.fromCategory(
                      category: item.category,
                      subCategory: item.subCategory,
                      inputType: item.details is ElectricityDetails
                          ? (item.details as ElectricityDetails).inputType
                          : (item.details is TransportationDetails
                              ? (item.details as TransportationDetails).inputType
                              : item.details.raw['input_type'] as String?),
                      refrigerantType: item.details is RefrigerantDetails
                          ? (item.details as RefrigerantDetails).refrigerantType
                          : item.details.raw['refrigerant_type'] as String?,
                    ),
                    const SizedBox(height: 24),

                    // Nút 1: Chỉnh sửa bản ghi (Ảnh 2)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isDeleting ? null : () => _navigateToEdit(item),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text(
                          'Chỉnh sửa bản ghi',
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
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nút 2: Xóa bản ghi (Ảnh 2)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isDeleting ? null : () => _handleDelete(item),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _kRedLightFEF2F2,
                          foregroundColor: AppColors.red600,
                          side: const BorderSide(color: _kRedFCA5A5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.red600),
                                ),
                              )
                            : const Text(
                                'Xóa bản ghi',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.red600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dòng chú thích minh họa ở cuối trang (Ảnh 2)
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            color: Colors.grey.shade600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
