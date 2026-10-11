import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/household_invitation.dart';
import '../../../domain/entities/household_join_request.dart';
import '../../../domain/repositories/household_repository.dart';
import 'household_state.dart';

class HouseholdCubit extends Cubit<HouseholdState> {
  final HouseholdRepository _repository;

  HouseholdCubit(this._repository) : super(const HouseholdState());

  Future<void> loadHouseholdData({String? userId}) async {
    final uid = userId ?? state.currentUserId;
    emit(state.copyWith(
      status: HouseholdStatus.loading,
      currentUserId: uid,
      errorMessage: null,
    ));

    try {
      final household = await _repository.getMyHousehold();

      final bool isOwner = household != null &&
          uid != null &&
          household.members.any((m) => m.userId == uid && m.isOwner);

      List<HouseholdInvitation> sentInvs = [];
      List<HouseholdInvitation> receivedInvs = [];
      List<HouseholdJoinRequest> incomingReqs = [];
      List<HouseholdJoinRequest> myReqs = [];

      if (household != null && isOwner) {
        // Chủ hộ: Lấy lời mời đã gửi và yêu cầu người khác xin vào hộ
        final results = await Future.wait([
          _repository.getSentInvitations(),
          _repository.getHouseholdJoinRequests(),
        ]);
        sentInvs = results[0] as List<HouseholdInvitation>;
        incomingReqs = results[1] as List<HouseholdJoinRequest>;
      } else {
        // Thành viên hoặc Chưa có hộ: Lấy lời mời nhận được và yêu cầu mình đã gửi
        final results = await Future.wait([
          _repository.getReceivedInvitations(),
          _repository.getMyJoinRequests(),
        ]);
        receivedInvs = results[0] as List<HouseholdInvitation>;
        myReqs = results[1] as List<HouseholdJoinRequest>;
      }

      emit(state.copyWith(
        status: HouseholdStatus.loaded,
        household: () => household,
        currentUserId: uid,
        sentInvitations: sentInvs,
        receivedInvitations: receivedInvs,
        incomingJoinRequests: incomingReqs,
        myJoinRequests: myReqs,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HouseholdStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<bool> leaveHousehold() async {
    emit(state.copyWith(isActionLoading: true, errorMessage: null));
    try {
      await _repository.leaveHousehold();
      await loadHouseholdData();
      return true;
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  void reset() {
    emit(const HouseholdState());
  }
}
