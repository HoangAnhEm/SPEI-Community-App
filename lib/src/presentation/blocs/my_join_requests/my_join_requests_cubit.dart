import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/di/di.dart';
import '../../../domain/repositories/household_repository.dart';
import '../household/household_cubit.dart';
import 'my_join_requests_state.dart';

class MyJoinRequestsCubit extends Cubit<MyJoinRequestsState> {
  final HouseholdRepository _householdRepository;

  MyJoinRequestsCubit(this._householdRepository) : super(MyJoinRequestsInitial());

  Future<void> loadMyJoinRequests() async {
    emit(MyJoinRequestsLoading());
    try {
      final list = await _householdRepository.getMyJoinRequests();
      emit(MyJoinRequestsLoaded(requests: list));
    } catch (e) {
      emit(MyJoinRequestsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<bool> cancelRequest(String requestId) async {
    final currentState = state;
    if (currentState is! MyJoinRequestsLoaded) return false;

    emit(currentState.copyWith(isActionLoading: true, actionMessage: null));
    try {
      await _householdRepository.cancelMyJoinRequest(requestId);
      getIt<HouseholdCubit>().loadHouseholdData();
      final updatedList = await _householdRepository.getMyJoinRequests();
      emit(MyJoinRequestsLoaded(
        requests: updatedList,
        actionMessage: 'Đã hủy yêu cầu tham gia thành công',
      ));
      return true;
    } catch (e) {
      emit(currentState.copyWith(
        isActionLoading: false,
        actionMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }
}
