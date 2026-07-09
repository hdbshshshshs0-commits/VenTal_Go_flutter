import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/ride/ride_status_controller.dart';
import '../widgets/driver_info_sheet.dart';

class TaxiTripScreen extends StatefulWidget {
  final RideStatusController rideController;

  const TaxiTripScreen({super.key, required this.rideController});

  @override
  State<TaxiTripScreen> createState() => _TaxiTripScreenState();
}

class _TaxiTripScreenState extends State<TaxiTripScreen> {
  @override
  void initState() {
    super.initState();
    widget.rideController.addListener(_onStatusChanged);
  }

  void _onStatusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.rideController.removeListener(_onStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.rideController.driver;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: AppMapWidget(showCenterPin: false, showLocateButton: false),
          ),
          if (driver != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: DriverInfoSheet(
                  key: const ValueKey('driver_sheet'),
                  driver: driver,
                  status: widget.rideController.status,
                  passengerConfirmedExit: widget.rideController.passengerConfirmedExit,
                  onConfirmExit: widget.rideController.confirmPassengerExit,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
