import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../screens/aitym_recommendations_screen.dart';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _timer;

  final List<_PromoItem> _items = const [
    _PromoItem(
      imagePath: 'assets/images/banners/collab_aitym.png',
      title: 'banner_collab',
      isCollab: true,
    ),
    _PromoItem(imagePath: 'assets/images/banners/promo_1.png', title: '', isCollab: false),
    _PromoItem(imagePath: 'assets/images/banners/promo_2.png', title: '', isCollab: false),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % _items.length;
      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _controller,
            itemCount: _items.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final item = _items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: item.isCollab
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AitymRecommendationsScreen()),
                          );
                        }
                      : () {},
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(item.imagePath, fit: BoxFit.cover),
                        if (item.isCollab)
                          Positioned(
                            left: 16,
                            bottom: 14,
                            right: 16,
                            child: Text(
                              AppStrings.t(item.title),
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_items.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PromoItem {
  final String imagePath;
  final String title;
  final bool isCollab;
  const _PromoItem({required this.imagePath, required this.title, required this.isCollab});
}