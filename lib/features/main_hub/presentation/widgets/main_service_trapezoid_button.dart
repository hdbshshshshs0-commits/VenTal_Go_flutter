import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'trapezoid_clipper.dart';

class MainServiceTrapezoidButton extends StatelessWidget {
  final String iconAsset;
  final String label;
  final VoidCallback onTap;
  final Color accentColor;

  const MainServiceTrapezoidButton({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.accentColor = AppColors.primary,
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
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.4),
              ),
              child: Center(
                child: Image.asset(iconAsset, width: 44, height: 44, fit: BoxFit.contain, color: accentColor),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
        ],
      ),
    );
  }
}