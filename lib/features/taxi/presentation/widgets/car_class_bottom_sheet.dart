import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/car_class_model.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/pricing/taxi_pricing_calculator.dart';
import 'address_input_field.dart';
import 'car_class_card.dart';
import 'payment_method_selector.dart';
import 'taxi_screen_skeleton.dart';

class CarClassBottomSheet extends StatelessWidget {
  final bool dataLoaded;
  final CityType cityType;
  final String fromAddress;
  final String toAddress;
  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;
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
    required this.fromAddress,
    required this.toAddress,
    required this.onFromChanged,
    required this.onToChanged,
    required this.selectedClass,
    required this.onClassSelected,
    required this.selectedPayment,
    required this.onPaymentChanged,
    required this.distanceKm,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, -6))],
      ),
      child: SafeArea(
        top: false,
        child: !dataLoaded
            ? const TaxiScreenSkeleton()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  AddressInputField(
                    icon: Icons.trip_origin,
                    hint: context.l10n.t('taxi_from'),
                    value: fromAddress,
                    onChanged: onFromChanged,
                  ),
                  const SizedBox(height: 8),
                  AddressInputField(
                    icon: Icons.location_on,
                    hint: context.l10n.t('taxi_to'),
                    value: toAddress,
                    onChanged: onToChanged,
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: SingleChildScrollView(
                      child: Column(
                        children: TaxiPricingCalculator.classesFor(cityType).map((pricing) {
                          return CarClassCard(
                            pricing: pricing,
                            distanceKm: distanceKm,
                            isSelected: pricing.carClass == selectedClass,
                            onTap: () => onClassSelected(pricing.carClass),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      PaymentMethodSelector(selected: selectedPayment, onChanged: onPaymentChanged),
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: distanceKm > 0 ? onOrder : null,
                            child: Text(
                              distanceKm > 0
                                  ? '${context.l10n.t('taxi_order_button')} ${TaxiPricingCalculator.calculatePrice(cityType: cityType, carClass: selectedClass, distanceKm: distanceKm)} тг'
                                  : context.l10n.t('taxi_fill_addresses'),
                              style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
