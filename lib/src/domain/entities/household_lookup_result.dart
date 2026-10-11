class HouseholdLookupResult {
  final String householdId;
  final String name;
  final String ownerName;
  final int memberCount;
  final DateTime? createdAt;
  final bool canRequest;
  final String? reason;

  const HouseholdLookupResult({
    required this.householdId,
    required this.name,
    required this.ownerName,
    required this.memberCount,
    this.createdAt,
    required this.canRequest,
    this.reason,
  });

  factory HouseholdLookupResult.fromJson(Map<String, dynamic> json) {
    return HouseholdLookupResult(
      householdId: json['household_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      ownerName: json['owner_name'] as String? ?? '',
      memberCount: json['member_count'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      canRequest: json['can_request'] as bool? ?? true,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'household_id': householdId,
      'name': name,
      'owner_name': ownerName,
      'member_count': memberCount,
      'created_at': createdAt?.toIso8601String(),
      'can_request': canRequest,
      'reason': reason,
    };
  }
}
