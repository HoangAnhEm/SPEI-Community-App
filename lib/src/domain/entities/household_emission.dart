import 'emission_details.dart';

/// Bản ghi phát thải đồng bộ của hộ gia đình (HouseholdEmissionResponse)
class HouseholdEmission {
  final String id;
  final String householdId;
  final int periodYear;
  final int periodMonth;
  final String category;
  final String? subCategory;
  final double co2eKg;
  final double co2eTon;
  final EmissionDetails details;
  final Map<String, dynamic> rawDetails;
  final String createdById;
  final String createdByName;
  final String updatedById;
  final String updatedByName;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HouseholdEmission({
    required this.id,
    required this.householdId,
    required this.periodYear,
    required this.periodMonth,
    required this.category,
    this.subCategory,
    required this.co2eKg,
    required this.co2eTon,
    required this.details,
    required this.rawDetails,
    required this.createdById,
    required this.createdByName,
    required this.updatedById,
    required this.updatedByName,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  String get categoryLabel => EmissionCategory.getLabel(category);
  String get subCategoryLabel => EmissionCategory.getSubCategoryLabel(subCategory);

  String get periodLabel => 'Tháng $periodMonth/$periodYear';
  String get co2eKgFormatted => co2eKg.toStringAsFixed(2);
  String get co2eTonFormatted => co2eTon.toStringAsFixed(4);

  factory HouseholdEmission.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] as String? ?? '';
    final subCat = json['sub_category'] as String?;
    final detailsMap = json['details'] as Map<String, dynamic>? ?? {};

    return HouseholdEmission(
      id: json['id'] as String? ?? '',
      householdId: json['household_id'] as String? ?? '',
      periodYear: (json['period_year'] as num?)?.toInt() ?? DateTime.now().year,
      periodMonth: (json['period_month'] as num?)?.toInt() ?? DateTime.now().month,
      category: cat,
      subCategory: subCat,
      co2eKg: (json['co2e_kg'] as num?)?.toDouble() ?? 0.0,
      co2eTon: (json['co2e_ton'] as num?)?.toDouble() ?? 0.0,
      details: EmissionDetails.fromJson(cat, detailsMap),
      rawDetails: detailsMap,
      createdById: json['created_by_id'] as String? ?? '',
      createdByName: json['created_by_name'] as String? ?? '',
      updatedById: json['updated_by_id'] as String? ?? '',
      updatedByName: json['updated_by_name'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'period_year': periodYear,
      'period_month': periodMonth,
      'category': category,
      'sub_category': subCategory,
      'co2e_kg': co2eKg,
      'co2e_ton': co2eTon,
      'details': details.toJson(),
      'created_by_id': createdById,
      'created_by_name': createdByName,
      'updated_by_id': updatedById,
      'updated_by_name': updatedByName,
      'version': version,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
