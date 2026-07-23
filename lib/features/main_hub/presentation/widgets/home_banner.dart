import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';

/// Single promotional banner on home screen.
/// Shows home_banner.png if available, otherwise a branded placeholder.
class HomeBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const HomeBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 148,
          width: double.infinity,
          child: Image.asset(
            'assets/images/banners/home_banner.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _PlaceholderBanner(),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF05C283), Color(0xFF038A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Fast delivery\nat your door',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Food, groceries, parcels and more',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('VT', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
