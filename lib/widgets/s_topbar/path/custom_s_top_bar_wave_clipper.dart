import 'package:flutter/material.dart';

class CustomSTopBarWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    const minSize = 70;
    final p0 = size.height;

    path.lineTo(0.0, p0);
    if (p0 != minSize) {
      final p1_middle = Offset(size.width * 0.001, size.height * 0.8);
      final p1 = Offset(size.width * 0.15, size.height * 0.8);

      path.quadraticBezierTo(p1_middle.dx, p1_middle.dy, p1.dx, p1.dy);

      final p2 = Offset(size.width * 0.9, size.height * 0.8);
      final p2Middle = Offset(size.width, size.height * 0.8);
      final p3 = Offset(size.width, size.height * 0.6);
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
