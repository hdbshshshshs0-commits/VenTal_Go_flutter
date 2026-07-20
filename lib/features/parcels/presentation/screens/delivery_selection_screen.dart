import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/routing/osrm_service.dart';
import 'package:vental_go/core/geocoding/geocoding_service.dart';
import '../../data/models/parcel_address_details_model.dart';
import '../../data/models/parcel_pricing_model.dart';
import '../../data/pricing/parcel_pricing_calculator.dart';
import '../widgets/order_details_sheet.dart';
import 'parcel_map_screen.dart';

class DeliverySelectionScreen extends StatefulWidget {
  final ParcelAddressDetails fromAddress;
  final ParcelAddressDetails toAddress;
  final ParcelOrderDetails orderDetails;

  const DeliverySelectionScreen({
    super.key,
    required this.fromAddress,
    required this.toAddress,
    required this.orderDetails,
  });

  @override
  State<DeliverySelectionScreen> createState() => _DeliverySelectionScreenState();
}

class _DeliverySelectionScreenState extends State<DeliverySelectionScreen> {
  ParcelTransport _transport = ParcelTransport.walking;
  String _weightId = 'light';
  double _distanceKm = 0;
  bool _loadingDistance = true;

  @override
  void initState() {
    super.initState();
    _loadDistance();
  }

  Future<void> _loadDistance() async {
    final result = await OsrmService.getRoute(widget.fromAddress.coordinates, widget.toAddress.coordinates);
    if (!mounted) return;
    setState(() {
      _distanceKm = result?.distanceKm ?? GeocodingService.calculateDistanceKm(widget.fromAddress.coordinates, widget.toAddress.coordinates);
      _loadingDistance = false;
    });
  }

  void _selectTransport(ParcelTransport transport) {
    final rows = ParcelPricingCalculator.rowsFor(transport);
    setState(() {
      _transport = transport;
      _weightId = rows.first.id;
    });
  }

  void _proceed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ParcelMapScreen(
          fromAddress: widget.fromAddress,
          toAddress: widget.toAddress,
          orderDetails: widget.orderDetails,
          transport: _transport,
          weightId: _weightId,
          distanceKm: _distanceKm,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = ParcelPricingCalculator.rowsFor(_transport);
    final breakdown = _loadingDistance
        ? null
        : ParcelPricingCalculator.calculate(transport: _transport, weightId: _weightId, distanceKm: _distanceKm);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('parcel_delivery_selection_title')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _addressSummaryCard(context),
                  const SizedBox(height: 20),
                  Text(context.l10n.t('parcel_how_to_deliver'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Row(children: ParcelTransport.values.map((t) => Expanded(child: _transportTile(context, t))).toList()),
                  const SizedBox(height: 20),
                  Text(context.l10n.t('parcel_weight_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 10, runSpacing: 10, children: rows.map((row) => _weightChip(context, row)).toList()),
                ],
              ),
            ),
            _bottomBar(context, breakdown),
          ],
        ),
      ),
    );
  }

  Widget _addressSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.t('taxi_from'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textHint)),
              Text(widget.fromAddress.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider(height: 1)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.t('taxi_to'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textHint)),
              Text(widget.toAddress.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transportTile(BuildContext context, ParcelTransport transport) {
    final isSelected = _transport == transport;
    return GestureDetector(
      onTap: () => _selectTransport(transport),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
        ),
        child: Column(
          children: [
            Image.asset(transport.iconAsset, width: 32, height: 32),
            const SizedBox(height: 8),
            Text(context.l10n.t(transport.stringKey), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            Text(context.l10n.t(transport.maxWeightLabelKey), style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }

  Widget _weightChip(BuildContext context, dynamic row) {
    final isSelected = _weightId == row.id;
    return GestureDetector(
      onTap: () => setState(() => _weightId = row.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          context.l10n.t(row.weightLabelKey),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? AppColors.textLight : AppColors.textDark),
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, dynamic breakdown) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(color: AppColors.background, boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, -6))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.t('parcel_estimated_price'), style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
              if (_loadingDistance) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              breakdown != null ? '${breakdown.clientPrice.round()} тг' : '—',
              key: ValueKey(breakdown?.clientPrice),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.textDark),
            ),
          ),
          if (breakdown != null && !breakdown.isFixedPrice)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('${breakdown.distanceKm.toStringAsFixed(1)} км × ${breakdown.perKm.round()} тг', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
            ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: breakdown != null ? _proceed : null,
              child: Text(context.l10n.t('parcel_continue_button'), style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}