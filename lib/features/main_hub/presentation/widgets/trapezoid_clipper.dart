import 'package:flutter/material.dart';

/// Приближение формы "флажок/трапеция, сужается к правому краю",
/// со скруглёнными углами. Не пиксель-в-пиксель со SVG, но близко по силуэту.
class TrapezoidClipper extends CustomClipper<Path> {
  final double cornerRadius;

  const TrapezoidClipper({this.cornerRadius = 18});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final inset = w * 0.14;
    final r = cornerRadius;

    final path = Path();
    path.moveTo(r, 0);
    path.lineTo(w - inset - r, 0);
    path.quadraticBezierTo(w - inset, 0, w - inset + r * 0.6, r);
    path.lineTo(w - r * 0.5, h / 2 - r);
    path.quadraticBezierTo(w, h / 2, w - r * 0.5, h / 2 + r);
    path.lineTo(w - inset + r * 0.6, h - r);
    path.quadraticBezierTo(w - inset, h, w - inset - r, h);
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}