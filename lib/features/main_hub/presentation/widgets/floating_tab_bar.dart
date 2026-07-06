import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

class FloatingTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingTabBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 60,
      right: 60,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Row(
            children: [
              _tabItem(icon: Icons.home_rounded, index: 0),
              _tabItem(icon: Icons.person_rounded, index: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabItem({required IconData icon, required int index}) {
    final isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
