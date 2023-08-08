import 'package:flutter/material.dart';

class ColorCircle extends StatelessWidget {
  final Color color;
  const ColorCircle({super.key, required this.color});

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
          child: const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 10,
          ),
        ),
        CircleAvatar(
          backgroundColor: color,
          radius: 7,
        ),
      ],
    );
  }
}
