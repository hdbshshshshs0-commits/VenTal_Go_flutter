import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/restaurant_order_status.dart';
import '../widgets/kanban_column.dart';

class RestaurantOrdersKanbanScreen extends StatefulWidget {
  const RestaurantOrdersKanbanScreen({super.key});

  @override
  State<RestaurantOrdersKanbanScreen> createState() => _RestaurantOrdersKanbanScreenState();
}

class _RestaurantOrdersKanbanScreenState extends State<RestaurantOrdersKanbanScreen> {
  final List<RestaurantOrderModel> _orders = [
    RestaurantOrderModel(id: '1042', clientName: 'Асхат Б.', total: 4200, status: RestaurantOrderStatus.newOrder),
    RestaurantOrderModel(id: '1041', clientName: 'Динара К.', total: 6800, status: RestaurantOrderStatus.cooking),
    RestaurantOrderModel(id: '1040', clientName: 'Ержан С.', total: 3100, status: RestaurantOrderStatus.ready),
  ];

  void _advance(RestaurantOrderModel order) {
    final next = order.status.next;
    if (next == null) return;
    setState(() => order.status = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('restaurant_orders_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: RestaurantOrderStatus.values.map((status) {
              final ordersInColumn = _orders.where((o) => o.status == status).toList();
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: KanbanColumn(status: status, orders: ordersInColumn, onAdvance: _advance),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
