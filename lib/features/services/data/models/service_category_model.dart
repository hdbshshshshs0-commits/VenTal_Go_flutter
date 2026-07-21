import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final IconData icon;
  final String labelKey;
  final bool isAvailable; // false = заглушка, ещё не реализовано

  const ServiceCategory({
    required this.id,
    required this.icon,
    required this.labelKey,
    this.isAvailable = false,
  });
}