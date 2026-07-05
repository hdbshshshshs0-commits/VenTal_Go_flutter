import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/car_class_model.dart';

class CarClassCard extends StatelessWidget {
  final CarClassPricing pricing;
  final double distanceKm;
  final bool isSelected;
  final VoidCallback onTap;

  const CarClassCard({
    super.key,
    required this.pricing,
    required this.distanceKm,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final price = (pricing.minPrice + pricing.kmRate * distanceKm).round();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 40,
              child: Image.asset(pricing.photoPath, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.t(pricing.carClass.stringKey),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
              ),
            ),
            Text(
              '$price тг',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
