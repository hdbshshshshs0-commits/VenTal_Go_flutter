import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../navigation_deeplinks.dart';

class NavigationButtonsRow extends StatelessWidget {
  final LatLng destination;

  const NavigationButtonsRow({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NavButton(
            label: context.l10n.t('nav_2gis'),
            onTap: () => NavigationDeeplinks.open2Gis(destination),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NavButton(
            label: context.l10n.t('nav_yandex'),
            onTap: () => NavigationDeeplinks.openYandexNavigator(destination),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ),
    );
  }
}
