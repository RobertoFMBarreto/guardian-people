import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/fencing_provider.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';

class FencingRequests {
  static Future<void> createFence({
    required FenceCompanion fence,
    required List<FencePointsCompanion> fencePoints,
    required BuildContext context,
    required Function onFailed,
  }) async {
    /// MEthod that allows to request for the creation of a new fence
    await FencingProvider.createFence(fence, fencePoints).then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
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
        onFailed();
      }
    });
  }
}
