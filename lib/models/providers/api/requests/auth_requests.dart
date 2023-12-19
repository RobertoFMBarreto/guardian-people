import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/helpers/navigator_key_helper.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';

/// Class that represents the auth requests
class AuthRequests {
  /// Method that refreshes user device token in the API
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> refreshDevicetoken(
      {required BuildContext context,
      required String devicetoken,
      bool onFailGoLogin = true,
      required Function onDataGotten}) async {
    AuthProvider.refreshDeviceToken(devicetoken).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        onDataGotten();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => refreshDevicetoken(
                context: context,
                devicetoken: devicetoken,
                onDataGotten: onDataGotten,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) => showDialog(
                    context: context, builder: (context) => const ServerErrorDialogue()));
              }
            });
          } else {
            if (onFailGoLogin) {
              await clearUserSession().then((_) async => await deleteEverything().then(
                    (_) => Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (Route<dynamic> route) => false),
                  ));
            }
          }
        });
      } else if (response.statusCode == 507) {
        hasShownNoServerConnection().then((hasShown) async {
          if (!hasShown) {
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue()));
          }
        });
      }
    });
  }
}
