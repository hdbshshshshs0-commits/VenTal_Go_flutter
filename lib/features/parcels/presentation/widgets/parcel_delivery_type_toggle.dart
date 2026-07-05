import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/parcel_model.dart';

class ParcelDeliveryTypeToggle extends StatelessWidget {
  final ParcelDeliveryType selected;
  final ValueChanged<ParcelDeliveryType> onChanged;

  const ParcelDeliveryTypeToggle({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.t('parcel_delivery_type_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 10),
        Row(
          children: ParcelDeliveryType.values.map((type) {
            final isSelected = type == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: type == ParcelDeliveryType.toAddress ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
                  ),
                  child: Text(
                    context.l10n.t(type.titleKey),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? AppColors.textLight : AppColors.textDark, fontSize: 13),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
