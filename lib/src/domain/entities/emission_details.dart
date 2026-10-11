/// Định nghĩa các loại phát thải chính
class EmissionCategory {
  static const String electricity = 'electricity';
  static const String transportation = 'transportation';
  static const String gas = 'gas';
  static const String refrigerant = 'refrigerant';
  static const String waste = 'waste';

  static String getLabel(String category) {
    switch (category) {
      case electricity:
        return 'Điện sinh hoạt';
      case transportation:
        return 'Phương tiện di chuyển';
      case gas:
        return 'Khí đốt (Gas)';
      case refrigerant:
        return 'Chất làm lạnh';
      case waste:
        return 'Rác thải & Nước thải';
      default:
        return category;
    }
  }

  static String getSubCategoryLabel(String? subCategory) {
    if (subCategory == null) return '';
    switch (subCategory) {
      case 'grid':
        return 'Lưới điện quốc gia';
      case 'gasoline_bike':
        return 'Xe máy xăng';
      case 'electric_bike':
        return 'Xe máy điện';
      case 'lpg':
        return 'Bình gas hóa lỏng (LPG)';
      case 'png':
        return 'Khí thiên nhiên qua đường ống (PNG)';
      case 'air_conditioner':
        return 'Điều hòa không khí';
      case 'refrigerator':
        return 'Tủ lạnh';
      case 'solid_waste':
        return 'Rác thải sinh hoạt';
      case 'wastewater':
        return 'Nước thải sinh hoạt';
      default:
        return subCategory;
    }
  }
}

/// Lớp cơ sở trừu tượng cho chi tiết bản ghi phát thải (details lưu dưới dạng JSONB)
abstract class EmissionDetails {
  final String? sourceLabel;
  final double? emissionFactor;
  final Map<String, dynamic> raw;

  const EmissionDetails({
    this.sourceLabel,
    this.emissionFactor,
    this.raw = const {},
  });

  Map<String, dynamic> toJson();

  factory EmissionDetails.fromJson(String category, Map<String, dynamic> json) {
    switch (category) {
      case EmissionCategory.electricity:
        return ElectricityDetails.fromJson(json);
      case EmissionCategory.transportation:
        return TransportationDetails.fromJson(json);
      case EmissionCategory.gas:
        return GasDetails.fromJson(json);
      case EmissionCategory.refrigerant:
        return RefrigerantDetails.fromJson(json);
      case EmissionCategory.waste:
        return WasteDetails.fromJson(json);
      default:
        return GenericEmissionDetails.fromJson(json);
    }
  }
}

/// 1. Chi tiết phát thải điện năng (Electricity)
class ElectricityDetails extends EmissionDetails {
  final String inputType; // 'kwh' | 'money_vnd'
  final double inputValue;
  final double? calculatedKwh;
  final double? estimatedMoneyVnd;

  const ElectricityDetails({
    super.sourceLabel,
    super.emissionFactor,
    super.raw,
    required this.inputType,
    required this.inputValue,
    this.calculatedKwh,
    this.estimatedMoneyVnd,
  });

  bool get isKwh => inputType == 'kwh';
  bool get isMoney => inputType == 'money_vnd';

  factory ElectricityDetails.fromJson(Map<String, dynamic> json) {
    return ElectricityDetails(
      sourceLabel: json['source_label'] as String?,
      emissionFactor: (json['emission_factor'] as num?)?.toDouble(),
      raw: Map<String, dynamic>.from(json),
      inputType: json['input_type'] as String? ?? 'kwh',
      inputValue: (json['input_value'] as num?)?.toDouble() ?? 0.0,
      calculatedKwh: (json['calculated_kwh'] as num?)?.toDouble(),
      estimatedMoneyVnd: (json['estimated_money_vnd'] as num?)?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'input_type': inputType,
      'input_value': inputValue,
    };
    if (sourceLabel != null) map['source_label'] = sourceLabel;
    if (calculatedKwh != null) map['calculated_kwh'] = calculatedKwh;
    if (estimatedMoneyVnd != null) map['estimated_money_vnd'] = estimatedMoneyVnd;
    if (emissionFactor != null) map['emission_factor'] = emissionFactor;
    return map;
  }
}

/// 2. Chi tiết phát thải phương tiện giao thông (Transportation)
class TransportationDetails extends EmissionDetails {
  final String inputType; // 'liters' | 'kwh'
  final double inputValue;

  const TransportationDetails({
    super.sourceLabel,
    super.emissionFactor,
    super.raw,
    required this.inputType,
    required this.inputValue,
  });

  bool get isLiters => inputType == 'liters';
  bool get isKwh => inputType == 'kwh';

  factory TransportationDetails.fromJson(Map<String, dynamic> json) {
    return TransportationDetails(
      sourceLabel: json['source_label'] as String?,
      emissionFactor: (json['emission_factor'] as num?)?.toDouble(),
      raw: Map<String, dynamic>.from(json),
      inputType: json['input_type'] as String? ?? 'liters',
      inputValue: (json['input_value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'input_type': inputType,
      'input_value': inputValue,
    };
    if (sourceLabel != null) map['source_label'] = sourceLabel;
    if (emissionFactor != null) map['emission_factor'] = emissionFactor;
    return map;
  }
}

/// 3. Chi tiết phát thải khí đốt Gas (Gas)
class GasDetails extends EmissionDetails {
  final String gasType; // 'lpg' | 'png'
  final double weightKg;

  const GasDetails({
    super.sourceLabel,
    super.emissionFactor,
    super.raw,
    required this.gasType,
    required this.weightKg,
  });

  factory GasDetails.fromJson(Map<String, dynamic> json) {
    return GasDetails(
      sourceLabel: json['source_label'] as String?,
      emissionFactor: (json['emission_factor'] as num?)?.toDouble(),
      raw: Map<String, dynamic>.from(json),
      gasType: json['gas_type'] as String? ?? 'lpg',
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'gas_type': gasType,
      'weight_kg': weightKg,
    };
    if (sourceLabel != null) map['source_label'] = sourceLabel;
    if (emissionFactor != null) map['emission_factor'] = emissionFactor;
    return map;
  }
}

/// 4. Chi tiết phát thải chất làm lạnh (Refrigerant)
class RefrigerantDetails extends EmissionDetails {
  final String refrigerantType; // 'R32' | 'R600a'
  final double quantity;

  const RefrigerantDetails({
    super.sourceLabel,
    super.emissionFactor,
    super.raw,
    required this.refrigerantType,
    required this.quantity,
  });

  factory RefrigerantDetails.fromJson(Map<String, dynamic> json) {
    return RefrigerantDetails(
      sourceLabel: json['source_label'] as String?,
      emissionFactor: (json['emission_factor'] as num?)?.toDouble(),
      raw: Map<String, dynamic>.from(json),
      refrigerantType: json['refrigerant_type'] as String? ?? 'R32',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'refrigerant_type': refrigerantType,
      'quantity': quantity,
    };
    if (sourceLabel != null) map['source_label'] = sourceLabel;
    if (emissionFactor != null) map['emission_factor'] = emissionFactor;
    return map;
  }
}

/// 5. Chi tiết phát thải rác & nước thải (Waste)
class WasteDetails extends EmissionDetails {
  final String unit; // 'kg' | 'm3'
  final double quantity;

  const WasteDetails({
    super.sourceLabel,
    super.emissionFactor,
    super.raw,
    required this.unit,
    required this.quantity,
  });

  factory WasteDetails.fromJson(Map<String, dynamic> json) {
    return WasteDetails(
      sourceLabel: json['source_label'] as String?,
      emissionFactor: (json['emission_factor'] as num?)?.toDouble(),
      raw: Map<String, dynamic>.from(json),
      unit: json['unit'] as String? ?? 'kg',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'unit': unit,
      'quantity': quantity,
    };
    if (sourceLabel != null) map['source_label'] = sourceLabel;
    if (emissionFactor != null) map['emission_factor'] = emissionFactor;
    return map;
  }
}

/// Chi tiết chung dự phòng (Generic fallback cho trường hợp chưa xác định hoặc mở rộng trong tương lai)
class GenericEmissionDetails extends EmissionDetails {
  const GenericEmissionDetails({
    super.sourceLabel,
    super.emissionFactor,
    super.raw,
  });

  factory GenericEmissionDetails.fromJson(Map<String, dynamic> json) {
    return GenericEmissionDetails(
      sourceLabel: json['source_label'] as String?,
      emissionFactor: (json['emission_factor'] as num?)?.toDouble(),
      raw: Map<String, dynamic>.from(json),
    );
  }

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

/// Payload đại diện cho 1 yêu cầu tính toán hoặc ghi nhận phát thải
class EmissionPayload {
  final String category;
  final String? subCategory;
  final EmissionDetails details;

  const EmissionPayload({
    required this.category,
    this.subCategory,
    required this.details,
  });

  /// Factory cho điện
  factory EmissionPayload.electricity({
    required ElectricityDetails details,
    String subCategory = 'grid',
  }) {
    return EmissionPayload(
      category: EmissionCategory.electricity,
      subCategory: subCategory,
      details: details,
    );
  }

  /// Factory cho phương tiện di chuyển
  factory EmissionPayload.transportation({
    required String subCategory, // 'gasoline_bike' | 'electric_bike'
    required TransportationDetails details,
  }) {
    return EmissionPayload(
      category: EmissionCategory.transportation,
      subCategory: subCategory,
      details: details,
    );
  }

  /// Factory cho Gas
  factory EmissionPayload.gas({
    required String subCategory, // 'lpg' | 'png'
    required GasDetails details,
  }) {
    return EmissionPayload(
      category: EmissionCategory.gas,
      subCategory: subCategory,
      details: details,
    );
  }

  /// Factory cho chất làm lạnh
  factory EmissionPayload.refrigerant({
    required String subCategory, // 'air_conditioner' | 'refrigerator'
    required RefrigerantDetails details,
  }) {
    return EmissionPayload(
      category: EmissionCategory.refrigerant,
      subCategory: subCategory,
      details: details,
    );
  }

  /// Factory cho rác thải
  factory EmissionPayload.waste({
    required String subCategory, // 'solid_waste' | 'wastewater'
    required WasteDetails details,
  }) {
    return EmissionPayload(
      category: EmissionCategory.waste,
      subCategory: subCategory,
      details: details,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'category': category,
      'details': details.toJson(),
    };
    if (subCategory != null) {
      map['sub_category'] = subCategory;
    }
    return map;
  }

  factory EmissionPayload.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as String? ?? '';
    final subCategory = json['sub_category'] as String?;
    final detailsMap = json['details'] as Map<String, dynamic>? ?? {};
    return EmissionPayload(
      category: category,
      subCategory: subCategory,
      details: EmissionDetails.fromJson(category, detailsMap),
    );
  }
}

/// Request model cho endpoint /emission/calculate
class CalculateEmissionRequest {
  final EmissionPayload payload;

  const CalculateEmissionRequest({required this.payload});

  Map<String, dynamic> toJson() {
    return {
      'payload': payload.toJson(),
    };
  }
}

/// Request model cho endpoint POST /emission/household
class RecordHouseholdEmissionRequest {
  final int periodYear;
  final int periodMonth;
  final EmissionPayload payload;

  const RecordHouseholdEmissionRequest({
    required this.periodYear,
    required this.periodMonth,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'period_year': periodYear,
      'period_month': periodMonth,
      'payload': payload.toJson(),
    };
  }
}
