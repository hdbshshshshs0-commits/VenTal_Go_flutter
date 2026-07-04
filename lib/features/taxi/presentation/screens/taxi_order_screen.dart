import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/location/location_service.dart';
import '../../data/models/car_class_model.dart';
import '../../data/pricing/taxi_pricing_calculator.dart';
import '../widgets/address_input_field.dart';
import '../widgets/car_class_selector.dart';
import '../widgets/taxi_screen_skeleton.dart';

class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen> {
  bool _dataLoaded = false;
  LatLng? _userPosition;
  String? _locationErrorKey;

  String fromAddress = '';
  String toAddress = '';
  CarClass selectedClass = CarClass.economy;
  final CityType cityType = CityType.bigCity;
  double distanceKm = 0; // TODO: расчёт через геокодер (Photon/Nominatim), пока 0

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _userPosition = position);
    } on LocationServiceDisabledException {
      setState(() => _locationErrorKey = 'location_disabled');
    } on LocationPermissionDeniedException {
      setState(() => _locationErrorKey = 'location_denied');
    } on LocationPermissionDeniedForeverException {
      setState(() => _locationErrorKey = 'location_denied_forever');
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _dataLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('tile_taxi')),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: _userPosition == null
                ? Container(
                    color: AppColors.divider,
                    child: Center(
                      child: _locationErrorKey != null
                          ? Padding(padding: const EdgeInsets.all(16), child: Text(context.l10n.t(_locationErrorKey!), textAlign: TextAlign.center))
                          : const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : AppMapWidget(initialPosition: _userPosition!, showCenterPin: true),
          ),
          Expanded(child: _dataLoaded ? _buildContent(context) : const TaxiScreenSkeleton()),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final classes = TaxiPricingCalculator.classesFor(cityType);
    final price = TaxiPricingCalculator.calculatePrice(cityType: cityType, carClass: selectedClass, distanceKm: distanceKm);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AddressInputField(
                icon: Icons.trip_origin,
                hint: context.l10n.t('taxi_from'),
                value: fromAddress,
                onChanged: (v) => setState(() => fromAddress = v),
              ),
              const SizedBox(height: 10),
              AddressInputField(
                icon: Icons.location_on,
                hint: context.l10n.t('taxi_to'),
                value: toAddress,
                onChanged: (v) => setState(() => toAddress = v),
              ),
              const SizedBox(height: 24),
              Text(context.l10n.t('taxi_car_class_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 12),
              CarClassSelector(classes: classes, selectedClass: selectedClass, distanceKm: distanceKm, onSelect: (c) => setState(() => selectedClass = c)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              onPressed: distanceKm > 0 ? () {} : null,
              child: Text(
                distanceKm > 0 ? '${context.l10n.t('taxi_order_button')} $price тг' : context.l10n.t('taxi_fill_addresses'),
                style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}