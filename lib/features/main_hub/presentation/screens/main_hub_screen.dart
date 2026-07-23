import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/features/location/presentation/state/location_controller.dart';
import 'package:vental_go/features/location/presentation/sheets/country_city_picker_sheet.dart';
import 'package:vental_go/features/location/presentation/sheets/address_input_sheet.dart';
import '../widgets/floating_tab_bar.dart';
import '../widgets/home_banner.dart';
import '../widgets/notification_bell_button.dart';
import 'package:vental_go/features/taxi/presentation/screens/taxi_order_screen.dart';
import 'package:vental_go/features/food/presentation/screens/restaurant_list_screen.dart';
import 'package:vental_go/features/parcels/presentation/screens/parcel_screen.dart';
import 'package:vental_go/features/services/presentation/screens/services_screen.dart';
import 'package:vental_go/features/history/presentation/screens/history_screen.dart';
import 'package:vental_go/features/profile/presentation/screens/profile_screen.dart';
import 'package:vental_go/features/notifications/presentation/screens/notifications_screen.dart';

class MainHubScreen extends StatefulWidget {
  const MainHubScreen({super.key});

  @override
  State<MainHubScreen> createState() => _MainHubScreenState();
}

class _MainHubScreenState extends State<MainHubScreen> {
  int _currentTabIndex = 0;

  static const _categories = [
    _Category(id: 'food', labelKey: 'cat_food', iconPath: 'assets/images/services/food.png'),
    _Category(id: 'taxi', labelKey: 'cat_taxi', iconPath: 'assets/images/services/taxi.png'),
    _Category(id: 'parcels', labelKey: 'cat_parcel', iconPath: 'assets/images/services/parcels.png'),
    _Category(id: 'shops', labelKey: 'cat_shops', iconPath: 'assets/images/icons/shops.png'),
    _Category(id: 'veggies', labelKey: 'cat_veggies', iconPath: 'assets/images/icons/veggies.png'),
    _Category(id: 'supplements', labelKey: 'cat_supplements', iconPath: 'assets/images/icons/supplements.png'),
    _Category(id: 'pharmacy', labelKey: 'cat_pharmacy', iconPath: 'assets/images/icons/pharmacy.png'),
  ];

  void _handleCategoryTap(_Category cat) {
    switch (cat.id) {
      case 'taxi':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TaxiOrderScreen()));
        break;
      case 'food':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RestaurantListScreen()));
        break;
      case 'parcels':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParcelScreen()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Скоро будет доступно'), duration: Duration(seconds: 2)),
        );
    }
  }

  Future<void> _handleLocationTap(LocationController loc) async {
    if (!loc.citySetupDone) {
      // First time: pick country + city
      final result = await showCountryCityPicker(context);
      if (result != null && mounted) {
        await loc.setCity(result.country, result.city);
        // Then show address input
        if (mounted) await showAddressInputSheet(context);
      }
    } else {
      // City already set — only address can be changed
      await showAddressInputSheet(context);
    }
  }

  Widget _hubContent() {
    final loc = context.watch<LocationController>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _Header(
                loc: loc,
                onLocationTap: () => _handleLocationTap(loc),
                onBellTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
              ),
            ),
          ),

          // Categories grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = _categories[index];
                  return _CategoryTile(
                    cat: cat,
                    label: context.l10n.t(cat.labelKey),
                    onTap: () => _handleCategoryTap(cat),
                  );
                },
                childCount: _categories.length,
              ),
            ),
          ),

          // Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: HomeBanner(onTap: () {}),
            ),
          ),

          // Bottom padding for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

// ─── Header widget ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final LocationController loc;
  final VoidCallback onLocationTap;
  final VoidCallback onBellTap;

  const _Header({required this.loc, required this.onLocationTap, required this.onBellTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Location pill
        Expanded(
          child: GestureDetector(
            onTap: onLocationTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Текущая локация',
                        style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      if (loc.isSet)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                loc.savedAddress.isNotEmpty
                                    ? loc.savedAddress
                                    : loc.headerLabel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textDark, size: 18),
                          ],
                        )
                      else
                        const Text(
                          'Выберите локацию',
                          style: TextStyle(fontSize: 14, color: AppColors.textHint),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        NotificationBellButton(onTap: onBellTap),
      ],
    );
  }
}

// ─── Category tile ────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final _Category cat;
  final String label;
  final VoidCallback onTap;

  const _CategoryTile({required this.cat, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                cat.iconPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.apps_rounded,
                  color: AppColors.primary.withValues(alpha: 0.6),
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class _Category {
  final String id;
  final String labelKey;
  final String iconPath;

  const _Category({required this.id, required this.labelKey, required this.iconPath});
}
