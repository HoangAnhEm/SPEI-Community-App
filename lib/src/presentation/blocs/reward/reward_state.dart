import '../../../domain/entities/reward.dart';

enum RewardLoadingStatus { initial, loading, loaded, error }

class RewardState {
  final RewardLoadingStatus status;
  final UserWallet? wallet;
  final List<RewardItem> rewards;
  final String? errorMessage;

  // Trạng thái đổi quà
  final bool isRedeeming;
  final RedemptionOrder? lastRedemptionOrder;
  final String? redeemErrorMessage;

  // Bộ lọc tab tại RewardStoreScreen: 'all' (Tất cả) hoặc 'affordable' (Có thể đổi)
  final String selectedFilter;

  const RewardState({
    this.status = RewardLoadingStatus.initial,
    this.wallet,
    this.rewards = const [],
    this.errorMessage,
    this.isRedeeming = false,
    this.lastRedemptionOrder,
    this.redeemErrorMessage,
    this.selectedFilter = 'all',
  });

  int get balance => wallet?.balance ?? 0;
  String get formattedBalance => wallet?.formattedBalance ?? '0';

  /// Danh sách quà đã lọc theo tab:
  /// - 'all': Tất cả quà đang mở bán
  /// - 'affordable': Các món quà có thể đổi và đủ điểm đổi
  List<RewardItem> get filteredRewards {
    if (selectedFilter == 'affordable') {
      return rewards
          .where((r) => r.isAvailable && r.canAfford(balance))
          .toList();
    }
    return rewards;
  }

  RewardState copyWith({
    RewardLoadingStatus? status,
    UserWallet? wallet,
    List<RewardItem>? rewards,
    String? errorMessage,
    bool? isRedeeming,
    RedemptionOrder? lastRedemptionOrder,
    String? redeemErrorMessage,
    String? selectedFilter,
  }) {
    return RewardState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      rewards: rewards ?? this.rewards,
      errorMessage: errorMessage,
      isRedeeming: isRedeeming ?? this.isRedeeming,
      lastRedemptionOrder: lastRedemptionOrder,
      redeemErrorMessage: redeemErrorMessage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}
