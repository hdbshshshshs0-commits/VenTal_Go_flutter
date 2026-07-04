import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class MainServicesRow extends StatelessWidget {
  const MainServicesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MainServiceCircle(
          label: AppStrings.t('tile_food'),
          imagePath: 'assets/images/services/food.png',
          onTap: () {},
        ),
        _MainServiceCircle(
          label: AppStrings.t('tile_taxi'),
          imagePath: 'assets/images/services/taxi.png',
          onTap: () {},
        ),
        _MainServiceCircle(
          label: AppStrings.t('tile_parcels'),
          imagePath: 'assets/images/services/parcels.png',
          onTap: () {},
        ),
      ],
    );
  }
}

class _MainServiceCircle extends StatefulWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;

  const _MainServiceCircle({
    required this.label,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<_MainServiceCircle> createState() => _MainServiceCircleState();
}

class _MainServiceCircleState extends State<_MainServiceCircle> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: AppColors.cardShadow, blurRadius: 14, offset: Offset(0, 6)),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: ClipOval(
                child: Image.asset(widget.imagePath, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}