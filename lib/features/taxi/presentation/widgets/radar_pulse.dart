import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';

class RadarPulse extends StatefulWidget {
  final Widget child;
  final double maxSize;
  final Color color;

  const RadarPulse({
    super.key,
    required this.child,
    this.maxSize = 320,
    this.color = AppColors.primary,
  });

  @override
  State<RadarPulse> createState() => _RadarPulseState();
}

class _RadarPulseState extends State<RadarPulse> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  static const int _ringCount = 3;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_ringCount, (i) {
      final controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();
      Future.delayed(Duration(milliseconds: (2000 ~/ _ringCount) * i), () {
        if (mounted) controller.forward(from: 0);
      });
      return controller;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.maxSize,
      height: widget.maxSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ..._controllers.map((controller) {
            return AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final progress = controller.value;
                final size = widget.maxSize * progress;
                final opacity = (1 - progress).clamp(0.0, 1.0) * 0.5;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.color.withValues(alpha: opacity), width: 2.5),
                  ),
                );
              },
            );
          }),
          widget.child,
        ],
      ),
    );
  }
}
