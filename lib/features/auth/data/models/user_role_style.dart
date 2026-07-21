import 'package:flutter/material.dart';
import 'user_role.dart';

extension UserRoleStyle on UserRole {
  String get profileLabelKey {
    switch (this) {
      case UserRole.client:
        return 'profile_role_client';
      case UserRole.courier:
        return 'profile_role_courier';
      case UserRole.driver:
        return 'profile_role_driver';
      case UserRole.restaurant:
        return 'profile_role_restaurant';
      case UserRole.admin:
        return 'profile_role_admin';
    }
  }

  LinearGradient get profileGradient {
    switch (this) {
      case UserRole.admin:
        return const LinearGradient(
          colors: [Color(0xFF7EC8E3), Color(0xFF0B4429)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UserRole.client:
      case UserRole.courier:
      case UserRole.driver:
      case UserRole.restaurant:
        return const LinearGradient(
          colors: [Color(0xFFE8C868), Color(0xFFD4AF37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}