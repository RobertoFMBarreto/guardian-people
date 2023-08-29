import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/db/device_operations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';

class OptionButton extends StatelessWidget {
  final Device device;
  const OptionButton({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return SliverToBoxAdapter(
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.grey),
                ),
              ),
              child: TextButton.icon(
                onPressed: () {
                  //TODO: Remove device
                  deleteDevice(device.deviceId).then((_) {
                    Navigator.of(context).pop();
                  });
                },
                icon: Icon(
                  Icons.delete_forever,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  '${localizations.remove.capitalize()} ${localizations.device.capitalize()}',
                  style: theme.textTheme.bodyLarge!.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: TextButton.icon(
                onPressed: () {
                  //TODO: block device
                  updateDevice(device.copy(isActive: false));
                },
                icon: Icon(
                  device.isActive ? Icons.lock_open : Icons.lock,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  '${device.isActive ? localizations.block.capitalize() : localizations.unblock.capitalize()} ${localizations.device.capitalize()}',
                  style: theme.textTheme.bodyLarge!.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
