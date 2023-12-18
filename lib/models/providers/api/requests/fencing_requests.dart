import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/helpers/navigator_key_helper.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/fencing_provider.dart';
import 'package:guardian/models/providers/api/parsers/fences_parsers.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';

class FencingRequests {
  /// Method that allows to request for the creation of a new fence
  static Future<void> createFence({
    required FenceCompanion fence,
    required List<FencePointsCompanion> fencePoints,
    required BuildContext context,
    required Function(int) onFailed,
  }) async {
    await FencingProvider.createFence(fence, fencePoints).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => createFence(
                fence: fence,
                fencePoints: fencePoints,
                onFailed: onFailed,
                context: context,
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

  /// Method that allows to request for the creation of a new fence
  static Future<void> removeFence({
    required String idFence,
    required BuildContext context,
    required Function() onGottenData,
    required Function(int) onFailed,
  }) async {
    await FencingProvider.removeFence(idFence).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        onGottenData();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => removeFence(
                idFence: idFence,
                onFailed: onFailed,
                onGottenData: onGottenData,
                context: context,
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

  /// Method that allows to request for the creation of a new fence
  static Future<void> getUserFences({
    required BuildContext context,
    required Function(String) onGottenData,
    required Function(int) onFailed,
  }) async {
    await FencingProvider.getUserFences().then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        await removeAllFences().then(
          (_) async => await fencesFromJson(response.body).then(
            (_) async => await onGottenData(response.body),
          ),
        );
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => getUserFences(
                onFailed: onFailed,
                onGottenData: onGottenData,
                context: context,
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

  /// Method that allows to request to update a fence
  static Future<void> updateFence({
    required FenceCompanion fence,
    required List<FencePointsCompanion> fencePoints,
    required BuildContext context,
    required Function(int) onFailed,
  }) async {
    await FencingProvider.updateFence(fence, fencePoints).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => createFence(
                fence: fence,
                fencePoints: fencePoints,
                onFailed: onFailed,
                context: context,
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

  /// Method that allows to request to add an animal to a fence
  static Future<void> addAnimalFence({
    required String fenceId,
    required List<String> animalIds,
    required BuildContext context,
    required Function(int) onFailed,
  }) async {
    await FencingProvider.addAnimalFence(fenceId, animalIds).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => addAnimalFence(
                fenceId: fenceId,
                animalIds: animalIds,
                onFailed: onFailed,
                context: context,
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

  /// Method that allows to request to remove an animal from a fence
  static Future<void> removeAnimalFence({
    required String fenceId,
    required List<String> animalIds,
    required BuildContext context,
    required Function(int) onFailed,
    required Function onDataGotten,
  }) async {
    await FencingProvider.removeAnimalFence(fenceId, animalIds).then((response) async {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
        setShownNoServerConnection(false);
        await onDataGotten();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken).then(
              (value) => removeAnimalFence(
                fenceId: fenceId,
                animalIds: animalIds,
                onFailed: onFailed,
                context: context,
                onDataGotten: onDataGotten,
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
