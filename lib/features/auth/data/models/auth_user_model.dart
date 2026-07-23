import 'user_role.dart';

class AuthUserModel {
  final String phone;
  final String name;
  final UserRole role;
  final String? email;
  final String? avatarPath; // local file path after user picks image

  const AuthUserModel({
    required this.phone,
    required this.name,
    required this.role,
    this.email,
    this.avatarPath,
  });

  AuthUserModel copyWith({
    String? phone,
    String? name,
    UserRole? role,
    String? email,
    String? avatarPath,
  }) {
    return AuthUserModel(
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'name': name,
        'role': role.name,
        if (email != null) 'email': email,
        if (avatarPath != null) 'avatarPath': avatarPath,
      };

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      phone: json['phone'] as String,
      name: json['name'] as String,
      role: UserRole.values.byName(json['role'] as String),
      email: json['email'] as String?,
      avatarPath: json['avatarPath'] as String?,
    );
  }
}
