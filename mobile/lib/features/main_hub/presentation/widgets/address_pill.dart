import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AddressPill extends StatelessWidget {
  const AddressPill({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
            SizedBox(width: 6),
            Text(
              'Мангилик Ел, 28',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textDark, size: 18),
          ],
        ),
      ),
    );
  }
}