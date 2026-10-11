import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/di/di.dart';
import '../../../domain/repositories/household_repository.dart';
import '../household/household_cubit.dart';
import 'household_lookup_state.dart';

class HouseholdLookupCubit extends Cubit<HouseholdLookupState> {
  final HouseholdRepository _householdRepository;

  HouseholdLookupCubit(this._householdRepository) : super(HouseholdLookupInitial());

  Future<void> lookupHousehold(String householdId) async {
    emit(HouseholdLookupLoading());
    try {
      final result = await _householdRepository.lookupHousehold(householdId);
      emit(HouseholdLookupSuccess(result: result));
    } catch (e) {
      emit(HouseholdLookupFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> sendJoinRequest(String householdId) async {
    final currentState = state;
    if (currentState is! HouseholdLookupSuccess) return;

    emit(currentState.copyWith(isJoining: true, joinError: null));

    try {
      await _householdRepository.createJoinRequest(householdId);
      // Đồng bộ nạp lại dữ liệu hộ gia đình toàn cục (cập nhật số lượng join request đã gửi)
      getIt<HouseholdCubit>().loadHouseholdData();
      emit(currentState.copyWith(isJoining: false, joinSuccess: true));
    } catch (e) {
      emit(currentState.copyWith(
        isJoining: false,
        joinError: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
