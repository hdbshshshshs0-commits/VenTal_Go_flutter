import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/service_tile_model.dart';
import '../widgets/address_pill.dart';
import '../widgets/main_service_trapezoid_button.dart';
import '../widgets/services_preview_row.dart';
import '../widgets/notification_bell_button.dart';
import '../widgets/promo_carousel.dart';
import '../widgets/floating_tab_bar.dart';
import 'aitym_recommendations_screen.dart';
import 'package:vental_go/features/taxi/presentation/screens/taxi_order_screen.dart';
import 'package:vental_go/features/food/presentation/screens/restaurant_list_screen.dart';
import 'package:vental_go/features/parcels/presentation/screens/parcel_screen.dart';
import 'package:vental_go/features/services/presentation/screens/services_screen.dart';
import 'package:vental_go/features/history/presentation/screens/history_screen.dart';
import 'package:vental_go/features/profile/presentation/screens/profile_screen.dart';

class MainHubScreen extends StatefulWidget {
  const MainHubScreen({super.key});

  @override
  State<MainHubScreen> createState() => _MainHubScreenState();
}

class _MainHubScreenState extends State<MainHubScreen> {
  int _currentTabIndex = 0;

  // Порядок по твоей формулировке: еда сверху-слева, такси сверху-справа,
  // магазины снизу-слева, посылки снизу-справа.
  static const _mainTiles = [
    ServiceTileModel(id: 'food', labelKey: 'tile_food', iconPath: 'assets/images/services/food.png', sortOrder: 1),
    ServiceTileModel(id: 'taxi', labelKey: 'tile_taxi', iconPath: 'assets/images/cars/economy.png', sortOrder: 2),
    ServiceTileModel(id: 'shops', labelKey: 'chip_shops', iconPath: 'assets/images/icons/shops.png', sortOrder: 3),
    ServiceTileModel(id: 'parcels', labelKey: 'tile_parcels', iconPath: 'assets/images/services/parcels.png', sortOrder: 4),
  ];

  // Маленькая полоска "Сервисы" — порядок как на макете (еда/такси/магазины/посылки).
  static const _servicesPreviewTiles = [
    ServiceTileModel(id: 'food', labelKey: 'tile_food', iconPath: 'assets/images/services/food.png', sortOrder: 1),
    ServiceTileModel(id: 'taxi', labelKey: 'tile_taxi', iconPath: 'assets/images/services/taxi.png', sortOrder: 2),
    ServiceTileModel(id: 'shops', labelKey: 'chip_shops', iconPath: 'assets/images/icons/shops.png', sortOrder: 3),
    ServiceTileModel(id: 'parcels', labelKey: 'tile_parcels', iconPath: 'assets/images/services/parcels.png', sortOrder: 4),
  ];

  void _handleTileTap(ServiceTileModel tile) {
    switch (tile.id) {
      case 'taxi':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaxiOrderScreen()));
        break;
      case 'food':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RestaurantListScreen()));
        break;
      case 'parcels':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParcelScreen()));
        break;
      case 'shops':
        // TODO: экран магазинов ещё не реализован
        break;
    }
  }

  Widget _hubContent() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('VenTal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30, color: AppColors.textDark)),
              NotificationBellButton(onTap: () {}), // TODO: экран уведомлений
            ],
          ),
          const SizedBox(height: 10),
          AddressPill(address: context.l10n.t('hub_default_address')),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: _mainTiles.map((tile) {
              return MainServiceTrapezoidButton(
                iconAsset: tile.iconPath,
                label: context.l10n.t(tile.labelKey),
                onTap: () => _handleTileTap(tile),
              );
            }).toList(),
          ),
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
          const SizedBox(height: 24),
          ServicesPreviewRow(
            tiles: _servicesPreviewTiles,
            onTap: _handleTileTap,
            onSeeAll: () => setState(() => _currentTabIndex = 1),
          ),
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
              const ServicesScreen(),
              const HistoryScreen(),
              const ProfileScreen(),
            ],
          ),
          FloatingTabBar(
            currentIndex: _currentTabIndex,
            onTap: (i) => setState(() => _currentTabIndex = i),
          ),
        ],
      ),
    );
  }
}