import '../entities/reward.dart';

abstract class RewardRepository {
  /// Lấy số dư ví điểm xanh hiện tại của người dùng
  Future<UserWallet> getBalance();

  /// Lấy danh sách quà tặng đang mở bán (published và chưa hết hạn)
  Future<List<RewardItem>> getRewards();

  /// Đổi điểm xanh lấy quà tặng / voucher
  Future<RedemptionOrder> redeemReward({
    required String rewardId,
    String? idempotencyKey,
  });
}
