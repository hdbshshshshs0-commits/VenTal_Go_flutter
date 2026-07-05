import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/widgets/skeleton_box.dart';
import '../../data/models/restaurant_model.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_menu_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  bool _loaded = false;
  final List<RestaurantModel> _restaurants = const [
    RestaurantModel(id: '1', name: 'Burger House', imagePath: 'assets/images/banners/promo_1.png', rating: 4.8, deliveryTimeMin: 25, minOrderAmount: 3500, freeDelivery: true),
    RestaurantModel(id: '2', name: 'Sushi Time', imagePath: 'assets/images/banners/promo_2.png', rating: 4.5, deliveryTimeMin: 35, minOrderAmount: 5000, freeDelivery: false),
    RestaurantModel(id: '3', name: 'Pizza Express', imagePath: 'assets/images/banners/collab_aitym.png', rating: 4.7, deliveryTimeMin: 30, minOrderAmount: 4000, freeDelivery: true),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(context.l10n.t('food_restaurants_title')),
      ),
      body: !_loaded
          ? ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 4,
              itemBuilder: (_, __) => const Padding(padding: EdgeInsets.only(bottom: 16), child: SkeletonBox(width: double.infinity, height: 200)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _restaurants.length,
              itemBuilder: (context, index) => RestaurantCard(
                restaurant: _restaurants[index],
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RestaurantMenuScreen(restaurant: _restaurants[index]))),
              ),
            ),
    );
  }
}
