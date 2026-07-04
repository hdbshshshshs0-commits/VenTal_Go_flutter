import 'dart:async';
import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class PromoCarouselItem {
  final String imagePath;
  final String? titleKey;
  final VoidCallback? onTap;

  const PromoCarouselItem({required this.imagePath, this.titleKey, this.onTap});
}

class PromoCarousel extends StatefulWidget {
  final List<PromoCarouselItem> items;

  const PromoCarousel({super.key, required this.items});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.items.isEmpty) return;
      _currentPage = (_currentPage + 1) % widget.items.length;
      _controller.animateToPage(_currentPage, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
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
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: item.onTap,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(item.imagePath, fit: BoxFit.cover),
                        if (item.titleKey != null)
                          Positioned(
                            left: 16,
                            bottom: 14,
                            right: 16,
                            child: Text(
                              context.l10n.t(item.titleKey!),
                              style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
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
          children: List.generate(widget.items.length, (index) {
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