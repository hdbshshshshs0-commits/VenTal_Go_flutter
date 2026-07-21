import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/history_order_model.dart';

class HistoryFilterChips extends StatelessWidget {
  final HistoryOrderCategory? selected; // null = "Все"
  final ValueChanged<HistoryOrderCategory?> onChanged;

  const HistoryFilterChips({super.key, required this.selected, required this.onChanged});

  static const _filters = [
    (category: null, labelKey: 'history_filter_all', icon: null),
    (category: HistoryOrderCategory.delivery, labelKey: 'history_filter_delivery', icon: Icons.electric_moped_rounded),
    (category: HistoryOrderCategory.taxi, labelKey: 'tile_taxi', icon: Icons.directions_car_rounded),
    (category: HistoryOrderCategory.food, labelKey: 'tile_food', icon: Icons.fastfood_rounded),
    (category: HistoryOrderCategory.parcels, labelKey: 'tile_parcels', icon: Icons.inventory_2_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter.category == selected;
          return GestureDetector(
            onTap: () => onChanged(filter.category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter.icon != null) ...[
                    Icon(filter.icon, size: 16, color: isSelected ? Colors.white : AppColors.textDark),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    context.l10n.t(filter.labelKey),
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? Colors.white : AppColors.textDark),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}