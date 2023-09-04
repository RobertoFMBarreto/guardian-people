import 'package:flutter/material.dart';

class ColorCircle extends StatelessWidget {
  final Color color;
  final double radius;
  const ColorCircle({super.key, required this.color, this.radius = 10});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 1,
                color: theme.brightness == Brightness.light ? Colors.grey : Colors.grey.shade400,
                spreadRadius: 1,
                offset: const Offset(.5, 1),
              ),
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
