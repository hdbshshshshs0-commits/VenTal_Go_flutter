import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/routing/osrm_service.dart';
import 'parcel_success_screen.dart';

class ParcelRouteScreen extends StatefulWidget {
  final LatLng fromPosition;
  final LatLng toPosition;
  final int price;

  const ParcelRouteScreen({super.key, required this.fromPosition, required this.toPosition, required this.price});

  @override
  State<ParcelRouteScreen> createState() => _ParcelRouteScreenState();
}

class _ParcelRouteScreenState extends State<ParcelRouteScreen> {
  List<LatLng>? _routePoints;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final result = await OsrmService.getRoute(widget.fromPosition, widget.toPosition);
    if (!mounted) return;
    setState(() {
      _routePoints = result?.geometry ?? [widget.fromPosition, widget.toPosition];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMapWidget(
              initialPosition: widget.fromPosition,
              routePoints: _routePoints,
              onMapReady: (_) {},
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    // TODO: отправить заказ посылки на бэкенд
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParcelSuccessScreen()));
                  },
                  child: Text(
                    '${context.l10n.t('parcel_confirm_button')} ${widget.price} ${context.l10n.t('currency_tg')}',
                    style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
