class HouseholdMember {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String role;
  final DateTime joinedAt;

  const HouseholdMember({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.joinedAt,
  });

  bool get isOwner => role == 'owner';
  bool get isMember => role == 'member';

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.tryParse(json['joined_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

class Household {
  final String id;
  final String name;
  final String createdById;
  final DateTime createdAt;
  final List<HouseholdMember> members;

  const Household({
    required this.id,
    required this.name,
    required this.createdById,
    required this.createdAt,
    this.members = const [],
  });

  int get memberCount => members.length;

  HouseholdMember? get owner {
    for (final member in members) {
      if (member.isOwner) return member;
    }
    return null;
  }

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      createdById: json['created_by_id'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => HouseholdMember.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by_id': createdById,
      'created_at': createdAt.toIso8601String(),
      'members': members.map((m) => m.toJson()).toList(),
    };
  }
}
