import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/di/di.dart';
import '../../../domain/repositories/household_repository.dart';
import '../household/household_cubit.dart';
import 'household_join_requests_state.dart';

class HouseholdJoinRequestsCubit extends Cubit<HouseholdJoinRequestsState> {
  final HouseholdRepository _householdRepository;

  HouseholdJoinRequestsCubit(this._householdRepository) : super(HouseholdJoinRequestsInitial());

  Future<void> loadJoinRequests() async {
    emit(HouseholdJoinRequestsLoading());
    try {
      final list = await _householdRepository.getHouseholdJoinRequests();
      emit(HouseholdJoinRequestsLoaded(requests: list));
    } catch (e) {
      emit(HouseholdJoinRequestsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<bool> approveRequest(String requestId) async {
    final currentState = state;
    if (currentState is! HouseholdJoinRequestsLoaded) return false;

    emit(currentState.copyWith(isActionLoading: true, actionMessage: null));
    try {
      await _householdRepository.approveJoinRequest(requestId);
      // Nạp lại toàn bộ dữ liệu hộ gia đình toàn cục (thành viên mới, số lượng yêu cầu)
      getIt<HouseholdCubit>().loadHouseholdData();
      final updatedList = await _householdRepository.getHouseholdJoinRequests();
      emit(HouseholdJoinRequestsLoaded(
        requests: updatedList,
        actionMessage: 'Đã chấp nhận yêu cầu tham gia',
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

  Future<bool> rejectRequest(String requestId) async {
    final currentState = state;
    if (currentState is! HouseholdJoinRequestsLoaded) return false;

    emit(currentState.copyWith(isActionLoading: true, actionMessage: null));
    try {
      await _householdRepository.rejectJoinRequest(requestId);
      getIt<HouseholdCubit>().loadHouseholdData();
      final updatedList = await _householdRepository.getHouseholdJoinRequests();
      emit(HouseholdJoinRequestsLoaded(
        requests: updatedList,
        actionMessage: 'Đã từ chối yêu cầu tham gia',
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
