class HouseholdJoinRequest {
  final String id;
  final String householdId;
  final String householdName;
  final String userId;
  final String userFullName;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HouseholdJoinRequest({
    required this.id,
    required this.householdId,
    required this.householdName,
    required this.userId,
    required this.userFullName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  factory HouseholdJoinRequest.fromJson(Map<String, dynamic> json) {
    return HouseholdJoinRequest(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      householdName: json['household_name'] as String? ?? '',
      userId: json['user_id'] as String,
      userFullName: json['user_full_name'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'household_name': householdName,
      'user_id': userId,
      'user_full_name': userFullName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
