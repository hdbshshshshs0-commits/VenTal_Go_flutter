import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/maps/widgets/navigation_buttons_row.dart';
import 'taxi_rating_screen.dart';

class TaxiRideInProgressScreen extends StatefulWidget {
  const TaxiRideInProgressScreen({super.key});

  @override
  State<TaxiRideInProgressScreen> createState() => _TaxiRideInProgressScreenState();
}

class _TaxiRideInProgressScreenState extends State<TaxiRideInProgressScreen> {
  static const LatLng _mockDestination = LatLng(51.1605, 71.4704);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMapWidget(initialPosition: _mockDestination),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: Offset(0, 6))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 24, backgroundColor: AppColors.divider, child: Icon(Icons.person, color: AppColors.textDark)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Водитель', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            Text('${context.l10n.t('taxi_arrives_in')} 3 ${context.l10n.t('taxi_min_short')}', style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const NavigationButtonsRow(destination: _mockDestination),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.textDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TaxiRatingScreen()));
                      },
                      child: const Text('Завершить (тест)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
