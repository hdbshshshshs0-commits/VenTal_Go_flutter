import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/restaurant_order_status.dart';

class OrderCard extends StatelessWidget {
  final RestaurantOrderModel order;
  final VoidCallback onAdvance;

  const OrderCard({super.key, required this.order, required this.onAdvance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(order.clientName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          Text('${order.total} тг', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
          if (order.status.actionLabelKey.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: onAdvance,
                child: Text(context.l10n.t(order.status.actionLabelKey), style: const TextStyle(fontSize: 12.5, color: AppColors.textLight, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
