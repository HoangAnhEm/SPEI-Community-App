import '../../domain/entities/reward.dart';

/// Request DTO để gửi yêu cầu đổi quà / voucher (/api/v1/loyalty/redeem)
class RedeemRewardRequestModel {
  final String rewardId;
  final String? idempotencyKey;

  const RedeemRewardRequestModel({
    required this.rewardId,
    this.idempotencyKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'reward_id': rewardId,
      if (idempotencyKey != null && idempotencyKey!.isNotEmpty)
        'idempotency_key': idempotencyKey,
    };
  }
}

/// DTO của món quà / voucher trả về từ API (/api/v1/loyalty/rewards)
class RewardItemModel extends RewardItem {
  const RewardItemModel({
    required super.id,
    required super.title,
    super.description,
    required super.costPoints,
    required super.stockQuantity,
    required super.status,
    super.imageUrl,
    super.expiresAt,
  });

  factory RewardItemModel.fromJson(Map<String, dynamic> json) {
    return RewardItemModel(
      id: (json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      costPoints: (json['cost_points'] ?? 0) as int,
      stockQuantity: (json['stock_quantity'] ?? 0) as int,
      status: RewardStatus.fromString(json['status'] as String?),
      imageUrl: json['image_url'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
    );
  }

  RewardItem toEntity() => this;
}

/// DTO của số dư ví điểm trả về từ API (/api/v1/loyalty/balance)
class UserWalletModel extends UserWallet {
  const UserWalletModel({
    required super.userId,
    required super.balance,
    required super.updatedAt,
  });

  factory UserWalletModel.fromJson(Map<String, dynamic> json) {
    return UserWalletModel(
      userId: (json['user_id'] ?? '') as String,
      balance: (json['balance'] ?? 0) as int,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  UserWallet toEntity() => this;
}

/// DTO của đơn hàng đổi quà thành công trả về từ API (/api/v1/loyalty/redeem)
class RedemptionOrderModel extends RedemptionOrder {
  const RedemptionOrderModel({
    required super.orderCode,
    required super.rewardId,
    required super.pointsSpent,
    super.voucherCode,
    required super.createdAt,
  });

  factory RedemptionOrderModel.fromJson(Map<String, dynamic> json) {
    return RedemptionOrderModel(
      orderCode: (json['order_code'] ?? '') as String,
      rewardId: (json['reward_id'] ?? '') as String,
      pointsSpent: (json['points_spent'] ?? 0) as int,
      voucherCode: json['voucher_code'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  RedemptionOrder toEntity() => this;
}
