import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/taxi/presentation/screens/taxi_order_screen.dart';
import 'package:vental_go/features/food/presentation/screens/restaurant_list_screen.dart';
import 'package:vental_go/features/parcels/presentation/screens/parcel_screen.dart';
import '../../data/models/service_category_model.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const _categories = [
    ServiceCategory(id: 'taxi', icon: Icons.directions_car_rounded, labelKey: 'tile_taxi', isAvailable: true),
    ServiceCategory(id: 'food', icon: Icons.fastfood_rounded, labelKey: 'tile_food', isAvailable: true),
    ServiceCategory(id: 'delivery', icon: Icons.electric_moped_rounded, labelKey: 'service_delivery'),
    ServiceCategory(id: 'flowers', icon: Icons.local_florist_rounded, labelKey: 'service_flowers'),
    ServiceCategory(id: 'shops', icon: Icons.shopping_basket_rounded, labelKey: 'service_shops'),
    ServiceCategory(id: 'cargo', icon: Icons.local_shipping_rounded, labelKey: 'service_cargo'),
    ServiceCategory(id: 'carwash', icon: Icons.local_car_wash_rounded, labelKey: 'service_carwash'),
    ServiceCategory(id: 'pharmacy', icon: Icons.medical_services_outlined, labelKey: 'chip_pharmacy'),
    ServiceCategory(id: 'courier', icon: Icons.directions_run_rounded, labelKey: 'service_courier'),
    ServiceCategory(id: 'gifts', icon: Icons.card_giftcard_rounded, labelKey: 'service_gifts'),
    ServiceCategory(id: 'pets', icon: Icons.pets_rounded, labelKey: 'service_pets'),
    ServiceCategory(id: 'repair', icon: Icons.build_rounded, labelKey: 'service_repair'),
    ServiceCategory(id: 'tickets', icon: Icons.confirmation_number_rounded, labelKey: 'service_tickets'),
    ServiceCategory(id: 'hotels', icon: Icons.apartment_rounded, labelKey: 'service_hotels'),
    ServiceCategory(id: 'travel', icon: Icons.flight_rounded, labelKey: 'service_travel'),
    ServiceCategory(id: 'finance', icon: Icons.account_balance_wallet_rounded, labelKey: 'service_finance'),
    ServiceCategory(id: 'insurance', icon: Icons.description_outlined, labelKey: 'service_insurance'),
    ServiceCategory(id: 'more', icon: Icons.more_horiz_rounded, labelKey: 'service_more'),
  ];

  void _handleTap(BuildContext context, ServiceCategory category) {
    switch (category.id) {
      case 'taxi':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaxiOrderScreen()));
        break;
      case 'food':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RestaurantListScreen()));
        break;
      case 'delivery':
      case 'cargo':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParcelScreen()));
        break;
      default:
        // TODO: остальные сервисы ещё не реализованы
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.t('services_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.textDark)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: _categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return GestureDetector(
                      onTap: () => _handleTap(context, category),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: category.isAvailable ? AppColors.primary.withValues(alpha: 0.1) : AppColors.divider.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(category.icon, size: 24, color: category.isAvailable ? AppColors.primary : AppColors.textHint),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.t(category.labelKey),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}