import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';

class CenterPin extends StatelessWidget {
  const CenterPin({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 22),
              ),
              Container(width: 3, height: 14, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
