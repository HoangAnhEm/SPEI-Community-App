import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/di/di.dart';
import '../../../domain/repositories/household_repository.dart';
import '../household/household_cubit.dart';
import 'received_invitations_state.dart';

class ReceivedInvitationsCubit extends Cubit<ReceivedInvitationsState> {
  final HouseholdRepository _householdRepository;

  ReceivedInvitationsCubit(this._householdRepository) : super(ReceivedInvitationsInitial());

  Future<void> loadReceivedInvitations() async {
    emit(ReceivedInvitationsLoading());
    try {
      final list = await _householdRepository.getReceivedInvitations();
      emit(ReceivedInvitationsLoaded(invitations: list));
    } catch (e) {
      emit(ReceivedInvitationsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<bool> acceptInvitation(String invitationId) async {
    final currentState = state;
    if (currentState is! ReceivedInvitationsLoaded) return false;

    emit(currentState.copyWith(isActionLoading: true, actionMessage: null));
    try {
      await _householdRepository.acceptInvitation(invitationId);
      getIt<HouseholdCubit>().loadHouseholdData();
      final updatedList = await _householdRepository.getReceivedInvitations();
      emit(ReceivedInvitationsLoaded(
        invitations: updatedList,
        actionMessage: 'Đã chấp nhận lời mời tham gia hộ gia đình',
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

  Future<bool> rejectInvitation(String invitationId) async {
    final currentState = state;
    if (currentState is! ReceivedInvitationsLoaded) return false;

    emit(currentState.copyWith(isActionLoading: true, actionMessage: null));
    try {
      await _householdRepository.rejectInvitation(invitationId);
      getIt<HouseholdCubit>().loadHouseholdData();
      final updatedList = await _householdRepository.getReceivedInvitations();
      emit(ReceivedInvitationsLoaded(
        invitations: updatedList,
        actionMessage: 'Đã từ chối lời mời tham gia',
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
