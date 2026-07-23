import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';

/// Floating center-pin widget shown over the map.
/// Displays address text inside a speech-bubble shape.
/// Auto-expands horizontally when address is long.
class CenterPinWidget extends StatelessWidget {
  final String? address;
  final bool isSearching;

  const CenterPinWidget({super.key, this.address, this.isSearching = false});

  @override
  Widget build(BuildContext context) {
    final text = isSearching
        ? 'Ищем адрес...'
        : (address ?? 'Ищем адрес...');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bubble
        Container(
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSearching) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
              ] else ...[
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSearching ? AppColors.textHint : AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Pointer triangle
        CustomPaint(
          size: const Size(16, 10),
          painter: _TrianglePainter(),
        ),
        // Pin dot
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x11000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
