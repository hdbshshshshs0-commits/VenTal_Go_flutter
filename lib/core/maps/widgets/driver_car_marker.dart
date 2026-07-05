import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';

class DriverCarMarker extends StatelessWidget {
  final double rotationDegrees;

  const DriverCarMarker({super.key, this.rotationDegrees = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationDegrees * 3.1415926535 / 180,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}
