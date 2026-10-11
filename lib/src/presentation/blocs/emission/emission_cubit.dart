import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/emission_repository.dart';
import 'emission_state.dart';

class EmissionCubit extends Cubit<EmissionState> {
  final EmissionRepository _repository;

  EmissionCubit(this._repository)
      : super(EmissionState(
          currentYear: DateTime.now().year,
          currentMonth: DateTime.now().month,
          prevYear: DateTime(DateTime.now().year, DateTime.now().month - 1, 1).year,
          prevMonth: DateTime(DateTime.now().year, DateTime.now().month - 1, 1).month,
        ));

  Future<void> loadEmissions({int? year, int? month}) async {
    final now = DateTime.now();
    final curYear = year ?? now.year;
    final curMonth = month ?? now.month;

    final prevDate = DateTime(curYear, curMonth - 1, 1);
    final pYear = prevDate.year;
    final pMonth = prevDate.month;

    emit(state.copyWith(
      status: EmissionStatus.loading,
      currentYear: curYear,
      currentMonth: curMonth,
      prevYear: pYear,
      prevMonth: pMonth,
      errorMessage: null,
    ));

    try {
      final results = await Future.wait([
        _repository.getHouseholdEmissionsByPeriod(year: curYear, month: curMonth),
        _repository.getHouseholdEmissionsByPeriod(year: pYear, month: pMonth),
      ]);

      emit(state.copyWith(
        status: EmissionStatus.loaded,
        currentMonthEmissions: results[0],
        previousMonthEmissions: results[1],
        errorMessage: null,
      ));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      // Nếu người dùng chưa thuộc hộ nào ("User is not a member of any household"),
      // vẫn coi như loaded với danh sách rỗng để UI hiển thị mượt mà.
      emit(state.copyWith(
        status: EmissionStatus.loaded,
        currentMonthEmissions: const [],
        previousMonthEmissions: const [],
        errorMessage: msg,
      ));
    }
  }

  void reset() {
    final now = DateTime.now();
    emit(EmissionState(
      currentYear: now.year,
      currentMonth: now.month,
      prevYear: DateTime(now.year, now.month - 1, 1).year,
      prevMonth: DateTime(now.year, now.month - 1, 1).month,
    ));
  }
}
