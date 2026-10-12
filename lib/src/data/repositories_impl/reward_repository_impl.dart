import '../../domain/entities/reward.dart';
import '../../domain/repositories/reward_repository.dart';
import '../datasources/remote/reward_remote_data_source.dart';
import '../models/reward_model.dart';

class RewardRepositoryImpl implements RewardRepository {
  final RewardRemoteDataSource remoteDataSource;

  RewardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserWallet> getBalance() async {
    final raw = await remoteDataSource.getBalance();
    return UserWalletModel.fromJson(raw).toEntity();
  }

  @override
  Future<List<RewardItem>> getRewards() async {
    final rawList = await remoteDataSource.getRewards();
    return rawList
        .map((e) => RewardItemModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<RedemptionOrder> redeemReward({
    required String rewardId,
    String? idempotencyKey,
  }) async {
    final requestModel = RedeemRewardRequestModel(
      rewardId: rewardId,
      idempotencyKey: idempotencyKey,
    );
    final raw = await remoteDataSource.redeemReward(requestModel.toJson());
    return RedemptionOrderModel.fromJson(raw).toEntity();
  }
}
