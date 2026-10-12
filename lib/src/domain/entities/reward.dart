/// Trạng thái của món quà trong danh mục đổi điểm
enum RewardStatus {
  creating('creating', 'Đang khởi tạo'),
  draft('draft', 'Bản nháp'),
  published('published', 'Đang mở đổi'),
  expired('expired', 'Hết hạn');

  final String value;
  final String label;

  const RewardStatus(this.value, this.label);

  static RewardStatus fromString(String? value) {
    if (value == null) return RewardStatus.draft;
    final lower = value.toLowerCase();
    return RewardStatus.values.firstWhere(
      (s) => s.value.toLowerCase() == lower,
      orElse: () => RewardStatus.draft,
    );
  }

  bool get isPublished => this == RewardStatus.published;
  bool get isDraft => this == RewardStatus.draft;
  bool get isExpired => this == RewardStatus.expired;
  bool get isCreating => this == RewardStatus.creating;
}

/// Món quà / voucher trong danh mục đổi điểm xanh
class RewardItem {
  final String id;
  final String title;
  final String? description;
  final int costPoints;
  final int stockQuantity;
  final RewardStatus status;
  final String? imageUrl;
  final DateTime? expiresAt;

  const RewardItem({
    required this.id,
    required this.title,
    this.description,
    required this.costPoints,
    required this.stockQuantity,
    required this.status,
    this.imageUrl,
    this.expiresAt,
  });

  /// Kiểm tra quà có còn hàng hay không
  bool get isOutOfStock => stockQuantity <= 0;

  /// Kiểm tra quà đã hết hạn đổi hay chưa
  bool get isExpiredDate {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }

  /// Quà có sẵn sàng để đổi (được đăng bán, còn hàng, chưa hết hạn)
  bool get isAvailable => status.isPublished && !isOutOfStock && !isExpiredDate;

  /// Kiểm tra số dư người dùng có đủ điểm để đổi không
  bool canAfford(int balance) => balance >= costPoints;

  /// Định dạng chuỗi hiển thị số điểm
  String get formattedPoints {
    return costPoints.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'cost_points': costPoints,
      'stock_quantity': stockQuantity,
      'status': status.value,
      if (imageUrl != null) 'image_url': imageUrl,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }

  RewardItem copyWith({
    String? id,
    String? title,
    String? description,
    int? costPoints,
    int? stockQuantity,
    RewardStatus? status,
    String? imageUrl,
    DateTime? expiresAt,
  }) {
    return RewardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      costPoints: costPoints ?? this.costPoints,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// Ví điểm xanh của người dùng
class UserWallet {
  final String userId;
  final int balance;
  final DateTime updatedAt;

  const UserWallet({
    required this.userId,
    required this.balance,
    required this.updatedAt,
  });

  /// Định dạng chuỗi số dư điểm hiển thị (e.g. 1.250)
  String get formattedBalance {
    return balance.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  factory UserWallet.fromJson(Map<String, dynamic> json) {
    return UserWallet(
      userId: (json['user_id'] ?? '') as String,
      balance: (json['balance'] ?? 0) as int,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'balance': balance,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserWallet copyWith({
    String? userId,
    int? balance,
    DateTime? updatedAt,
  }) {
    return UserWallet(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Đơn hàng đổi quà thành công
class RedemptionOrder {
  final String orderCode;
  final String rewardId;
  final int pointsSpent;
  final String? voucherCode;
  final DateTime createdAt;

  const RedemptionOrder({
    required this.orderCode,
    required this.rewardId,
    required this.pointsSpent,
    this.voucherCode,
    required this.createdAt,
  });

  factory RedemptionOrder.fromJson(Map<String, dynamic> json) {
    return RedemptionOrder(
      orderCode: (json['order_code'] ?? '') as String,
      rewardId: (json['reward_id'] ?? '') as String,
      pointsSpent: (json['points_spent'] ?? 0) as int,
      voucherCode: json['voucher_code'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_code': orderCode,
      'reward_id': rewardId,
      'points_spent': pointsSpent,
      if (voucherCode != null) 'voucher_code': voucherCode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RedemptionOrder copyWith({
    String? orderCode,
    String? rewardId,
    int? pointsSpent,
    String? voucherCode,
    DateTime? createdAt,
  }) {
    return RedemptionOrder(
      orderCode: orderCode ?? this.orderCode,
      rewardId: rewardId ?? this.rewardId,
      pointsSpent: pointsSpent ?? this.pointsSpent,
      voucherCode: voucherCode ?? this.voucherCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
