import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class CategoryToggleRow extends StatefulWidget {
  const CategoryToggleRow({super.key});

  @override
  State<CategoryToggleRow> createState() => _CategoryToggleRowState();
}

class _CategoryToggleRowState extends State<CategoryToggleRow> {
  bool taxiEnabled = true;
  bool foodEnabled = false;
  bool parcelsEnabled = false;

  Widget _row(String labelKey, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(context.l10n.t(labelKey), style: const TextStyle(fontWeight: FontWeight.w600))),
          Switch(value: value, activeColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.t('driver_categories_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        _row('driver_category_taxi', taxiEnabled, (v) => setState(() => taxiEnabled = v)),
        _row('driver_category_food', foodEnabled, (v) => setState(() => foodEnabled = v)),
        _row('driver_category_parcels', parcelsEnabled, (v) => setState(() => parcelsEnabled = v)),
      ],
    );
  }
}
