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
    ServiceCategory(id: 'parcels', icon: Icons.inventory_2_rounded, labelKey: 'tile_parcels', isAvailable: true),
    ServiceCategory(id: 'shops', icon: Icons.shopping_basket_rounded, labelKey: 'chip_shops'),
    ServiceCategory(id: 'veggies', icon: Icons.eco_rounded, labelKey: 'chip_veggies'),
    ServiceCategory(id: 'supplements', icon: Icons.medication_outlined, labelKey: 'chip_supplements'),
    ServiceCategory(id: 'pharmacy', icon: Icons.medical_services_outlined, labelKey: 'chip_pharmacy'),
  ];

  void _handleTap(BuildContext context, ServiceCategory category) {
    switch (category.id) {
      case 'taxi':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaxiOrderScreen()));
        break;
      case 'food':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RestaurantListScreen()));
        break;
      case 'parcels':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParcelScreen()));
        break;
      default:
        // TODO: shops/veggies/supplements/pharmacy ещё не реализованы
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                            color: category.isAvailable ? AppColors.primary.withValues(alpha: 0.12) : AppColors.divider.withValues(alpha: 0.4),
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
            ],
          ),
        ),
      ),
    );
  }
}