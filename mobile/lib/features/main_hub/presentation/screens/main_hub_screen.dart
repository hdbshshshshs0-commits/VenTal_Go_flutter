import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/address_pill.dart';
import '../widgets/main_services_row.dart';
import '../widgets/related_services_row.dart';
import '../widgets/promo_carousel.dart';
import '../widgets/floating_search_bar.dart';

class MainHubScreen extends StatelessWidget {
  const MainHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: const [
                AddressPill(),
                SizedBox(height: 20),
                MainServicesRow(),
                SizedBox(height: 20),
                RelatedServicesRow(),
                SizedBox(height: 24),
                PromoCarousel(),
                SizedBox(height: 20),
              ],
            ),
          ),
          const FloatingSearchBar(),
        ],
      ),
    );
  }
}