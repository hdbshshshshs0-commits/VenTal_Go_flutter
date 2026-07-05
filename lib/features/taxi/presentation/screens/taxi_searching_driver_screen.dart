import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'taxi_ride_in_progress_screen.dart';

class TaxiSearchingDriverScreen extends StatefulWidget {
  const TaxiSearchingDriverScreen({super.key});

  @override
  State<TaxiSearchingDriverScreen> createState() => _TaxiSearchingDriverScreenState();
}

class _TaxiSearchingDriverScreenState extends State<TaxiSearchingDriverScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _mockTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _mockTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TaxiRideInProgressScreen()));
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.local_taxi_rounded, color: Colors.white, size: 44),
              ),
            ),
            const SizedBox(height: 24),
            Text(context.l10n.t('taxi_searching_driver'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(context.l10n.t('taxi_searching_driver_subtitle'), style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(context.l10n.t('taxi_cancel_search')),
            ),
          ],
        ),
      ),
    );
  }
}
