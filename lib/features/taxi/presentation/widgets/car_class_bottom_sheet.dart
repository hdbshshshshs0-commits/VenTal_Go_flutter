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
    required this.fromAddress,
    required this.toAddress,
    required this.onFromSelected,
    required this.onToSelected,
    required this.selectedClass,
    required this.onClassSelected,
    required this.selectedPayment,
    required this.onPaymentChanged,
    required this.distanceKm,
    required this.onOrder,
    this.cityName,
  });

  static const double _collapsedSize = 0.26;
  static const double _expandedSize = 0.66;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _collapsedSize,
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
                    SliverToBoxAdapter(child: _buildClassStrip(context)),
                    SliverToBoxAdapter(child: _buildOrderRow(context)),
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  /// Горизонтальная лента классов — видна сразу, без разворачивания
  /// (структура как у Яндекса), карточки компактные, в стиле Uber.
  Widget _buildClassStrip(BuildContext context) {
    final classes = TaxiPricingCalculator.classesFor(cityType);

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: classes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final pricing = classes[index];
          final isSelected = pricing.carClass == selectedClass;
          final price = (pricing.minPrice + pricing.kmRate * distanceKm).round();

          return GestureDetector(
            onTap: () => onClassSelected(pricing.carClass),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 84,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(pricing.photoPath, height: 28, fit: BoxFit.contain),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.t(pricing.carClass.stringKey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  Text(
                    '$price тг',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Оплата + безымянная кнопка разбивки цены + кнопка заказа.
  Widget _buildOrderRow(BuildContext context) {
    final price = TaxiPricingCalculator.calculatePrice(
      cityType: cityType,
      carClass: selectedClass,
      distanceKm: distanceKm,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
          const Spacer(),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onPressed: distanceKm > 0 ? onOrder : null,
              child: Text(
                distanceKm > 0
                    ? '${context.l10n.t('taxi_order_button')} $price ${context.l10n.t('currency_tg')}'
                    : context.l10n.t('taxi_order_button'),
                style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

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