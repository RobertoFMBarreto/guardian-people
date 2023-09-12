import 'package:flutter/material.dart';

class CircleAvatarBorder extends StatelessWidget {
  final double? radius;
  const CircleAvatarBorder({super.key, this.radius});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: const BorderRadius.all(
        Radius.circular(10000),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: radius != null ? radius! + 2 : null,
            backgroundColor: Colors.white,
          ),
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
