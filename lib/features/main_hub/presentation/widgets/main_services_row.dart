import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/service_tile_model.dart';

class MainServicesRow extends StatelessWidget {
  final List<ServiceTileModel> tiles;
  final void Function(ServiceTileModel tile) onTap;

  const MainServicesRow({super.key, required this.tiles, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tiles
          .map((tile) => _MainServiceCircle(
                label: context.l10n.t(tile.labelKey),
                imagePath: tile.iconPath,
                onTap: () => onTap(tile),
              ))
          .toList(),
    );
  }
}

class _MainServiceCircle extends StatefulWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;

  const _MainServiceCircle({required this.label, required this.imagePath, required this.onTap});

  @override
  State<_MainServiceCircle> createState() => _MainServiceCircleState();
}

class _MainServiceCircleState extends State<_MainServiceCircle> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 14, offset: Offset(0, 6))],
              ),
              padding: const EdgeInsets.all(14),
              child: ClipOval(child: Image.asset(widget.imagePath, fit: BoxFit.cover)),
            ),
            const SizedBox(height: 8),
            Text(widget.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}
