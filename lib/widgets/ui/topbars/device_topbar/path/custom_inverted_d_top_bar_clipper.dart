import 'package:flutter/material.dart';

/// Class that represents the inverted D shape top bar clipper
class CustomInvertedDTopBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    const minSize = 70;
    final p0 = size.height * 0.8;

    path.lineTo(0.0, p0);
    if (p0 != minSize) {
      final p1Middle = Offset(size.width * 0.001, size.height);
      final p1 = Offset(size.width * 0.15, size.height);

      path.quadraticBezierTo(p1Middle.dx, p1Middle.dy, p1.dx, p1.dy);

      final p2 = Offset(size.width * 0.85, size.height);
      final p2Middle = Offset(size.width, size.height);
      final p3 = Offset(size.width, size.height * 0.8);
      path.lineTo(p2.dx, p2.dy);
      path.quadraticBezierTo(p2Middle.dx, p2Middle.dy, p3.dx, p3.dy);
    } else {
      path.lineTo(size.width, 70);
    }
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => oldClipper != this;
}
