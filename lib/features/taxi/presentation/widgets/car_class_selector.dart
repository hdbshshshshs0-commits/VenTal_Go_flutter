import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/car_class_model.dart';

class CarClassSelector extends StatelessWidget {
  final List<CarClassPricing> classes;
  final CarClass selectedClass;
  final double distanceKm;
  final ValueChanged<CarClass> onSelect;

  const CarClassSelector({
    super.key,
    required this.classes,
    required this.selectedClass,
    required this.distanceKm,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: classes.map((pricing) {
        final isSelected = pricing.carClass == selectedClass;
        final price = (pricing.minPrice + pricing.kmRate * distanceKm).round();

        return GestureDetector(
          onTap: () => onSelect(pricing.carClass),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.directions_car_filled_rounded, color: isSelected ? AppColors.textLight : AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.t(pricing.carClass.stringKey),
                    style: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? AppColors.textLight : AppColors.textDark),
                  ),
                ),
                Text(
                  '$price тг',
                  style: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? AppColors.textLight : AppColors.textDark),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}