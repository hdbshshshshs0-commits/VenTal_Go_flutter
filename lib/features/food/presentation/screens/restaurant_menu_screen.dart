import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/models/menu_item_model.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/food_cart_bottom_bar.dart';
import 'food_cart_screen.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  const RestaurantMenuScreen({super.key, required this.restaurant});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final Map<String, int> _cartMap = {};

  final List<MenuItemModel> _items = const [
    MenuItemModel(id: '1', categoryId: 'burgers', name: 'Классический бургер', imagePath: 'assets/images/services/food.png', price: 2200),
    MenuItemModel(id: '2', categoryId: 'burgers', name: 'Чизбургер', imagePath: 'assets/images/services/food.png', price: 2600),
    MenuItemModel(id: '3', categoryId: 'drinks', name: 'Кола 0.5л', imagePath: 'assets/images/services/food.png', price: 500),
    MenuItemModel(id: '4', categoryId: 'sides', name: 'Картофель фри', imagePath: 'assets/images/services/food.png', price: 900),
  ];

  int get _cartCount => _cartMap.values.fold(0, (a, b) => a + b);
  int get _cartTotal => _cartMap.entries.fold(0, (sum, entry) {
        final item = _items.firstWhere((i) => i.id == entry.key, orElse: () => _items.first);
        return sum + item.price * entry.value;
      });

  void _addToCart(MenuItemModel item) {
    setState(() => _cartMap[item.id] = (_cartMap[item.id] ?? 0) + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(widget.restaurant.name),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: _items.length,
            itemBuilder: (context, index) => MenuItemCard(item: _items[index], onAddToCart: () => _addToCart(_items[index])),
          ),
          FoodCartBottomBar(
            itemCount: _cartCount,
            total: _cartTotal,
            onCheckout: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FoodCartScreen(cart: Map.from(_cartMap), menuItems: _items))),
          ),
        ],
      ),
    );
  }
}
