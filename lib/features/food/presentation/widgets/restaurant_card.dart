import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/restaurant_model.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const RestaurantCard({super.key, required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: Image.asset(restaurant.imagePath, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                      const SizedBox(width: 2),
                      Text(restaurant.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text('${restaurant.deliveryTimeMin} ${context.l10n.t('food_delivery_time')}', style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                      const SizedBox(width: 12),
                      if (restaurant.freeDelivery)
                        Text(context.l10n.t('food_free_delivery'), style: const TextStyle(fontSize: 12.5, color: AppColors.success, fontWeight: FontWeight.w600))
                      else
                        Text('${context.l10n.t('food_min_order')}: ${restaurant.minOrderAmount} тг', style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
