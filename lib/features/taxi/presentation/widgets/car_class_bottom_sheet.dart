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
import 'taxi_screen_skeleton.dart';

class CarClassBottomSheet extends StatelessWidget {
  final bool dataLoaded;
  final CityType cityType;
  final LatLng? biasPosition;
  final void Function(String address, LatLng coordinates) onFromSelected;
  final void Function(String address, LatLng coordinates) onToSelected;
  final CarClass selectedClass;
  final ValueChanged<CarClass> onClassSelected;
  final PaymentMethod selectedPayment;
  final ValueChanged<PaymentMethod> onPaymentChanged;
  final double distanceKm;
  final VoidCallback onOrder;

  const CarClassBottomSheet({
    super.key,
    required this.dataLoaded,
    required this.cityType,
    required this.biasPosition,
    required this.onFromSelected,
    required this.onToSelected,
    required this.selectedClass,
    required this.onClassSelected,
    required this.selectedPayment,
    required this.onPaymentChanged,
    required this.distanceKm,
    required this.onOrder,
  });

  static const double _collapsedSize = 0.20;
  static const double _expandedSize = 0.62;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _expandedSize,
      minChildSize: _collapsedSize,
      maxChildSize: _expandedSize,
      snap: true,
      snapSizes: const [_collapsedSize, _expandedSize],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, -6))],
          ),
          child: !dataLoaded
              ? const TaxiScreenSkeleton()
              : CustomScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildDragHandle()),
                    SliverToBoxAdapter(child: _buildAlwaysVisibleRow(context)),
                    SliverToBoxAdapter(child: _buildExpandedContent(context)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  /// Видно всегда: выбранный класс, иконка оплаты, кнопка заказа.
  Widget _buildAlwaysVisibleRow(BuildContext context) {
    final price = TaxiPricingCalculator.calculatePrice(
      cityType: cityType,
      carClass: selectedClass,
      distanceKm: distanceKm,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.t(selectedClass.stringKey),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PaymentMethodSelector(selected: selectedPayment, onChanged: onPaymentChanged),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withAlpha(100),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: distanceKm > 0 ? onOrder : null,
              child: Text(
                distanceKm > 0
                    ? '${context.l10n.t('taxi_order_button')} $price ${context.l10n.t('currency_tg')}'
                    : context.l10n.t('taxi_order_button'),
                style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Видно только при разворачивании: поля адресов + полный список классов.
  Widget _buildExpandedContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          AddressAutocompleteField(
            icon: Icons.trip_origin,
            hintKey: 'taxi_from',
            biasPosition: biasPosition,
            onAddressSelected: onFromSelected,
          ),
          const SizedBox(height: 8),
          AddressAutocompleteField(
            icon: Icons.location_on,
            hintKey: 'taxi_to',
            biasPosition: biasPosition,
            onAddressSelected: onToSelected,
          ),
          const SizedBox(height: 16),
          ...TaxiPricingCalculator.classesFor(cityType).map((pricing) {
            return CarClassCard(
              pricing: pricing,
              distanceKm: distanceKm,
              isSelected: pricing.carClass == selectedClass,
              onTap: () => onClassSelected(pricing.carClass),
            );
          }),
        ],
      ),
    );
  }
}