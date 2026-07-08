import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/car_class_model.dart';
import '../../data/pricing/taxi_pricing_calculator.dart';

class PriceBreakdownSheet extends StatelessWidget {
  final CityType cityType;
  final CarClass carClass;
  final double distanceKm;

  const PriceBreakdownSheet({
    super.key,
    required this.cityType,
    required this.carClass,
    required this.distanceKm,
  });

  static Future<void> show(
    BuildContext context, {
    required CityType cityType,
    required CarClass carClass,
    required double distanceKm,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PriceBreakdownSheet(cityType: cityType, carClass: carClass, distanceKm: distanceKm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pricing = TaxiPricingCalculator.classesFor(cityType).firstWhere((p) => p.carClass == carClass);
    final distanceCost = (pricing.kmRate * distanceKm).round();
    final total = pricing.minPrice + distanceCost;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text(
            context.l10n.t('price_breakdown_title'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          _row(context, 'price_breakdown_boarding', '${pricing.minPrice} тг'),
          const SizedBox(height: 10),
          _row(context, 'price_breakdown_distance', '$distanceCost тг'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          _row(context, 'price_breakdown_total', '$total тг', bold: true),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String labelKey, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.t(labelKey),
          style: TextStyle(
            fontSize: bold ? 15 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: bold ? AppColors.textDark : AppColors.textHint,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}