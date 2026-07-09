import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/city/city_controller.dart';
import '../widgets/city_picker_sheet.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cityController = context.watch<CityController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('profile_section_addresses')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 3))],
            ),
            child: ListTile(
              leading: const Icon(Icons.location_city_rounded, color: AppColors.primary),
              title: Text(
                context.l10n.t('profile_city_label'),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textHint),
              ),
              subtitle: Text(
                cityController.selectedCity.displayName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              onTap: () => CityPickerSheet.show(context),
            ),
          ),
        ],
      ),
    );
  }
}
