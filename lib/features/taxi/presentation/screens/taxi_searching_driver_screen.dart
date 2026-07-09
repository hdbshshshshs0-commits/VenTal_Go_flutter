import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/ride/ride_status_controller.dart';
import 'package:vental_go/data/models/ride_status_model.dart';
import '../widgets/radar_pulse.dart';
import 'taxi_trip_screen.dart';

class TaxiSearchingDriverScreen extends StatefulWidget {
  const TaxiSearchingDriverScreen({super.key});

  @override
  State<TaxiSearchingDriverScreen> createState() => _TaxiSearchingDriverScreenState();
}

class _TaxiSearchingDriverScreenState extends State<TaxiSearchingDriverScreen> {
  late final RideStatusController _rideController;

  @override
  void initState() {
    super.initState();
    _rideController = RideStatusController();
    _rideController.startSearching();
    _rideController.addListener(_onStatusChanged);
  }

  void _onStatusChanged() {
    if (_rideController.status == RideStatus.driverAssigned && mounted) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => TaxiTripScreen(rideController: _rideController)),
        );
      });
    }
  }

  @override
  void dispose() {
    _rideController.removeListener(_onStatusChanged);
    _rideController.cancelSearch();
    _rideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            RadarPulse(
              maxSize: 300,
              color: AppColors.success,
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFE7B93A), Color(0xFFC9932A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.local_taxi_rounded, color: Colors.white, size: 44),
              ),
            ),
            const Spacer(flex: 2),
            Text(
              context.l10n.t('taxi_searching_driver'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.t('taxi_searching_driver_subtitle'),
              style: const TextStyle(fontSize: 15, color: AppColors.textHint),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.divider, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  _rideController.cancelSearch();
                  Navigator.of(context).pop();
                },
                child: Text(
                  context.l10n.t('taxi_cancel_search'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
