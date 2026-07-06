import 'user_role.dart';

class AuthUserModel {
  final String phone;
  final String name;
  final UserRole role;

  const AuthUserModel({required this.phone, required this.name, required this.role});
}
