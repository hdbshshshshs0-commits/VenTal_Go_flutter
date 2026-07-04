import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/service_tile_model.dart';

class RelatedServicesRow extends StatelessWidget {
  final List<ServiceTileModel> tiles;
  final void Function(ServiceTileModel tile) onTap;

  const RelatedServicesRow({super.key, required this.tiles, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final tile = tiles[index];
          return _RelatedCircle(
            label: context.l10n.t(tile.labelKey),
            imagePath: tile.iconPath,
            onTap: () => onTap(tile),
          );
        },
      ),
    );
  }
}

class _RelatedCircle extends StatefulWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;

  const _RelatedCircle({required this.label, required this.imagePath, required this.onTap});

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
      onTap: widget.onTap,
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
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                padding: const EdgeInsets.all(10),
                child: ClipOval(child: Image.asset(widget.imagePath, fit: BoxFit.cover)),
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