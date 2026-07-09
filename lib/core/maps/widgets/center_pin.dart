import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';

class CenterPin extends StatelessWidget {
  final bool isLoading;
  final String? address;

  const CenterPin({super.key, this.isLoading = false, this.address});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Image.asset('assets/images/icons/center_pin.png', width: 48, height: 64),
          ),
          Positioned(
            top: 40,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: _buildChip(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip() {
    if (isLoading) {
      return Container(
        key: const ValueKey('loading'),
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: const SizedBox(
          width: 90,
          height: 12,
          child: LinearProgressIndicator(minHeight: 3, borderRadius: BorderRadius.all(Radius.circular(2))),
        ),
      );
    }

    if (address == null) return const SizedBox.shrink(key: ValueKey('empty'));

    return Container(
      key: ValueKey(address),
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Text(
        address!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
      ),
    );
  }
}