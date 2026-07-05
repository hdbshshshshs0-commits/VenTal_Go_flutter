import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/widgets/pulse_indicator.dart';

class GeoProximityIndicator extends StatelessWidget {
  final int distanceMeters;

  const GeoProximityIndicator({super.key, required this.distanceMeters});

  bool get isInZone => distanceMeters <= 150;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseIndicator(color: isInZone ? AppColors.success : AppColors.warning, size: 36),
        const SizedBox(width: 10),
        Text(
          '$distanceMeters ${context.l10n.t('courier_meters_left')}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isInZone ? AppColors.success : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
