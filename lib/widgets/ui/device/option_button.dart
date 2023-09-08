import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';

class OptionButton extends StatelessWidget {
  final Device device;
  final Function() onRemove;
  final Function() onBlock;
  const OptionButton(
      {super.key, required this.device, required this.onRemove, required this.onBlock});

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
                onPressed: onRemove,
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
                onPressed: onBlock,
                icon: Icon(
                  device.device.isActive.value ? Icons.lock_open : Icons.lock,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  '${device.device.isActive.value ? localizations.unblock.capitalize() : localizations.block.capitalize()} ${localizations.device.capitalize()}',
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
