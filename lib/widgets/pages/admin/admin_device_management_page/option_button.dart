import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/extensions/string_extension.dart';

class OptionButton extends StatelessWidget {
  const OptionButton({super.key});

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
                },
                icon: Icon(
                  Icons.lock,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  '${localizations.block.capitalize()} ${localizations.device.capitalize()}',
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
