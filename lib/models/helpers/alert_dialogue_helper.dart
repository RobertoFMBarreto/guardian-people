import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/helpers/navigator_key_helper.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/colors.dart';

/// Method that shows a loading indicator dialogue
void showLoadingDialog(BuildContext context) {
  AppLocalizations localizations = AppLocalizations.of(navigatorKey.currentContext!)!;
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The loading indicator
              const CircularProgressIndicator(color: gdSecondaryColor),
              const SizedBox(
                height: 15,
              ),
              // Some text
              Text(localizations.loading.capitalizeFirst!)
            ],
          ),
        ),
      );
    },
  );
}

/// Method to show to the user that he has no wifi
///
/// This method verifies if this dialogue has already been showed
///
/// If it hasn't been showed then it shows and sets the showed dialogue user preference to `true`
Future<void> showNoWifiDialog(BuildContext context) async {
  AppLocalizations localizations = AppLocalizations.of(navigatorKey.currentContext!)!;
  ThemeData theme = Theme.of(context);
  hasShownNoWifiDialog().then((hasShown) async {
    if (!hasShown) {
      setShownNoWifiDialog(true).then(
        (_) => showDialog<void>(
          context: navigatorKey.currentContext!,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text(localizations.no_wifi.capitalizeFirst!),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(localizations.no_wifi_operations.capitalizeFirst!),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    localizations.ok.capitalizeFirst!,
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

/// This method is similar to the [showNoWifiDialog] but this one shows the dialogue every time its executed
Future<void> showNoWifiLoginDialog(BuildContext context) async {
  AppLocalizations localizations = AppLocalizations.of(context)!;
  ThemeData theme = Theme.of(context);

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(localizations.no_wifi.capitalizeFirst!),
        actions: <Widget>[
          TextButton(
            child: Text(
              localizations.ok.capitalizeFirst!,
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

void showNoConnectionSnackBar() {
  if (!isSnackbarActive) {
    AppLocalizations localizations = AppLocalizations.of(navigatorKey.currentContext!)!;
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          localizations.no_server_connection.capitalize!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(days: 365),
        backgroundColor: gdErrorColor,
        padding: const EdgeInsets.only(top: 2, bottom: 4),
      ),
    );
    isSnackbarActive = true;
  }
}
