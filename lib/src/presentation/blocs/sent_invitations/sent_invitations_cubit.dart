import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/di/di.dart';
import '../../../domain/repositories/household_repository.dart';
import '../household/household_cubit.dart';
import 'sent_invitations_state.dart';

class SentInvitationsCubit extends Cubit<SentInvitationsState> {
  final HouseholdRepository _householdRepository;

  SentInvitationsCubit(this._householdRepository) : super(SentInvitationsInitial());

  Future<void> loadSentInvitations() async {
    emit(SentInvitationsLoading());
    try {
      final list = await _householdRepository.getSentInvitations();
      emit(SentInvitationsLoaded(invitations: list));
    } catch (e) {
      emit(SentInvitationsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<bool> revokeInvitation(String invitationId) async {
    final currentState = state;
    if (currentState is! SentInvitationsLoaded) return false;

    emit(currentState.copyWith(isActionLoading: true, actionMessage: null));
    try {
      await _householdRepository.revokeInvitation(invitationId);
      // Nạp lại dữ liệu hộ gia đình toàn cục
      getIt<HouseholdCubit>().loadHouseholdData();
      final updatedList = await _householdRepository.getSentInvitations();
      emit(SentInvitationsLoaded(
        invitations: updatedList,
        actionMessage: 'Đã hủy lời mời thành công',
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
