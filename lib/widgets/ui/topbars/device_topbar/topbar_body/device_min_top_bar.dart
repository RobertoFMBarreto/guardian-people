import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';

class DeviceMinTopBar extends StatelessWidget {
  final Device device;
  const DeviceMinTopBar({
    super.key,
    required this.device,
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
            device.device.name.value,
            style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSecondary),
          ),
        ],
      ),
    );
  }
}
