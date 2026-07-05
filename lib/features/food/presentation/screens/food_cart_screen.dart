import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/pricing/food_pricing_calculator.dart';
import 'food_checkout_screen.dart';

class FoodCartScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<MenuItemModel> menuItems;

  const FoodCartScreen({super.key, required this.cart, required this.menuItems});

  @override
  State<FoodCartScreen> createState() => _FoodCartScreenState();
}

class _FoodCartScreenState extends State<FoodCartScreen> {
  late final Map<String, int> _cart = Map.from(widget.cart);

  int get _subtotal => _cart.entries.fold(0, (sum, entry) {
        final item = widget.menuItems.firstWhere((i) => i.id == entry.key, orElse: () => widget.menuItems.first);
        return sum + item.price * entry.value;
      });

  @override
  Widget build(BuildContext context) {
    final subtotal = _subtotal;
    final serviceFee = FoodPricingCalculator.serviceFeeAmount(subtotal);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('food_cart_title')),
      ),
      body: _cart.isEmpty
          ? Center(child: Text(context.l10n.t('food_cart_empty'), style: const TextStyle(color: Colors.black45, fontSize: 16)))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: _cart.entries.map((entry) {
                      final item = widget.menuItems.firstWhere((i) => i.id == entry.key, orElse: () => widget.menuItems.first);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text('${item.price} тг', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ])),
                            Row(
                              children: [
                                IconButton(onPressed: () { setState(() { if (_cart[item.id]! > 1) { _cart[item.id] = _cart[item.id]! - 1; } else { _cart.remove(item.id); } }); }, icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary)),
                                Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                IconButton(onPressed: () { setState(() => _cart[item.id] = (_cart[item.id] ?? 0) + 1); }, icon: const Icon(Icons.add_circle_outline, color: AppColors.primary)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(context.l10n.t('food_service_fee')),
                          Text('$serviceFee тг', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 6),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(context.l10n.t('food_total'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text('${subtotal + serviceFee} тг', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)),
                        ]),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FoodCheckoutScreen())),
                            child: Text(context.l10n.t('food_go_to_checkout'), style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
