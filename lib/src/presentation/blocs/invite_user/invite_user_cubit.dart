import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/di/di.dart';
import '../../../domain/repositories/household_repository.dart';
import '../household/household_cubit.dart';
import 'invite_user_state.dart';

class InviteUserCubit extends Cubit<InviteUserState> {
  final HouseholdRepository _householdRepository;

  InviteUserCubit(this._householdRepository) : super(const InviteUserState());

  Future<void> searchUser({
    String? phoneNumber,
    String? email,
    String? userId,
  }) async {
    emit(state.copyWith(
      searchStatus: UserSearchStatus.loading,
      searchError: null,
      hasInvited: false,
      inviteStatus: SendInviteStatus.initial,
      inviteMessage: null,
      clearSearchedUser: true,
    ));

    try {
      final user = await _householdRepository.lookupUser(
        phoneNumber: phoneNumber,
        email: email,
        userId: userId,
      );
      emit(state.copyWith(
        searchStatus: UserSearchStatus.success,
        searchedUser: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        searchStatus: UserSearchStatus.failure,
        searchError: e.toString().replaceFirst('Exception: ', ''),
        clearSearchedUser: true,
      ));
    }
  }

  Future<bool> sendInvite(String inviteeId) async {
    emit(state.copyWith(
      inviteStatus: SendInviteStatus.loading,
      inviteMessage: null,
    ));

    try {
      await _householdRepository.inviteDirect(inviteeId);
      getIt<HouseholdCubit>().loadHouseholdData();
      emit(state.copyWith(
        inviteStatus: SendInviteStatus.success,
        hasInvited: true,
        inviteMessage: 'Đã gửi lời mời thành công',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        inviteStatus: SendInviteStatus.failure,
        inviteMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  void resetSearch() {
    emit(const InviteUserState());
  }
}
