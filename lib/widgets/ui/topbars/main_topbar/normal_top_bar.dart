import 'package:flutter/material.dart';

/// Class that represents the normal top bar body
class NormalTopBar extends StatelessWidget {
  final String name;
  const NormalTopBar({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            name,
            style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSecondary),
          ),
          const SizedBox(
            width: 5,
          ),
          const CircleAvatar(
            backgroundColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}
