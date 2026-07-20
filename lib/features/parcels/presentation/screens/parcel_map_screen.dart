import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import 'package:vental_go/core/routing/osrm_service.dart';
import '../../data/models/parcel_address_details_model.dart';
import '../../data/models/parcel_pricing_model.dart';
import '../../data/pricing/parcel_pricing_calculator.dart';
import '../widgets/order_details_sheet.dart';

class ParcelMapScreen extends StatefulWidget {
  final ParcelAddressDetails fromAddress;
  final ParcelAddressDetails toAddress;
  final ParcelOrderDetails orderDetails;
  final ParcelTransport transport;
  final String weightId;
  final double distanceKm;

  const ParcelMapScreen({
    super.key,
    required this.fromAddress,
    required this.toAddress,
    required this.orderDetails,
    required this.transport,
    required this.weightId,
    required this.distanceKm,
  });

  @override
  State<ParcelMapScreen> createState() => _ParcelMapScreenState();
}

class _ParcelMapScreenState extends State<ParcelMapScreen> {
  List<LatLng>? _routePoints;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final result = await OsrmService.getRoute(widget.fromAddress.coordinates, widget.toAddress.coordinates);
    if (!mounted) return;
    setState(() => _routePoints = result?.geometry);
  }

  void _placeOrder() {
    // TODO: отправка заказа на бэкенд, переход на экран поиска курьера
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = ParcelPricingCalculator.calculate(transport: widget.transport, weightId: widget.weightId, distanceKm: widget.distanceKm);
    final row = ParcelPricingCalculator.rowById(widget.transport, widget.weightId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMapWidget(
              initialPosition: widget.fromAddress.coordinates,
              showCenterPin: false,
              showLocateButton: false,
              routePoints: _routePoints,
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
            bottom: 0,
            child: Container(
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
                  _row(context, Icons.savings_outlined, context.l10n.t('parcel_cost_title'), '${breakdown.clientPrice.round()} тг'),
                  const SizedBox(height: 10),
                  _row(context, Icons.local_shipping_outlined, context.l10n.t('parcel_delivery_type_title'), context.l10n.t(widget.transport.stringKey)),
                  const SizedBox(height: 10),
                  _row(context, Icons.inventory_2_outlined, context.l10n.t('parcel_weight_title'), context.l10n.t(row.weightLabelKey)),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: _placeOrder,
                      child: Text(
                        '${context.l10n.t('parcel_order_button')} ${breakdown.clientPrice.round()} тг',
                        style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
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

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withValues(alpha: 0.08), child: Icon(icon, size: 18, color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark)),
      ],
    );
  }
}