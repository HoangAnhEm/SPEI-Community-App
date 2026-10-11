class HouseholdInvitation {
  final String id;
  final String householdId;
  final String householdName;
  final String inviterId;
  final String inviterName;
  final String inviteeId;
  final String inviteeName;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;

  const HouseholdInvitation({
    required this.id,
    required this.householdId,
    required this.householdName,
    required this.inviterId,
    required this.inviterName,
    required this.inviteeId,
    required this.inviteeName,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired' || DateTime.now().isAfter(expiresAt);
  bool get isRevoked => status == 'revoked';

  factory HouseholdInvitation.fromJson(Map<String, dynamic> json) {
    return HouseholdInvitation(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      householdName: json['household_name'] as String? ?? '',
      inviterId: json['inviter_id'] as String? ?? '',
      inviterName: json['inviter_name'] as String? ?? '',
      inviteeId: json['invitee_id'] as String? ?? '',
      inviteeName: json['invitee_name'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'household_name': householdName,
      'inviter_id': inviterId,
      'inviter_name': inviterName,
      'invitee_id': inviteeId,
      'invitee_name': inviteeName,
      'status': status,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
