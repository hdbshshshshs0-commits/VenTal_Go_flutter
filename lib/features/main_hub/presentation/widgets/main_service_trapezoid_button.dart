import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'trapezoid_clipper.dart';

class MainServiceTrapezoidButton extends StatelessWidget {
  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  const MainServiceTrapezoidButton({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipPath(
            clipper: const TrapezoidClipper(),
            child: Container(
              width: double.infinity,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.4),
              ),
              child: Center(
                child: Image.asset(iconAsset, width: 34, height: 34, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
        ],
      ),
    );
  }
}