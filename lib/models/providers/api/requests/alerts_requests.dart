import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/helpers/navigator_key_helper.dart';
import 'package:guardian/models/providers/api/alerts_provider.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/parsers/alerts_parsers.dart';
import 'package:guardian/models/providers/api/parsers/sensor_parser.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';

/// Class that represents the alert requests
class AlertRequests {
  /// Method that allows to get all alertable sensors from the API
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> getAlertableSensorsFromApi(
      {required BuildContext context,
      required Function(String) onDataGotten,
      required Function(int) onFailed}) async {
    await AlertsProvider.getAlertableSensors().then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        await parseSensors(response.body).then(
          (_) async => await onDataGotten(response.body),
        );
      } else if (response.statusCode == 401) {
        await AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) async => await getAlertableSensorsFromApi(
                context: context,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
              ),
            );
          } else if (resp.statusCode == 507) {
            await hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                await setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
          } else {
            await clearUserSession().then((_) async => await deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        await hasShownNoServerConnection().then((hasShown) async {
          if (!hasShown) {
            await setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }

  /// Method that allows to create an alert in the API
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> addAlertToApi(
      {required BuildContext context,
      required UserAlertCompanion alert,
      required List<Animal> animals,
      required Function(String) onDataGotten,
      required Function(int) onFailed}) async {
    AlertsProvider.createAlert(alert, animals).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        alertFromJson(jsonDecode(response.body)).then((_) => onDataGotten(response.body));
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => addAlertToApi(
                context: context,
                onDataGotten: onDataGotten,
                alert: alert,
                animals: animals,
                onFailed: onFailed,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
          } else {
            clearUserSession().then((_) => deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        hasShownNoServerConnection().then((hasShown) async {
          if (!hasShown) {
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }

  /// Method that allows to update an alert in the API
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> updateAlertToApi(
      {required BuildContext context,
      required UserAlertCompanion alert,
      required List<Animal> animals,
      required Function(String) onDataGotten,
      required Function(int) onFailed}) async {
    await AlertsProvider.updateAlert(alert, animals).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        removeAllAlertAnimals(alert.idAlert.value).then(
          (_) => alertFromJson(jsonDecode(response.body)).then(
            (_) => onDataGotten(response.body),
          ),
        );
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => updateAlertToApi(
                context: context,
                onDataGotten: onDataGotten,
                alert: alert,
                animals: animals,
                onFailed: onFailed,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
          } else {
            clearUserSession().then((_) => deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        hasShownNoServerConnection().then((hasShown) async {
          if (!hasShown) {
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }

  /// Method that allows to get all user alerts from API
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> getUserAlertsFromApi(
      {required BuildContext context,
      required Function(String) onDataGotten,
      required Function(int) onFailed}) async {
    AlertsProvider.getAllAlerts().then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        await deleteAllAlerts().then(
          (_) async => await alertsFromJson(response.body).then(
            (_) async => await onDataGotten(response.body),
          ),
        );
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => getUserAlertsFromApi(
                context: context,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
          } else {
            clearUserSession().then((_) => deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        hasShownNoServerConnection().then((hasShown) async {
          if (!hasShown) {
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }

  /// Method that allows to delete user alert from API
  ///
  /// In case of auth error [401] it refreshes the token and tries again if it fails again it send the user to the login page
  ///
  /// In case of server unreachable [507] it shows the user that there is no connection to the server
  ///
  /// Any other error will send the user to login deleting all data
  static Future<void> deleteUserAlertFromApi(
      {required BuildContext context,
      required String alertId,
      required Function(String) onDataGotten,
      required Function(int) onFailed}) async {
    await AlertsProvider.deleteAlert(alertId).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        onDataGotten(response.body);
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => deleteUserAlertFromApi(
                context: context,
                alertId: alertId,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then((_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                        .then((_) => onFailed(resp.statusCode)));
              }
            });
            onFailed(resp.statusCode);
          } else {
            clearUserSession().then((_) => deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        hasShownNoServerConnection().then((hasShown) async {
          if (!hasShown) {
            setShownNoServerConnection(true).then((_) =>
                showDialog(context: context, builder: (context) => const ServerErrorDialogue())
                    .then((_) => onFailed(response.statusCode)));
          }
        });
      } else {
        onFailed(response.statusCode);
      }
    });
  }
}
