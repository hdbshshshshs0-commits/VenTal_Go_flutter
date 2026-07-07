import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/geocoding/geocoding_service.dart';
import 'package:vental_go/core/routing/osrm_service.dart';
import '../../data/models/car_class_model.dart';
import '../../data/models/payment_method_model.dart';
import '../widgets/car_class_bottom_sheet.dart';
import 'taxi_searching_driver_screen.dart';

class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen> {
  LatLng? _userPosition;

  LatLng? _fromLatLng;
  LatLng? _toLatLng;
  CarClass selectedClass = CarClass.economy;
  PaymentMethod selectedPayment = PaymentMethod.card;
  final CityType cityType = CityType.bigCity;
  double distanceKm = 0;
  List<LatLng>? _routePoints;
  MapLibreMapController? _mapController;

  Future<void> _updateRoute() async {
    final from = _fromLatLng;
    final to = _toLatLng;
    if (from == null || to == null) return;

    setState(() { distanceKm = 0; _routePoints = null; });

    final result = await OsrmService.getRoute(from, to);
    if (!mounted) return;

    setState(() {
      _routePoints = result?.geometry;
      distanceKm = result?.distanceKm ?? GeocodingService.calculateDistanceKm(from, to);
    });

    _fitCameraToRoute(from, to);
  }

  Future<void> _fitCameraToRoute(LatLng from, LatLng to) async {
    final ctrl = _mapController;
    if (ctrl == null) return;
    await ctrl.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            math.min(from.latitude, to.latitude) - 0.005,
            math.min(from.longitude, to.longitude) - 0.005,
          ),
          northeast: LatLng(
            math.max(from.latitude, to.latitude) + 0.005,
            math.max(from.longitude, to.longitude) + 0.005,
          ),
        ),
        left: 60,
        top: 80,
        right: 60,
        bottom: 340,
      ),
    );
  }

  void _handleOrder() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TaxiSearchingDriverScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMapWidget(
              initialPosition: _userPosition,
              showCenterPin: false,
              routePoints: _routePoints,
              onMapReady: (controller) => _mapController = controller,
              onUserLocationFound: (position) => setState(() => _userPosition = position),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: CarClassBottomSheet(
              dataLoaded: true,
              cityType: cityType,
              biasPosition: _userPosition,
              onFromSelected: (address, latLng) {
                setState(() => _fromLatLng = latLng);
                _updateRoute();
              },
              onToSelected: (address, latLng) {
                setState(() => _toLatLng = latLng);
                _updateRoute();
              },
              selectedClass: selectedClass,
              onClassSelected: (c) => setState(() => selectedClass = c),
              selectedPayment: selectedPayment,
              onPaymentChanged: (p) => setState(() => selectedPayment = p),
              distanceKm: distanceKm,
              onOrder: _handleOrder,
            ),
          ),
        ],
      ),
    );
  }
}