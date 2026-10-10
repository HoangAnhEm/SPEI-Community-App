class User {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final String role;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.role,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phone,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: (json['phone_number'] ?? json['phone'] ?? '') as String,
      fullName: (json['full_name'] ?? json['fullName'] ?? '') as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
