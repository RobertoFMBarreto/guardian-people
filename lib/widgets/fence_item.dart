import 'package:flutter/material.dart';
import 'package:guardian/widgets/color_circle.dart';

class FenceItem extends StatelessWidget {
  final String name;
  final Color color;
  final Function() onRemove;
  const FenceItem({super.key, required this.onRemove, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                name,
                style: theme.textTheme.bodyLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      'Cor:',
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ColorCircle(
                    color: color,
                  ),
                ],
              ),
            )
          ],
        ),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.delete_forever),
          iconSize: 30,
          color: theme.colorScheme.error,
        )
      ],
    );
  }
}
