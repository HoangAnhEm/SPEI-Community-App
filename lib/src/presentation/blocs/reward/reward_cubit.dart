import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/reward.dart';
import '../../../domain/repositories/reward_repository.dart';
import 'reward_state.dart';

class RewardCubit extends Cubit<RewardState> {
  final RewardRepository _repository;

  RewardCubit(this._repository) : super(const RewardState());

  /// Tải dữ liệu ví điểm và danh sách quà
  Future<void> loadRewardData({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(
        status: RewardLoadingStatus.loading,
        errorMessage: null,
      ));
    }
    try {
      UserWallet? wallet;
      List<RewardItem>? rewards;
      String? firstError;

      try {
        wallet = await _repository.getBalance();
      } catch (e) {
        firstError = e.toString().replaceFirst('Exception: ', '');
      }

      try {
        rewards = await _repository.getRewards();
      } catch (e) {
        firstError ??= e.toString().replaceFirst('Exception: ', '');
      }

      if (wallet == null && rewards == null) {
        emit(state.copyWith(
          status: RewardLoadingStatus.error,
          errorMessage: firstError ?? 'Không thể tải dữ liệu điểm xanh.',
        ));
      } else {
        emit(state.copyWith(
          status: RewardLoadingStatus.loaded,
          wallet: wallet ?? state.wallet,
          rewards: rewards ?? state.rewards,
          errorMessage: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RewardLoadingStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// Tải riêng số dư ví
  Future<void> loadBalance({bool silent = true}) async {
    try {
      final wallet = await _repository.getBalance();
      emit(state.copyWith(wallet: wallet));
    } catch (_) {}
  }

  /// Tải riêng danh sách quà
  Future<void> loadRewards({bool silent = true}) async {
    try {
      final rewards = await _repository.getRewards();
      emit(state.copyWith(rewards: rewards));
    } catch (_) {}
  }

  /// Đặt tab lọc hiện tại ('all' hoặc 'affordable')
  void setFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  /// Tiến hành đổi quà
  Future<RedemptionOrder?> redeemReward(String rewardId) async {
    emit(state.copyWith(
      isRedeeming: true,
      redeemErrorMessage: null,
      lastRedemptionOrder: null,
    ));
    try {
      final order = await _repository.redeemReward(rewardId: rewardId);
      // Cập nhật lại số dư ví và danh sách quà mới nhất ngầm
      await loadRewardData(silent: true);
      emit(state.copyWith(
        isRedeeming: false,
        lastRedemptionOrder: order,
      ));
      return order;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        isRedeeming: false,
        redeemErrorMessage: msg,
      ));
      return null;
    }
  }

  /// Xóa toàn bộ dữ liệu khi người dùng đăng xuất
  void reset() {
    emit(const RewardState());
  }
}
