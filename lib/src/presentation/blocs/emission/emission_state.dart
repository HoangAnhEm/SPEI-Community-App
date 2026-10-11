import 'package:equatable/equatable.dart';
import '../../../domain/entities/emission_details.dart';
import '../../../domain/entities/household_emission.dart';

enum EmissionStatus { initial, loading, loaded, error }

/// Model biểu diễn cặp thông số phát thải hiển thị trên Thẻ Xanh
class EmissionMetricItem extends Equatable {
  final String category;
  final String title;
  final String primaryValue;
  final String primaryUnit;
  final String co2eKg;
  final String co2eUnit;
  final String changeText;
  final bool isDecrease; // true: giảm (tích cực), false: tăng

  const EmissionMetricItem({
    required this.category,
    required this.title,
    required this.primaryValue,
    required this.primaryUnit,
    required this.co2eKg,
    this.co2eUnit = 'kg CO₂e ước tính',
    required this.changeText,
    this.isDecrease = true,
  });

  @override
  List<Object?> get props => [
        category,
        title,
        primaryValue,
        primaryUnit,
        co2eKg,
        co2eUnit,
        changeText,
        isDecrease,
      ];
}

class EmissionState extends Equatable {
  final EmissionStatus status;
  final List<HouseholdEmission> currentMonthEmissions;
  final List<HouseholdEmission> previousMonthEmissions;
  final int currentYear;
  final int currentMonth;
  final int prevYear;
  final int prevMonth;
  final String? errorMessage;

  const EmissionState({
    this.status = EmissionStatus.initial,
    this.currentMonthEmissions = const [],
    this.previousMonthEmissions = const [],
    required this.currentYear,
    required this.currentMonth,
    required this.prevYear,
    required this.prevMonth,
    this.errorMessage,
  });

  bool get isLoading => status == EmissionStatus.loading;
  bool get isLoaded => status == EmissionStatus.loaded;

  /// Tạo danh sách các cặp đơn vị phát thải - CO2 để luân phiên hiển thị trên Thẻ Xanh
  List<EmissionMetricItem> get metricItems {
    final curMM = currentMonth.toString().padLeft(2, '0');
    final prevMM = prevMonth.toString().padLeft(2, '0');

    final items = <EmissionMetricItem>[];

    // 1. Phân loại: Điện (Electricity)
    final currElec = currentMonthEmissions.where((e) => e.category == EmissionCategory.electricity).toList();
    final prevElec = previousMonthEmissions.where((e) => e.category == EmissionCategory.electricity).toList();

    double currElecKwh = 0.0;
    double currElecCo2 = 0.0;
    for (final e in currElec) {
      if (e.details is ElectricityDetails) {
        final d = e.details as ElectricityDetails;
        currElecKwh += (d.calculatedKwh ?? d.inputValue);
      } else {
        currElecKwh += ((e.details.raw['calculated_kwh'] ?? e.details.raw['input_value']) as num? ?? 0.0).toDouble();
      }
      currElecCo2 += e.co2eKg;
    }

    double prevElecKwh = 0.0;
    for (final e in prevElec) {
      if (e.details is ElectricityDetails) {
        final d = e.details as ElectricityDetails;
        prevElecKwh += (d.calculatedKwh ?? d.inputValue);
      } else {
        prevElecKwh += ((e.details.raw['calculated_kwh'] ?? e.details.raw['input_value']) as num? ?? 0.0).toDouble();
      }
    }

    String elecChangeText;
    bool elecIsDecrease = true;
    if (currElec.isEmpty && prevElec.isEmpty) {
      elecChangeText = 'Chưa có bản ghi điện • Nhập chỉ số ngay';
    } else if (prevElecKwh > 0) {
      final pct = ((currElecKwh - prevElecKwh) / prevElecKwh) * 100;
      if (pct < 0) {
        elecIsDecrease = true;
        elecChangeText = 'Giảm ${(-pct).toStringAsFixed(1).replaceAll('.', ',')}% điện so với tháng $prevMM';
      } else if (pct > 0) {
        elecIsDecrease = false;
        elecChangeText = 'Tăng ${pct.toStringAsFixed(1).replaceAll('.', ',')}% điện so với tháng $prevMM';
      } else {
        elecIsDecrease = true;
        elecChangeText = 'Không đổi điện so với tháng $prevMM';
      }
    } else {
      elecChangeText = 'Dữ liệu điện tháng đầu tiên';
    }

    items.add(EmissionMetricItem(
      category: EmissionCategory.electricity,
      title: 'Điện gia đình • Tháng $curMM/$currentYear',
      primaryValue: currElecKwh > 0 ? (currElecKwh % 1 == 0 ? currElecKwh.toInt().toString() : currElecKwh.toStringAsFixed(1).replaceAll('.', ',')) : '0',
      primaryUnit: 'kWh sử dụng',
      co2eKg: currElecCo2 > 0 ? currElecCo2.toStringAsFixed(1).replaceAll('.', ',') : '0,0',
      changeText: elecChangeText,
      isDecrease: elecIsDecrease,
    ));

    // 2. Phân loại: Phương tiện giao thông (Transportation)
    final currTrans = currentMonthEmissions.where((e) => e.category == EmissionCategory.transportation).toList();
    final prevTrans = previousMonthEmissions.where((e) => e.category == EmissionCategory.transportation).toList();

    double currTransVal = 0.0;
    double currTransCo2 = 0.0;
    String transUnit = 'lít xăng';
    for (final e in currTrans) {
      if (e.details is TransportationDetails) {
        final d = e.details as TransportationDetails;
        currTransVal += d.inputValue;
        if (d.isKwh) transUnit = 'kWh điện';
      } else {
        currTransVal += ((e.details.raw['input_value']) as num? ?? 0.0).toDouble();
      }
      currTransCo2 += e.co2eKg;
    }

    double prevTransVal = 0.0;
    for (final e in prevTrans) {
      if (e.details is TransportationDetails) {
        prevTransVal += (e.details as TransportationDetails).inputValue;
      } else {
        prevTransVal += ((e.details.raw['input_value']) as num? ?? 0.0).toDouble();
      }
    }

    String transChangeText;
    bool transIsDecrease = true;
    if (currTrans.isEmpty && prevTrans.isEmpty) {
      transChangeText = 'Chưa có bản ghi di chuyển • Nhập chỉ số ngay';
    } else if (prevTransVal > 0) {
      final pct = ((currTransVal - prevTransVal) / prevTransVal) * 100;
      transIsDecrease = pct <= 0;
      final formattedPct = pct.abs().toStringAsFixed(1).replaceAll('.', ',');
      transChangeText = pct < 0
          ? 'Giảm $formattedPct% nhiên liệu so với tháng $prevMM'
          : (pct > 0 ? 'Tăng $formattedPct% nhiên liệu so với tháng $prevMM' : 'Không đổi so với tháng $prevMM');
    } else {
      transChangeText = 'Dữ liệu di chuyển tháng đầu tiên';
    }

    items.add(EmissionMetricItem(
      category: EmissionCategory.transportation,
      title: 'Phương tiện • Tháng $curMM/$currentYear',
      primaryValue: currTransVal > 0 ? (currTransVal % 1 == 0 ? currTransVal.toInt().toString() : currTransVal.toStringAsFixed(1).replaceAll('.', ',')) : '0',
      primaryUnit: '$transUnit sử dụng',
      co2eKg: currTransCo2 > 0 ? currTransCo2.toStringAsFixed(1).replaceAll('.', ',') : '0,0',
      changeText: transChangeText,
      isDecrease: transIsDecrease,
    ));

    // 3. Phân loại: Khí đốt Gas (Gas)
    final currGas = currentMonthEmissions.where((e) => e.category == EmissionCategory.gas).toList();
    final prevGas = previousMonthEmissions.where((e) => e.category == EmissionCategory.gas).toList();

    double currGasVal = 0.0;
    double currGasCo2 = 0.0;
    for (final e in currGas) {
      if (e.details is GasDetails) {
        currGasVal += (e.details as GasDetails).weightKg;
      } else {
        currGasVal += ((e.details.raw['weight_kg']) as num? ?? 0.0).toDouble();
      }
      currGasCo2 += e.co2eKg;
    }

    double prevGasVal = 0.0;
    for (final e in prevGas) {
      if (e.details is GasDetails) {
        prevGasVal += (e.details as GasDetails).weightKg;
      } else {
        prevGasVal += ((e.details.raw['weight_kg']) as num? ?? 0.0).toDouble();
      }
    }

    String gasChangeText;
    bool gasIsDecrease = true;
    if (currGas.isEmpty && prevGas.isEmpty) {
      gasChangeText = 'Chưa có bản ghi gas • Nhập chỉ số ngay';
    } else if (prevGasVal > 0) {
      final pct = ((currGasVal - prevGasVal) / prevGasVal) * 100;
      gasIsDecrease = pct <= 0;
      final formattedPct = pct.abs().toStringAsFixed(1).replaceAll('.', ',');
      gasChangeText = pct < 0
          ? 'Giảm $formattedPct% gas so với tháng $prevMM'
          : (pct > 0 ? 'Tăng $formattedPct% gas so với tháng $prevMM' : 'Không đổi so với tháng $prevMM');
    } else {
      gasChangeText = 'Dữ liệu gas tháng đầu tiên';
    }

    items.add(EmissionMetricItem(
      category: EmissionCategory.gas,
      title: 'Khí đốt Gas • Tháng $curMM/$currentYear',
      primaryValue: currGasVal > 0 ? (currGasVal % 1 == 0 ? currGasVal.toInt().toString() : currGasVal.toStringAsFixed(1).replaceAll('.', ',')) : '0',
      primaryUnit: 'kg gas sử dụng',
      co2eKg: currGasCo2 > 0 ? currGasCo2.toStringAsFixed(1).replaceAll('.', ',') : '0,0',
      changeText: gasChangeText,
      isDecrease: gasIsDecrease,
    ));

    // 4. Phân loại: Rác & Nước thải (Waste)
    final currWaste = currentMonthEmissions.where((e) => e.category == EmissionCategory.waste).toList();
    final prevWaste = previousMonthEmissions.where((e) => e.category == EmissionCategory.waste).toList();

    double currWasteVal = 0.0;
    double currWasteCo2 = 0.0;
    String wasteUnit = 'kg';
    for (final e in currWaste) {
      if (e.details is WasteDetails) {
        currWasteVal += (e.details as WasteDetails).quantity;
        wasteUnit = (e.details as WasteDetails).unit;
      } else {
        currWasteVal += ((e.details.raw['quantity']) as num? ?? 0.0).toDouble();
        wasteUnit = (e.details.raw['unit'] as String?) ?? 'kg';
      }
      currWasteCo2 += e.co2eKg;
    }

    double prevWasteVal = 0.0;
    for (final e in prevWaste) {
      if (e.details is WasteDetails) {
        prevWasteVal += (e.details as WasteDetails).quantity;
      } else {
        prevWasteVal += ((e.details.raw['quantity']) as num? ?? 0.0).toDouble();
      }
    }

    String wasteChangeText;
    bool wasteIsDecrease = true;
    if (currWaste.isEmpty && prevWaste.isEmpty) {
      wasteChangeText = 'Chưa có bản ghi rác thải • Nhập chỉ số ngay';
    } else if (prevWasteVal > 0) {
      final pct = ((currWasteVal - prevWasteVal) / prevWasteVal) * 100;
      wasteIsDecrease = pct <= 0;
      final formattedPct = pct.abs().toStringAsFixed(1).replaceAll('.', ',');
      wasteChangeText = pct < 0
          ? 'Giảm $formattedPct% rác thải so với tháng $prevMM'
          : (pct > 0 ? 'Tăng $formattedPct% rác thải so với tháng $prevMM' : 'Không đổi so với tháng $prevMM');
    } else {
      wasteChangeText = 'Dữ liệu rác thải tháng đầu tiên';
    }

    items.add(EmissionMetricItem(
      category: EmissionCategory.waste,
      title: 'Rác thải • Tháng $curMM/$currentYear',
      primaryValue: currWasteVal > 0 ? (currWasteVal % 1 == 0 ? currWasteVal.toInt().toString() : currWasteVal.toStringAsFixed(1).replaceAll('.', ',')) : '0',
      primaryUnit: '$wasteUnit rác phát sinh',
      co2eKg: currWasteCo2 > 0 ? currWasteCo2.toStringAsFixed(1).replaceAll('.', ',') : '0,0',
      changeText: wasteChangeText,
      isDecrease: wasteIsDecrease,
    ));

    // 5. Phân loại: Môi chất lạnh (Refrigerant)
    final currRef = currentMonthEmissions.where((e) => e.category == EmissionCategory.refrigerant).toList();
    final prevRef = previousMonthEmissions.where((e) => e.category == EmissionCategory.refrigerant).toList();

    double currRefVal = 0.0;
    double currRefCo2 = 0.0;
    for (final e in currRef) {
      if (e.details is RefrigerantDetails) {
        currRefVal += (e.details as RefrigerantDetails).quantity;
      } else {
        currRefVal += ((e.details.raw['quantity']) as num? ?? 0.0).toDouble();
      }
      currRefCo2 += e.co2eKg;
    }

    double prevRefVal = 0.0;
    for (final e in prevRef) {
      if (e.details is RefrigerantDetails) {
        prevRefVal += (e.details as RefrigerantDetails).quantity;
      } else {
        prevRefVal += ((e.details.raw['quantity']) as num? ?? 0.0).toDouble();
      }
    }

    String refChangeText;
    bool refIsDecrease = true;
    if (prevRefVal > 0) {
      final pct = ((currRefVal - prevRefVal) / prevRefVal) * 100;
      refIsDecrease = pct <= 0;
      final formattedPct = pct.abs().toStringAsFixed(1).replaceAll('.', ',');
      refChangeText = pct < 0
          ? 'Giảm $formattedPct% môi chất lạnh so với tháng $prevMM'
          : (pct > 0 ? 'Tăng $formattedPct% môi chất lạnh so với tháng $prevMM' : 'Không đổi so với tháng $prevMM');
    } else if (currRefVal > 0) {
      refChangeText = 'Dữ liệu môi chất lạnh tháng đầu tiên';
    } else {
      refChangeText = 'Chưa ghi nhận rò rỉ môi chất lạnh tháng này';
    }

    items.add(EmissionMetricItem(
      category: EmissionCategory.refrigerant,
      title: 'Môi chất lạnh • Tháng $curMM/$currentYear',
      primaryValue: currRefVal > 0
          ? (currRefVal % 1 == 0 ? currRefVal.toInt().toString() : currRefVal.toStringAsFixed(1).replaceAll('.', ','))
          : '0',
      primaryUnit: 'kg môi chất lạnh',
      co2eKg: currRefCo2 > 0 ? currRefCo2.toStringAsFixed(1).replaceAll('.', ',') : '0,0',
      changeText: refChangeText,
      isDecrease: refIsDecrease,
    ));

    return items;
  }

  EmissionState copyWith({
    EmissionStatus? status,
    List<HouseholdEmission>? currentMonthEmissions,
    List<HouseholdEmission>? previousMonthEmissions,
    int? currentYear,
    int? currentMonth,
    int? prevYear,
    int? prevMonth,
    String? errorMessage,
  }) {
    return EmissionState(
      status: status ?? this.status,
      currentMonthEmissions: currentMonthEmissions ?? this.currentMonthEmissions,
      previousMonthEmissions: previousMonthEmissions ?? this.previousMonthEmissions,
      currentYear: currentYear ?? this.currentYear,
      currentMonth: currentMonth ?? this.currentMonth,
      prevYear: prevYear ?? this.prevYear,
      prevMonth: prevMonth ?? this.prevMonth,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentMonthEmissions,
        previousMonthEmissions,
        currentYear,
        currentMonth,
        prevYear,
        prevMonth,
        errorMessage,
      ];
}
