import 'package:flutter/material.dart';

class ColorCircle extends StatelessWidget {
  final Color color;
  final double radius;
  const ColorCircle({super.key, required this.color, this.radius = 10});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(blurRadius: 1, color: Colors.grey, spreadRadius: 1, offset: Offset(.5, 1)),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: radius,
          ),
        ),
        CircleAvatar(
          backgroundColor: color,
          radius: radius - 3,
        ),
      ],
    );
  }
}
