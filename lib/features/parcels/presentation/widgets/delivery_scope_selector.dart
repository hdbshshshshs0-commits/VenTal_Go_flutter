import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/parcel_contact_model.dart';

class DeliveryScopeSelector extends StatelessWidget {
  final DeliveryScope selected;
  final ValueChanged<DeliveryScope> onSelect;

  const DeliveryScopeSelector({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _button(context, DeliveryScope.doorToDoor, 'parcel_delivery_door_to_door')),
        const SizedBox(width: 8),
        Expanded(child: _button(context, DeliveryScope.buildingToBuilding, 'parcel_delivery_building_to_building')),
      ],
    );
  }

  Widget _button(BuildContext context, DeliveryScope scope, String labelKey) {
    final isSelected = scope == selected;
    return GestureDetector(
      onTap: () => onSelect(scope),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          context.l10n.t(labelKey),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: isSelected ? AppColors.textLight : AppColors.textDark),
        ),
      ),
    );
  }
}
