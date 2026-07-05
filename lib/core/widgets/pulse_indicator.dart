import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';

class PulseIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const PulseIndicator({super.key, this.color = AppColors.primary, this.size = 60});

  @override
  State<PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<PulseIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - _controller.value).clamp(0.0, 1.0),
                child: Container(
                  width: widget.size * _controller.value,
                  height: widget.size * _controller.value,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color.withValues(alpha: 0.3)),
                ),
              ),
              Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
              ),
            ],
          );
        },
      ),
    );
  }
}
