import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/notifications_provider.dart';
import 'package:guardian/models/providers/api/parsers/notifications_parsers.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';

class NotificationsRequests {
  /// Method that allows to get all user notifications from api
  static Future<void> getUserNotificationsFromApi(
      {required BuildContext context,
      required Function(String) onDataGotten,
      required Function onFailed}) async {
    NotificationsProvider.getNotifications().then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        parseNotifications(response.body).then((_) => onDataGotten(response.body));
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => getUserNotificationsFromApi(
                context: context,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
            });
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
            setShownNoServerConnection(true).then(
              (_) =>
                  showDialog(context: context, builder: (context) => const ServerErrorDialogue()),
            );
          }
        });
      }
    });
  }

  /// Method that allows to get all user notifications from api
  static Future<void> deleteAllNotificationsFromApi(
      {required BuildContext context,
      required Function(String) onDataGotten,
      required Function onFailed}) async {
    NotificationsProvider.deleteAllNotifications().then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        parseNotifications(response.body).then((_) => onDataGotten(response.body));
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => deleteAllNotificationsFromApi(
                context: context,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
            });
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
            setShownNoServerConnection(true).then(
              (_) =>
                  showDialog(context: context, builder: (context) => const ServerErrorDialogue()),
            );
          }
        });
      }
    });
  }

  /// Method that allows to get all user notifications from api
  static Future<void> deleteNotificationFromApi(
      {required BuildContext context,
      required String idNotification,
      required Function(String) onDataGotten,
      required Function onFailed}) async {
    NotificationsProvider.deleteNotification(idNotification).then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        parseNotifications(response.body).then((_) => onDataGotten(response.body));
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => deleteNotificationFromApi(
                context: context,
                idNotification: idNotification,
                onDataGotten: onDataGotten,
                onFailed: onFailed,
              ),
            );
          } else if (resp.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
            });
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
            setShownNoServerConnection(true).then(
              (_) =>
                  showDialog(context: context, builder: (context) => const ServerErrorDialogue()),
            );
          }
        });
      }
    });
  }
}
