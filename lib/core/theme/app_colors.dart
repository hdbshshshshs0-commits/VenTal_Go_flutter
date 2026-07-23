import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF05C283);
  static const Color primaryDark = Color(0xFF038A5A);
  static const Color accent = Color(0xFFB3EDD8);
  static const Color background = Color(0xFFF8F9FA);

  static const Color textDark = Color(0xFF1B1F1D);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A05C283);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color textHint = Color(0xFF9CA3AF);

  static const Color success = Color(0xFF05C283);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);

  /// Gradient for profile header and branded surfaces
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF05C283), Color(0xFF038A5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
