import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/restaurant_order_status.dart';
import 'order_card.dart';

class KanbanColumn extends StatelessWidget {
  final RestaurantOrderStatus status;
  final List<RestaurantOrderModel> orders;
  final void Function(RestaurantOrderModel order) onAdvance;

  const KanbanColumn({super.key, required this.status, required this.orders, required this.onAdvance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.divider.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(context.l10n.t(status.titleKey), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: Text('${orders.length}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) => OrderCard(order: orders[index], onAdvance: () => onAdvance(orders[index])),
            ),
          ),
        ],
      ),
    );
  }
}
