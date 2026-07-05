import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class IncomingOrderCard extends StatelessWidget {
  final String fromAddress;
  final String toAddress;
  final int driverEarnings;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingOrderCard({
    super.key,
    required this.fromAddress,
    required this.toAddress,
    required this.driverEarnings,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, -6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.t('driver_new_order'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('$driverEarnings тг', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
          const SizedBox(height: 16),
          Row(children: [const Icon(Icons.trip_origin, size: 16, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text(fromAddress, style: const TextStyle(fontSize: 14)))]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.location_on, size: 16, color: AppColors.error), const SizedBox(width: 8), Expanded(child: Text(toAddress, style: const TextStyle(fontSize: 14)))]),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(context.l10n.t('driver_decline')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(context.l10n.t('driver_accept'), style: const TextStyle(color: AppColors.textLight)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
