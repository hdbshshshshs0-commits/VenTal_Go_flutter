import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/service_tile_model.dart';

class ServicesPreviewRow extends StatelessWidget {
  final List<ServiceTileModel> tiles;
  final ValueChanged<ServiceTileModel> onTap;
  final VoidCallback onSeeAll;

  const ServicesPreviewRow({super.key, required this.tiles, required this.onTap, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.t('main_hub_services_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textDark)),
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text(context.l10n.t('main_hub_see_all'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: tiles.map((tile) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(tile),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Image.asset(tile.iconPath, width: 26, height: 26, color: AppColors.primary),
                    ),
                    const SizedBox(height: 6),
                    Text(context.l10n.t(tile.labelKey), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}