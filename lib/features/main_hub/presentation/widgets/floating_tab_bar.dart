import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class FloatingTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingTabBar({super.key, required this.currentIndex, required this.onTap});

  static const _tabs = [
    (icon: Icons.home_outlined, iconActive: Icons.home_rounded, labelKey: 'tab_home'),
    (icon: Icons.grid_view_outlined, iconActive: Icons.grid_view_rounded, labelKey: 'tab_services'),
    (icon: Icons.receipt_long_outlined, iconActive: Icons.receipt_long_rounded, labelKey: 'tab_history'),
    (icon: Icons.person_outline_rounded, iconActive: Icons.person_rounded, labelKey: 'tab_profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
            boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -3))],
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
            Icon(
              isActive ? tab.iconActive : tab.icon,
              color: isActive ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              context.l10n.t(tab.labelKey),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
