import 'package:flutter/material.dart';
import 'package:spei_community/src/core/constants/app_colors.dart';

// Màu riêng của màn này
const Color _kBlue4B7293 = Color(0xFF4B7293);

/// Loại phương thức ước tính phát thải tương ứng với 6 biến thể trong Ảnh 2
enum EmissionCalculationMethodType {
  /// Điện năng — kWh
  electricityKwh,

  /// Điện — tiền điện VND
  electricityMoney,

  /// Xe xăng — lít
  transportGasoline,

  /// Xe điện — kWh
  transportElectric,

  /// Điều hòa — R600a
  refrigerantR600a,

  /// Tủ lạnh — R32
  refrigerantR32,

  /// Gas — kg thực dùng
  gasLpg,

  /// Chất thải rắn — loại & xử lý
  wasteSolid,

  /// Chất thải nguy hại
  wasteHazardous,

  /// Nước thải
  wastewater,
}

/// Widget hiển thị box "Cách hệ thống ước tính" tái sử dụng được ở nhiều màn hình (Ảnh 2)
class EmissionCalculationMethodCard extends StatelessWidget {
  final EmissionCalculationMethodType type;
  final String? customTitle;
  final String? customHeadline;
  final String? customBody;
  final String? customFooter;

  const EmissionCalculationMethodCard({
    super.key,
    required this.type,
    this.customTitle,
    this.customHeadline,
    this.customBody,
    this.customFooter,
  });

  /// Factory tiện ích tự động phân giải loại từ category và subCategory/inputMethod
  factory EmissionCalculationMethodCard.fromCategory({
    Key? key,
    required String category,
    String? subCategory,
    String? inputType,
    String? refrigerantType,
  }) {
    EmissionCalculationMethodType resolvedType;

    switch (category) {
      case 'electricity':
        resolvedType = (inputType == 'money_vnd')
            ? EmissionCalculationMethodType.electricityMoney
            : EmissionCalculationMethodType.electricityKwh;
        break;
      case 'transportation':
        resolvedType = (subCategory == 'electric_bike' || inputType == 'kwh')
            ? EmissionCalculationMethodType.transportElectric
            : EmissionCalculationMethodType.transportGasoline;
        break;
      case 'gas':
        resolvedType = EmissionCalculationMethodType.gasLpg;
        break;
      case 'refrigerant':
        if (refrigerantType == 'R32' || subCategory == 'refrigerator') {
          resolvedType = EmissionCalculationMethodType.refrigerantR32;
        } else {
          resolvedType = EmissionCalculationMethodType.refrigerantR600a;
        }
        break;
      case 'waste':
        if (subCategory == 'wastewater') {
          resolvedType = EmissionCalculationMethodType.wastewater;
        } else if (subCategory == 'solid_waste') {
          resolvedType = EmissionCalculationMethodType.wasteSolid;
        } else {
          resolvedType = EmissionCalculationMethodType.wasteHazardous;
        }
        break;
      default:
        resolvedType = EmissionCalculationMethodType.electricityKwh;
        break;
    }

    return EmissionCalculationMethodCard(
      key: key,
      type: resolvedType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final headline = customHeadline ?? _getDefaultHeadline();
    final body = customBody ?? _getDefaultBody();
    final footer = customFooter ?? 'Phương thức, nguồn và phiên bản theo thông tin hệ thống áp dụng.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.blueBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề card có icon
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.blueMedium,
              ),
              const SizedBox(width: 8),
              Text(
                customTitle ?? 'Cách hệ thống ước tính',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Dòng headline in đậm (màu xanh nước biển thẫm)
          Text(
            headline,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.blueDeep,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),

          // Dòng body giải thích
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.blueDark,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),

          // Dòng footer ghi chú hệ thống
          Text(
            footer,
            style: const TextStyle(
              fontSize: 12,
              color: _kBlue4B7293,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getDefaultHeadline() {
    switch (type) {
      case EmissionCalculationMethodType.electricityKwh:
        return 'Hệ thống ước tính phát thải từ điện năng theo phương thức và hệ số áp dụng cho kỳ dữ liệu.';
      case EmissionCalculationMethodType.electricityMoney:
        return 'Hệ thống xử lý tiền điện và khoản thuế/phí phù hợp, rồi quy đổi theo biểu giá được cấu hình trước khi ước tính phát thải.';
      case EmissionCalculationMethodType.transportGasoline:
        return 'Hệ thống ước tính từ lượng xăng đã tiêu thụ theo phương thức và hệ số nhiên liệu áp dụng.';
      case EmissionCalculationMethodType.transportElectric:
        return 'Hệ thống ước tính từ lượng điện sạc phương tiện theo phương thức và hệ số phát thải lưới điện áp dụng.';
      case EmissionCalculationMethodType.refrigerantR600a:
        return 'Cách tính này dùng môi chất R600a. Hệ thống xử lý lượng rò rỉ/bổ sung theo thông tin môi chất và phương thức áp dụng.';
      case EmissionCalculationMethodType.refrigerantR32:
        return 'Phát thải tủ lạnh được tính dựa trên môi chất R32. Hệ thống xử lý lượng rò rỉ/bổ sung theo thông tin môi chất và phương thức áp dụng.';
      case EmissionCalculationMethodType.gasLpg:
        return 'Hệ thống ước tính từ lượng gas thực tế tiêu thụ theo phương thức LPG được cấu hình.';
      case EmissionCalculationMethodType.wasteSolid:
        return 'Hệ thống chọn phương thức phù hợp với loại chất thải và cách xử lý, đồng thời chuẩn hóa đơn vị khối lượng.';
      case EmissionCalculationMethodType.wasteHazardous:
        return 'Hệ thống chọn phương thức phù hợp với loại chất thải nguy hại và cách xử lý, đồng thời chuẩn hóa đơn vị khối lượng.';
      case EmissionCalculationMethodType.wastewater:
        return 'Hệ thống tính phát thải từ lượng nước thải xử lý qua hệ thống KCN theo hệ số được cấu hình.';
    }
  }

  String _getDefaultBody() {
    switch (type) {
      case EmissionCalculationMethodType.electricityKwh:
        return 'Dùng số điện trên hóa đơn hoặc điện năng sạc xe đã ghi nhận.';
      case EmissionCalculationMethodType.electricityMoney:
        return 'Không yêu cầu người dùng nhập biểu giá hoặc đơn giá bình quân.';
      case EmissionCalculationMethodType.transportGasoline:
        return 'Lượng tiêu thụ khác số tiền mua xăng hoặc quãng đường.';
      case EmissionCalculationMethodType.transportElectric:
        return 'Dùng điện năng thực tế đã sạc cho phương tiện trong kỳ ghi nhận.';
      case EmissionCalculationMethodType.refrigerantR600a:
        return 'Loại môi chất là giả định cách tính của sản phẩm này.';
      case EmissionCalculationMethodType.refrigerantR32:
        return 'R32 là giả định của cách tính trong sản phẩm này.';
      case EmissionCalculationMethodType.gasLpg:
        return 'Dùng khối lượng gas tịnh, không bao gồm vỏ bình.';
      case EmissionCalculationMethodType.wasteSolid:
        return 'Phương thức cho rác sinh hoạt không áp thay cho chất thải nguy hại.';
      case EmissionCalculationMethodType.wasteHazardous:
        return 'Phương thức cho chất thải nguy hại áp đúng mã và cách xử lý trong bảng.';
      case EmissionCalculationMethodType.wastewater:
        return 'Chỉ áp dụng khi xác nhận nước thải đi qua hệ thống KCN phù hợp với bảng định kèm.';
    }
  }
}
