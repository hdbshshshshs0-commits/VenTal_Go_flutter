import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

class AddressPill extends StatelessWidget {
  final String address;
  final VoidCallback? onTap;

  const AddressPill({super.key, required this.address, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 6),
            Text(address, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textDark, size: 18),
          ],
        ),
      ),
    );
  }
}