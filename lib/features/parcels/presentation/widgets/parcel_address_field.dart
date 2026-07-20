import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/parcel_address_details_model.dart';
import 'full_address_form_sheet.dart';

class ParcelAddressField extends StatelessWidget {
  final IconData icon;
  final String hintKey;
  final ParcelAddressDetails? value;
  final ValueChanged<ParcelAddressDetails> onChanged;

  const ParcelAddressField({
    super.key,
    required this.icon,
    required this.hintKey,
    required this.onChanged,
    this.value,
  });

  Future<void> _openForm(BuildContext context) async {
    final result = await FullAddressFormSheet.show(context, icon: icon, hintKey: hintKey, initial: value);
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openForm(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value?.address ?? context.l10n.t(hintKey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: value != null ? AppColors.textDark : AppColors.textHint,
                  fontWeight: value != null ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}