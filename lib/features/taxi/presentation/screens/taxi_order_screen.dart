import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/geocoding/geocoding_service.dart';
import 'package:vental_go/core/routing/osrm_service.dart';
import 'package:vental_go/core/city/city_controller.dart';
import 'package:vental_go/core/location/location_service.dart';
import '../../data/models/car_class_model.dart';
import '../../data/models/payment_method_model.dart';
import '../widgets/car_class_bottom_sheet.dart';
import '../widgets/address_step_sheet.dart';
import 'taxi_searching_driver_screen.dart';

enum _OrderStep { pickingFrom, pickingTo, choosingClass }

class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen> {
  _OrderStep _step = _OrderStep.pickingFrom;

  LatLng? _userPosition;
  bool _locatingUser = false;

  String? _fromAddress;
  LatLng? _fromLatLng;
  String? _toAddress;
  LatLng? _toLatLng;

  CarClass selectedClass = CarClass.economy;
  PaymentMethod selectedPayment = PaymentMethod.cash;
  final CityType cityType = CityType.bigCity;
  double distanceKm = 0;
  double? durationMin;
  List<LatLng>? _routePoints;
  MapLibreMapController? _mapController;

  Future<void> _updateRoute() async {
    final from = _fromLatLng;
    final to = _toLatLng;
    if (from == null || to == null) return;

    setState(() { distanceKm = 0; durationMin = null; _routePoints = null; });

    final result = await OsrmService.getRoute(from, to);
    if (!mounted) return;

    setState(() {
      _routePoints = result?.geometry;
      distanceKm = result?.distanceKm ?? GeocodingService.calculateDistanceKm(from, to);
      durationMin = result?.durationMin;
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

  Future<void> _handleLocateFrom() async {
    setState(() => _locatingUser = true);
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _userPosition = position);
      await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось получить геолокацию')),
      );
    } finally {
      if (mounted) setState(() => _locatingUser = false);
    }
  }

  void _confirmFrom() {
    if (_fromLatLng == null) return;
    setState(() => _step = _OrderStep.pickingTo);
  }

  void _confirmTo() {
    if (_toLatLng == null) return;
    setState(() => _step = _OrderStep.choosingClass);
    _updateRoute();
  }

  void _handleOrder() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TaxiSearchingDriverScreen()),
    );
  }

  /// Вызывается при перетаскивании карты, когда центр-пин активен
  /// (на шагах выбора адреса откуда/куда). Обновляет координаты сразу,
  /// адрес — как только приходит реверс-геокодинг.
  void _handleCenterChanged(LatLng position, String? address) {
    setState(() {
      if (_step == _OrderStep.pickingFrom) {
        _fromLatLng = position;
        if (address != null) _fromAddress = address;
      } else if (_step == _OrderStep.pickingTo) {
        _toLatLng = position;
        if (address != null) _toAddress = address;
      }
    });
  }

  void _swapAddresses() {
    setState(() {
      final tempAddress = _fromAddress;
      final tempLatLng = _fromLatLng;
      _fromAddress = _toAddress;
      _fromLatLng = _toLatLng;
      _toAddress = tempAddress;
      _toLatLng = tempLatLng;
    });
    _updateRoute();
  }

  @override
  Widget build(BuildContext context) {
    final cityController = context.watch<CityController>();
    final city = cityController.selectedCity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMapWidget(
              initialPosition: _userPosition ?? city.center,
              showCenterPin: _step != _OrderStep.choosingClass,
              routePoints: _routePoints,
              onMapReady: (controller) => _mapController = controller,
              onUserLocationFound: (position) => setState(() => _userPosition = position),
              onCenterChanged: _step == _OrderStep.choosingClass ? null : _handleCenterChanged,
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
                    onPressed: () {
                      if (_step == _OrderStep.pickingTo) {
                        setState(() => _step = _OrderStep.pickingFrom);
                      } else if (_step == _OrderStep.choosingClass) {
                        setState(() => _step = _OrderStep.pickingTo);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: _buildBottomContent(city.displayName),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContent(String cityName) {
    switch (_step) {
      case _OrderStep.pickingFrom:
        return Align(
          key: const ValueKey('from'),
          alignment: Alignment.bottomCenter,
          child: AddressStepSheet(
            icon: Icons.trip_origin,
            hintKey: 'taxi_from',
            titleKey: 'taxi_from_title',
            biasPosition: _userPosition ?? _fromLatLng,
            cityName: cityName,
            initialAddress: _fromAddress,
            showLocateButton: true,
            isLocating: _locatingUser,
            onLocateTap: _handleLocateFrom,
            canConfirm: _fromLatLng != null,
            onConfirm: _confirmFrom,
            onAddressSelected: (address, latLng) {
              setState(() {
                _fromAddress = address;
                _fromLatLng = latLng;
              });
              _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
            },
          ),
        );
      case _OrderStep.pickingTo:
        return Align(
          key: const ValueKey('to'),
          alignment: Alignment.bottomCenter,
          child: AddressStepSheet(
            icon: Icons.location_on,
            hintKey: 'taxi_to',
            titleKey: 'taxi_to_title',
            biasPosition: _fromLatLng,
            cityName: cityName,
            initialAddress: _toAddress,
            canConfirm: _toLatLng != null,
            onConfirm: _confirmTo,
            onAddressSelected: (address, latLng) {
              setState(() {
                _toAddress = address;
                _toLatLng = latLng;
              });
              _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
            },
          ),
        );
      case _OrderStep.choosingClass:
        return CarClassBottomSheet(
          key: const ValueKey('class'),
          dataLoaded: true,
          cityType: cityType,
          biasPosition: _userPosition,
          cityName: cityName,
          fromAddress: _fromAddress ?? '',
          toAddress: _toAddress ?? '',
          onFromSelected: (address, latLng) {
            setState(() {
              _fromAddress = address;
              _fromLatLng = latLng;
            });
            _updateRoute();
          },
          onToSelected: (address, latLng) {
            setState(() {
              _toAddress = address;
              _toLatLng = latLng;
            });
            _updateRoute();
          },
          selectedClass: selectedClass,
          onClassSelected: (c) => setState(() => selectedClass = c),
          selectedPayment: selectedPayment,
          onPaymentChanged: (p) => setState(() => selectedPayment = p),
          distanceKm: distanceKm,
          onOrder: _handleOrder,
          onSwapAddresses: _swapAddresses,
          durationMin: durationMin,
        );
    }
  }
}