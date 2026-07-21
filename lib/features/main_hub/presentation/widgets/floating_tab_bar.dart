import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class FloatingTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingTabBar({super.key, required this.currentIndex, required this.onTap});

  static const _tabs = [
    (icon: Icons.home_rounded, labelKey: 'tab_home'),
    (icon: Icons.grid_view_rounded, labelKey: 'tab_services'),
    (icon: Icons.history_rounded, labelKey: 'tab_history'),
    (icon: Icons.person_rounded, labelKey: 'tab_profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Row(
            children: [
              for (int i = 0; i < _tabs.length; i++) _tabItem(context, index: i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabItem(BuildContext context, {required int index}) {
    final tab = _tabs[index];
    final isActive = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(tab.icon, color: isActive ? AppColors.primary : AppColors.textHint, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.t(tab.labelKey),
              style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? AppColors.primary : AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}