import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class FloatingSearchBar extends StatefulWidget {
  const FloatingSearchBar({super.key});

  @override
  State<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: -5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) => Transform.translate(offset: Offset(0, _bounceAnimation.value), child: child),
                child: const Icon(Icons.search_rounded, color: AppColors.textLight, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(context.l10n.t('search_hint'), style: const TextStyle(color: Colors.white70, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
