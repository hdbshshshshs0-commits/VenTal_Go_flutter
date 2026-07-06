import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/service_tile_model.dart';
import '../widgets/address_pill.dart';
import '../widgets/main_services_row.dart';
import '../widgets/related_services_row.dart';
import '../widgets/promo_carousel.dart';
import '../widgets/floating_search_bar.dart';
import '../widgets/floating_tab_bar.dart';
import 'aitym_recommendations_screen.dart';
import 'package:vental_go/features/taxi/presentation/screens/taxi_order_screen.dart';
import 'package:vental_go/features/food/presentation/screens/restaurant_list_screen.dart';
import 'package:vental_go/features/parcels/presentation/screens/parcel_order_screen.dart';
import 'package:vental_go/features/profile/presentation/screens/profile_screen.dart';

class MainHubScreen extends StatefulWidget {
  const MainHubScreen({super.key});

  @override
  State<MainHubScreen> createState() => _MainHubScreenState();
}

class _MainHubScreenState extends State<MainHubScreen> {
  int _currentTabIndex = 0;

  static const _mainTiles = [
    ServiceTileModel(id: 'food', labelKey: 'tile_food', iconPath: 'assets/images/services/food.png', sortOrder: 1),
    ServiceTileModel(id: 'taxi', labelKey: 'tile_taxi', iconPath: 'assets/images/services/taxi.png', sortOrder: 2),
    ServiceTileModel(id: 'parcels', labelKey: 'tile_parcels', iconPath: 'assets/images/services/parcels.png', sortOrder: 3),
  ];

  static const _relatedTiles = [
    ServiceTileModel(id: 'shops', labelKey: 'chip_shops', iconPath: 'assets/images/icons/shops.png'),
    ServiceTileModel(id: 'veggies', labelKey: 'chip_veggies', iconPath: 'assets/images/icons/veggies.png'),
    ServiceTileModel(id: 'supplements', labelKey: 'chip_supplements', iconPath: 'assets/images/icons/supplements.png'),
    ServiceTileModel(id: 'pharmacy', labelKey: 'chip_pharmacy', iconPath: 'assets/images/icons/pharmacy.png'),
  ];

  void _handleMainTileTap(ServiceTileModel tile) {
    switch (tile.id) {
      case 'taxi':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaxiOrderScreen()));
        break;
      case 'food':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RestaurantListScreen()));
        break;
      case 'parcels':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParcelOrderScreen()));
        break;
    }
  }

  Widget _hubContent() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          AddressPill(address: context.l10n.t('hub_default_address')),
          const SizedBox(height: 20),
          MainServicesRow(tiles: _mainTiles, onTap: _handleMainTileTap),
          const SizedBox(height: 20),
          RelatedServicesRow(tiles: _relatedTiles, onTap: (_) {}),
          const SizedBox(height: 24),
          PromoCarousel(
            items: [
              PromoCarouselItem(
                imagePath: 'assets/images/banners/collab_aitym.png',
                titleKey: 'banner_collab',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AitymRecommendationsScreen()),
                ),
              ),
              const PromoCarouselItem(imagePath: 'assets/images/banners/promo_1.png'),
              const PromoCarouselItem(imagePath: 'assets/images/banners/promo_2.png'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTabIndex,
            children: [
              _hubContent(),
              const ProfileScreen(),
            ],
          ),
          if (_currentTabIndex == 0) const FloatingSearchBar(),
          FloatingTabBar(
            currentIndex: _currentTabIndex,
            onTap: (i) => setState(() => _currentTabIndex = i),
          ),
        ],
      ),
    );
  }
}
