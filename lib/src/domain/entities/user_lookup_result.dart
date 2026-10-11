class UserLookupResult {
  final String userId;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final bool canInvite;
  final String? reason;

  const UserLookupResult({
    required this.userId,
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.canInvite,
    this.reason,
  });

  factory UserLookupResult.fromJson(Map<String, dynamic> json) {
    return UserLookupResult(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      canInvite: json['can_invite'] as bool? ?? false,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'can_invite': canInvite,
      'reason': reason,
    };
  }
}

