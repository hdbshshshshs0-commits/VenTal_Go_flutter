import 'package:flutter/material.dart';

class TrapezoidClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double cutWidth;

  const TrapezoidClipper({this.cornerRadius = 16, this.cutWidth = 18});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = cornerRadius;
    final cut = cutWidth;

    final rrect = RRect.fromRectAndCorners(
      Rect.fromLTRB(0, 0, w - cut, h),
      topLeft: Radius.circular(r),
      bottomLeft: Radius.circular(r),
      topRight: Radius.circular(r * 0.6),
      bottomRight: Radius.circular(r * 0.6),
    );

    final path = Path()..addRRect(rrect);
    // Треугольный "хвост" справа, сходящийся к середине высоты.
    path.moveTo(w - cut, h * 0.12);
    path.lineTo(w, h / 2);
    path.lineTo(w - cut, h * 0.88);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}