import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/parcel_model.dart';

class ParcelCategorySelector extends StatelessWidget {
  final ParcelCategory selected;
  final ValueChanged<ParcelCategory> onChanged;

  const ParcelCategorySelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.t('parcel_category_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: ParcelCategory.values.map((cat) {
            final isSelected = cat == selected;
            return GestureDetector(
              onTap: () => onChanged(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
                ),
                child: Text(
                  context.l10n.t(cat.titleKey),
                  style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? AppColors.textLight : AppColors.textDark, fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
