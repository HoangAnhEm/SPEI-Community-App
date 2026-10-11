import 'emission_details.dart';

/// Kết quả tính toán phát thải trả về từ API /emission/calculate
class EmissionResultResponse {
  final String category;
  final String? subCategory;
  final double co2eKg;
  final double co2eTon;
  final EmissionDetails details;
  final Map<String, dynamic> rawDetails;
  final DateTime createdAt;

  const EmissionResultResponse({
    required this.category,
    this.subCategory,
    required this.co2eKg,
    required this.co2eTon,
    required this.details,
    required this.rawDetails,
    required this.createdAt,
  });

  String get categoryLabel => EmissionCategory.getLabel(category);
  String get subCategoryLabel => EmissionCategory.getSubCategoryLabel(subCategory);

  /// Trả về số ký tự thập phân hiển thị đẹp mắt
  String get co2eKgFormatted => co2eKg.toStringAsFixed(2);
  String get co2eTonFormatted => co2eTon.toStringAsFixed(4);

  factory EmissionResultResponse.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] as String? ?? '';
    final subCat = json['sub_category'] as String?;
    final detailsMap = json['details'] as Map<String, dynamic>? ?? {};

    return EmissionResultResponse(
      category: cat,
      subCategory: subCat,
      co2eKg: (json['co2e_kg'] as num?)?.toDouble() ?? 0.0,
      co2eTon: (json['co2e_ton'] as num?)?.toDouble() ?? 0.0,
      details: EmissionDetails.fromJson(cat, detailsMap),
      rawDetails: detailsMap,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'sub_category': subCategory,
      'co2e_kg': co2eKg,
      'co2e_ton': co2eTon,
      'details': details.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
