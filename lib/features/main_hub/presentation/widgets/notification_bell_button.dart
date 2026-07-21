import 'package:flutter/material.dart';

class NotificationBellButton extends StatelessWidget {
  final VoidCallback onTap;

  const NotificationBellButton({super.key, required this.onTap});

  static const goldColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.notifications_none_rounded, color: goldColor, size: 26),
      splashRadius: 22,
    );
  }
}