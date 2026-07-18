import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/car_class_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/pricing/taxi_pricing_calculator.dart';
import 'address_autocomplete_field.dart';
import 'car_class_card.dart';
import 'payment_method_selector.dart';
import 'price_breakdown_sheet.dart';
import 'taxi_screen_skeleton.dart';

class CarClassBottomSheet extends StatelessWidget {
  final bool dataLoaded;
  final CityType cityType;
  final LatLng? biasPosition;
  final String? cityName;
  final String fromAddress;
  final String toAddress;
  final void Function(String address, LatLng coordinates) onFromSelected;
  final void Function(String address, LatLng coordinates) onToSelected;
  final VoidCallback onSwapAddresses;
  final CarClass selectedClass;
  final ValueChanged<CarClass> onClassSelected;
  final PaymentMethod selectedPayment;
  final ValueChanged<PaymentMethod> onPaymentChanged;
  final double distanceKm;
  final double? durationMin;
  final VoidCallback onOrder;

  const CarClassBottomSheet({
    super.key,
    required this.dataLoaded,
    required this.cityType,
    required this.biasPosition,
    required this.fromAddress,
    required this.toAddress,
    required this.onFromSelected,
    required this.onToSelected,
    required this.onSwapAddresses,
    required this.selectedClass,
    required this.onClassSelected,
    required this.selectedPayment,
    required this.onPaymentChanged,
    required this.distanceKm,
    required this.onOrder,
    this.cityName,
    this.durationMin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.58,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, -6))],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: !dataLoaded
            ? const TaxiScreenSkeleton(key: ValueKey('skeleton'))
            : Column(
                key: const ValueKey('content'),
                children: [
                  _buildDragHandle(),
                  _buildAddressRow(context),
                  const Divider(height: 1),
                  Expanded(child: _buildClassList(context)),
                  const Divider(height: 1),
                  _buildOrderRow(context),
                ],
              ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
    );
  }

  Widget _buildAddressRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                AddressAutocompleteField(
                  icon: Icons.trip_origin,
                  hintKey: 'taxi_from',
                  biasPosition: biasPosition,
                  cityName: cityName,
                  initialValue: fromAddress,
                  onAddressSelected: onFromSelected,
                ),
                const SizedBox(height: 8),
                AddressAutocompleteField(
                  icon: Icons.location_on,
                  hintKey: 'taxi_to',
                  biasPosition: biasPosition,
                  cityName: cityName,
                  initialValue: toAddress,
                  onAddressSelected: onToSelected,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              _smallIconButton(icon: Icons.swap_vert_rounded, onTap: onSwapAddresses),
              const SizedBox(height: 8),
              _smallIconButton(
                icon: Icons.add_rounded,
                onTap: () {}, // TODO: добавление промежуточной точки маршрута
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallIconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildClassList(BuildContext context) {
    final classes = TaxiPricingCalculator.classesFor(cityType);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final pricing = classes[index];
        return CarClassCard(
          pricing: pricing,
          distanceKm: distanceKm,
          durationMin: durationMin,
          isSelected: pricing.carClass == selectedClass,
          onTap: () => onClassSelected(pricing.carClass),
        );
      },
    );
  }

  Widget _buildOrderRow(BuildContext context) {
    final price = TaxiPricingCalculator.calculatePrice(
      cityType: cityType,
      carClass: selectedClass,
      distanceKm: distanceKm,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          PaymentMethodSelector(selected: selectedPayment, onChanged: onPaymentChanged),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: distanceKm > 0
                ? () => PriceBreakdownSheet.show(
                      context,
                      cityType: cityType,
                      carClass: selectedClass,
                      distanceKm: distanceKm,
                    )
                : null,
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.info_outline_rounded, size: 20, color: AppColors.textHint),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: distanceKm > 0 ? onOrder : null,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    distanceKm > 0
                        ? '${context.l10n.t('taxi_order_button')} $price ${context.l10n.t('currency_tg')}'
                        : context.l10n.t('taxi_order_button'),
                    key: ValueKey(price),
                    style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 14),
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