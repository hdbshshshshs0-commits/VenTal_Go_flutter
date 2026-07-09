import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/data/models/ride_status_model.dart';
import 'package:vental_go/data/models/driver_model.dart';

class DriverInfoSheet extends StatelessWidget {
  final DriverInfo driver;
  final RideStatus status;
  final bool passengerConfirmedExit;
  final VoidCallback onConfirmExit;

  const DriverInfoSheet({
    super.key,
    required this.driver,
    required this.status,
    required this.passengerConfirmedExit,
    required this.onConfirmExit,
  });

  Future<void> _callDriver() async {
    final uri = Uri(scheme: 'tel', path: driver.phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, -6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(status),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: Text(
                context.l10n.t(status.stringKey),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.divider,
                backgroundImage: AssetImage(driver.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${driver.carModel} · ${driver.carPlate}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textHint),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 15, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text('${driver.rating}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      ],
                    ),
                  ],
                ),
              ),
              Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _callDriver,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.phone_rounded, color: AppColors.textLight, size: 20),
                  ),
                ),
              ),
            ],
          ),
          if (status == RideStatus.driverArrived && !passengerConfirmedExit) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onConfirmExit,
                child: Text(
                  context.l10n.t('ride_passenger_exit_button'),
                  style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
