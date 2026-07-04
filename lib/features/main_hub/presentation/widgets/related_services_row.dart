import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class RelatedServicesRow extends StatelessWidget {
  const RelatedServicesRow({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_RelatedItem>[
      _RelatedItem(AppStrings.t('chip_shops'), 'assets/images/icons/shops.png'),
      _RelatedItem(AppStrings.t('chip_veggies'), 'assets/images/icons/veggies.png'),
      _RelatedItem(AppStrings.t('chip_supplements'), 'assets/images/icons/supplements.png'),
      _RelatedItem(AppStrings.t('chip_pharmacy'), 'assets/images/icons/pharmacy.png'),
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = items[index];
          return _RelatedCircle(label: item.label, imagePath: item.imagePath);
        },
      ),
    );
  }
}

class _RelatedItem {
  final String label;
  final String imagePath;
  _RelatedItem(this.label, this.imagePath);
}

class _RelatedCircle extends StatefulWidget {
  final String label;
  final String imagePath;

  const _RelatedCircle({required this.label, required this.imagePath});

  @override
  State<_RelatedCircle> createState() => _RelatedCircleState();
}

class _RelatedCircleState extends State<_RelatedCircle> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {},
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: ClipOval(
                  child: Image.asset(widget.imagePath, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}