import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/history_order_model.dart';
import '../widgets/history_segmented_toggle.dart';
import '../widgets/history_filter_chips.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _tabIndex = 0; // 0 = Активные, 1 = История
  HistoryOrderCategory? _filter;

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
              HistorySegmentedToggle(selectedIndex: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i)),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _tabIndex == 0 ? _buildActiveTab(context) : _buildHistoryTab(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTab(BuildContext context) {
    // TODO: подключить реальные активные заказы с бэкенда (сейчас заглушка UI)
    return ListView(
      key: const ValueKey('active'),
      children: [
        Text(context.l10n.t('history_active_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.textDark)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 24, backgroundColor: AppColors.background, child: Icon(Icons.electric_moped_rounded, color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.t('history_order_in_transit'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(context.l10n.t('history_delivery_eta'), style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _stepDot(done: true),
                  _stepLine(active: true),
                  _stepDot(done: true),
                  _stepLine(active: true),
                  _stepDot(done: false, active: true, icon: Icons.shopping_bag_rounded),
                  _stepLine(active: false),
                  _stepDot(done: false, icon: Icons.home_rounded),
                ],
              ),
              const SizedBox(height: 10),
              Text(context.l10n.t('history_courier_picked_up'), style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepDot({required bool done, bool active = false, IconData? icon}) {
    final color = done || active ? AppColors.primary : AppColors.divider;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(shape: BoxShape.circle, color: done ? AppColors.primary : Colors.white, border: Border.all(color: color, width: 2)),
      child: Icon(
        done ? Icons.check_rounded : icon,
        size: 14,
        color: done ? Colors.white : color,
      ),
    );
  }

  Widget _stepLine({required bool active}) {
    return Expanded(child: Container(height: 2, color: active ? AppColors.primary : AppColors.divider));
  }

  Widget _buildHistoryTab(BuildContext context) {
    final orders = _filter == null ? HistoryMockData.orders : HistoryMockData.orders.where((o) => o.category == _filter).toList();

    return Column(
      key: const ValueKey('history'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HistoryFilterChips(selected: _filter, onChanged: (v) => setState(() => _filter = v)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order.orderNumber, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                        Text(order.date, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textDark)),
                        Text('${order.price} тг', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textDark)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.divider), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () {}, // TODO: показать состав заказа
                            icon: const Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.textDark),
                            label: Text(context.l10n.t('history_composition'), style: const TextStyle(color: AppColors.textDark, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.divider), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () {}, // TODO: повторить заказ
                            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                            label: Text(context.l10n.t('history_repeat_order'), style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}