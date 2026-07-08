import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'address_autocomplete_field.dart';

class AddressStepSheet extends StatelessWidget {
  final IconData icon;
  final String hintKey;
  final String titleKey;
  final LatLng? biasPosition;
  final String? cityName;
  final bool showLocateButton;
  final bool isLocating;
  final VoidCallback? onLocateTap;
  final bool canConfirm;
  final VoidCallback onConfirm;
  final void Function(String address, LatLng coordinates) onAddressSelected;

  const AddressStepSheet({
    super.key,
    required this.icon,
    required this.hintKey,
    required this.titleKey,
    required this.canConfirm,
    required this.onConfirm,
    required this.onAddressSelected,
    this.biasPosition,
    this.cityName,
    this.showLocateButton = false,
    this.isLocating = false,
    this.onLocateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, -6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.t(titleKey),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AddressAutocompleteField(
                  icon: icon,
                  hintKey: hintKey,
                  biasPosition: biasPosition,
                  cityName: cityName,
                  onAddressSelected: onAddressSelected,
                ),
              ),
              if (showLocateButton) ...[
                const SizedBox(width: 8),
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: isLocating ? null : onLocateTap,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: isLocating
                          ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: canConfirm ? onConfirm : null,
              child: Text(
                context.l10n.t('address_confirm_button'),
                style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}