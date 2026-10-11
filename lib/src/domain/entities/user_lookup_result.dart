class UserLookupResult {
  final String userId;
  final String fullName;
  final bool canInvite;
  final String? reason;

  const UserLookupResult({
    required this.userId,
    required this.fullName,
    required this.canInvite,
    this.reason,
  });

  factory UserLookupResult.fromJson(Map<String, dynamic> json) {
    return UserLookupResult(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String? ?? '',
      canInvite: json['can_invite'] as bool? ?? false,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'can_invite': canInvite,
      'reason': reason,
    };
  }
}
