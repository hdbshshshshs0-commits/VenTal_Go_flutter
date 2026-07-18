import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/car_class_model.dart';

class CarClassCard extends StatelessWidget {
  final CarClassPricing pricing;
  final double distanceKm;
  final double? durationMin;
  final bool isSelected;
  final VoidCallback onTap;

  const CarClassCard({
    super.key,
    required this.pricing,
    required this.distanceKm,
    required this.isSelected,
    required this.onTap,
    this.durationMin,
  });

  @override
  Widget build(BuildContext context) {
    final price = (pricing.minPrice + pricing.kmRate * distanceKm).round();
    final timeText = durationMin != null ? '${durationMin!.round()} ${context.l10n.t('taxi_min_short')}' : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 48,
              child: Image.asset(pricing.photoPath, fit: BoxFit.contain),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.t(pricing.carClass.stringKey),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '$price тг',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark),
                      ),
                      if (timeText != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '· $timeText',
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.textHint),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}