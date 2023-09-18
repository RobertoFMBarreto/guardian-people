import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

class DeviceMinTopBar extends StatelessWidget {
  final Animal animal;
  const DeviceMinTopBar({
    super.key,
    required this.animal,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSecondary),
          ),
          Text(
            animal.animal.animalName.value,
            style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSecondary),
          ),
        ],
      ),
    );
  }
}
