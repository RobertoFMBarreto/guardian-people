import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/navigator_key.dart';
import 'package:guardian/models/providers/session_provider.dart';

Future<void> showNoWifiDialog(BuildContext context) async {
  AppLocalizations localizations = AppLocalizations.of(navigatorKey.currentContext!)!;
  ThemeData theme = Theme.of(context);
  hasShownNoWifiDialog().then((hasShown) async {
    print("Has showed: $hasShown");
    if (!hasShown) {
      setShownNoWifiDialog(true).then(
        (_) => showDialog<void>(
          context: navigatorKey.currentContext!,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(localizations.no_wifi.capitalize()),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(localizations.no_wifi_operations.capitalize()),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    localizations.ok.capitalize(),
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        ),
      );
    }
  });
}

Future<void> showNoWifiLoginDialog(BuildContext context) async {
  AppLocalizations localizations = AppLocalizations.of(context)!;
  ThemeData theme = Theme.of(context);

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localizations.no_wifi.capitalize()),
        actions: <Widget>[
          TextButton(
            child: Text(
              localizations.ok.capitalize(),
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
