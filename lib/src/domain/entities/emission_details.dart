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
        return 'Chất thải rắn sinh hoạt';
      case 'hazardous_printer_cartridge':
      case 'hazardous_cartridge':
        return 'Hộp mực in thải (08 02 04)';
      case 'hazardous_ink':
        return 'Mực in thải (08 02 01)';
      case 'hazardous_metal_packaging':
        return 'Bao bì kim loại nhiễm hại (18 01 02)';
      case 'hazardous_fluorescent_lamp':
        return 'Bóng đèn huỳnh quang thải (16 01 06)';
      case 'hazardous_lead_battery':
      case 'hazardous_battery':
        return 'Pin, ắc quy chì thải (19 06 01)';
      case 'hazardous_engine_oil':
      case 'hazardous_oil':
        return 'Dầu động cơ, bôi trơn thải (17 02 03)';
      case 'hazardous_absorbent_material':
      case 'hazardous_absorbent':
        return 'Giẻ lau, vật liệu lọc nhiễm hại (18 02 01)';
      case 'hazardous_grease':
        return 'Các loại dầu mỡ thải (16 01 08)';
      case 'wastewater':
        return 'Nước thải KCN';
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

class WasteDetails extends EmissionDetails {
  final String unit; // 'kg' | 'm3' | 'ton'
  final double quantity;
  final String? wasteType;
  final String? wasteCode;
  final String? treatmentMethod;
  final String? wasteTypeName;
  final String? emissionFactorUnit;

  const WasteDetails({
    super.sourceLabel,
    super.emissionFactor,
    super.raw,
    required this.unit,
    required this.quantity,
    this.wasteType,
    this.wasteCode,
    this.treatmentMethod,
    this.wasteTypeName,
    this.emissionFactorUnit,
  });

  factory WasteDetails.fromJson(Map<String, dynamic> json) {
    return WasteDetails(
      sourceLabel: json['source_label'] as String?,
      emissionFactor: (json['emission_factor'] as num?)?.toDouble(),
      raw: Map<String, dynamic>.from(json),
      unit: json['unit'] as String? ?? 'kg',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      wasteType: json['waste_type'] as String? ?? json['waste_type_key'] as String?,
      wasteCode: json['waste_code'] as String?,
      treatmentMethod: json['treatment_method'] as String?,
      wasteTypeName: json['waste_type_name'] as String?,
      emissionFactorUnit: json['emission_factor_unit'] as String?,
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
    if (wasteType != null) map['waste_type'] = wasteType;
    if (wasteCode != null) map['waste_code'] = wasteCode;
    if (treatmentMethod != null) map['treatment_method'] = treatmentMethod;
    if (wasteTypeName != null) map['waste_type_name'] = wasteTypeName;
    if (emissionFactorUnit != null) map['emission_factor_unit'] = emissionFactorUnit;
    return map;
  }
}

class WasteTypeItem {
  final String key;
  final String name;
  final String? wasteCode;
  final String treatmentMethod;
  final double emissionFactor;
  final String emissionFactorUnit;
  final String defaultUnit;

  const WasteTypeItem({
    required this.key,
    required this.name,
    this.wasteCode,
    required this.treatmentMethod,
    required this.emissionFactor,
    required this.emissionFactorUnit,
    required this.defaultUnit,
  });

  static const List<WasteTypeItem> all = [
    WasteTypeItem(
      key: 'solid_waste',
      name: 'Chất thải rắn sinh hoạt',
      wasteCode: null,
      treatmentMethod: 'Chôn lấp',
      emissionFactor: 497.24244,
      emissionFactorUnit: 'kg CO2e/tấn',
      defaultUnit: 'kg',
    ),
    WasteTypeItem(
      key: 'hazardous_printer_cartridge',
      name: 'Hộp mực in thải có các thành phần nguy hại',
      wasteCode: '08 02 04',
      treatmentMethod: 'Thiêu đốt',
      emissionFactor: 4.68568,
      emissionFactorUnit: 'kg CO2e/tấn',
      defaultUnit: 'kg',
    ),
    WasteTypeItem(
      key: 'hazardous_ink',
      name: 'Mực in thải có thành phần nguy hại',
      wasteCode: '08 02 01',
      treatmentMethod: 'Thiêu đốt',
      emissionFactor: 4.68568,
      emissionFactorUnit: 'kg CO2e/tấn',
      defaultUnit: 'kg',
    ),
    WasteTypeItem(
      key: 'hazardous_metal_packaging',
      name: 'Bao bì cứng thải bằng kim loại nhiễm các thành phần nguy hại',
      wasteCode: '18 01 02',
      treatmentMethod: 'Tẩy rửa',
      emissionFactor: 4.68568,
      emissionFactorUnit: 'kg CO2e/tấn',
      defaultUnit: 'kg',
    ),
    WasteTypeItem(
      key: 'hazardous_fluorescent_lamp',
      name: 'Bóng đèn huỳnh quang thải',
      wasteCode: '16 01 06',
      treatmentMethod: 'Nghiền, HR',
      emissionFactor: 4.68568,
      emissionFactorUnit: 'kg CO2e/tấn',
      defaultUnit: 'kg',
    ),
    WasteTypeItem(
      key: 'hazardous_lead_battery',
      name: 'Pin, ắc quy chì thải',
      wasteCode: '19 06 01',
      treatmentMethod: 'Tẩy rửa, Tháo dỡ',
      emissionFactor: 4.68568,
      emissionFactorUnit: 'kg CO2e/tấn',
      defaultUnit: 'kg',
    ),
    WasteTypeItem(
      key: 'hazardous_engine_oil',
      name: 'Dầu động cơ, hộp số và bôi trơn tổng hợp thải',
      wasteCode: '17 02 03',
      treatmentMethod: 'Tái chế',
      emissionFactor: 4.68568,
      emissionFactorUnit: 'kg CO2e/tấn',
      defaultUnit: 'kg',
    ),
    WasteTypeItem(
      key: 'hazardous_absorbent_material',
      name: 'Chất hấp thụ, vật liệu lọc, giẻ lau, vải bảo vệ thải bị nhiễm các thành phần nguy hại',
      wasteCode: '18 02 01',
      treatmentMethod: 'Thiêu đốt',
      emissionFactor: 4.68568,
      emissionFactorUnit: 'kg CO2e/tấn',
      defaultUnit: 'kg',
    ),
    WasteTypeItem(
      key: 'hazardous_grease',
      name: 'Các loại dầu mỡ thải',
      wasteCode: '16 01 08',
      treatmentMethod: 'Thiêu đốt',
      emissionFactor: 4.68568,
      emissionFactorUnit: 'kg CO2e/tấn',
      defaultUnit: 'kg',
    ),
    WasteTypeItem(
      key: 'wastewater',
      name: 'Nước thải xử lý ở hệ thống xử lý nước thải KCN',
      wasteCode: null,
      treatmentMethod: 'Hệ thống XL nước thải KCN',
      emissionFactor: 0.18574,
      emissionFactorUnit: 'kg CO2e/m3',
      defaultUnit: 'm3',
    ),
  ];
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
