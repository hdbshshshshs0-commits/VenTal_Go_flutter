import 'user_role.dart';

class AuthUserModel {
  final String phone;
  final String name;
  final UserRole role;

  const AuthUserModel({required this.phone, required this.name, required this.role});

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'name': name,
        'role': role.name,
      };

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      phone: json['phone'] as String,
      name: json['name'] as String,
      role: UserRole.values.byName(json['role'] as String),
    );
  }
}