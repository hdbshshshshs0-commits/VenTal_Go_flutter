import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/location/default_location.dart';
import 'package:vental_go/core/geocoding/geocoding_service.dart';
import '../../data/models/parcel_model.dart';
import '../../data/models/parcel_contact_model.dart';
import '../../data/pricing/parcel_pricing_calculator.dart';
import '../widgets/parcel_category_selector.dart';
import '../widgets/parcel_contact_form.dart';
import '../widgets/delivery_scope_selector.dart';
import 'parcel_route_screen.dart';

class ParcelOrderScreen extends StatefulWidget {
  const ParcelOrderScreen({super.key});

  @override
  State<ParcelOrderScreen> createState() => _ParcelOrderScreenState();
}

class _ParcelOrderScreenState extends State<ParcelOrderScreen> {
  int _step = 0;

  ParcelCategory _category = ParcelCategory.upTo5kg;
  DeliveryScope _scope = DeliveryScope.doorToDoor;

  ParcelContactModel? _sender;
  ParcelContactModel? _receiver;

  bool _navigating = false;

  bool get _senderReady => _sender?.isComplete ?? false;
  bool get _receiverReady => _receiver?.isComplete ?? false;

  Future<void> _goToRoute() async {
    if (_navigating) return;
    setState(() => _navigating = true);

    LatLng? fromPos;
    LatLng? toPos;

    final senderAddr = _sender?.address ?? '';
    final receiverAddr = _receiver?.address ?? '';

    if (senderAddr.isNotEmpty) {
      final results = await GeocodingService.search(senderAddr);
      if (results.isNotEmpty) fromPos = results.first.position;
    }
    if (receiverAddr.isNotEmpty) {
      final results = await GeocodingService.search(receiverAddr);
      if (results.isNotEmpty) toPos = results.first.position;
    }

    fromPos ??= DefaultLocation.center;
    toPos ??= DefaultLocation.center;

    final deliveryType = _scope == DeliveryScope.doorToDoor
        ? ParcelDeliveryType.doorToDoor
        : ParcelDeliveryType.toAddress;
    final price = ParcelPricingCalculator.calculate(category: _category, deliveryType: deliveryType);

    if (!mounted) return;
    setState(() => _navigating = false);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ParcelRouteScreen(
        fromPosition: fromPos!,
        toPosition: toPos!,
        price: price,
      ),
    ));
  }

  Widget _buildStep0() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        ParcelCategorySelector(
          selected: _category,
          onChanged: (v) => setState(() => _category = v),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => setState(() => _step = 1),
            child: Text(context.l10n.t('back') == 'Назад' ? 'Далее' : 'Next',
                style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        DeliveryScopeSelector(
          selected: _scope,
          onSelect: (s) => setState(() => _scope = s),
        ),
        const SizedBox(height: 20),
        ParcelContactForm(
          titleKey: 'parcel_sender_title',
          showDetailFields: _scope == DeliveryScope.doorToDoor,
          onChanged: (m) => setState(() => _sender = m),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withAlpha(100),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _senderReady ? () => setState(() => _step = 2) : null,
            child: Text(context.l10n.t('back') == 'Назад' ? 'Далее' : 'Next',
                style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        ParcelContactForm(
          titleKey: 'parcel_receiver_title',
          showDetailFields: _scope == DeliveryScope.doorToDoor,
          onChanged: (m) => setState(() => _receiver = m),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withAlpha(100),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _receiverReady && !_navigating ? _goToRoute : null,
            child: _navigating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(context.l10n.t('parcel_order_button'),
                    style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('parcel_title')),
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _step--),
              )
            : null,
      ),
      body: IndexedStack(
        index: _step,
        children: [
          _buildStep0(),
          _buildStep1(),
          _buildStep2(),
        ],
      ),
    );
  }
}
