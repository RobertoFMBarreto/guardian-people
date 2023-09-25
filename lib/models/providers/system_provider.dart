import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/permissions_provider.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<bool> checkInternetConnection(BuildContext context) async {
  return await InternetAddress.lookup('google.com').then((result) {
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      }).catchError((_) {
        return false;
      }) ??
      false;
}

StreamSubscription<ConnectivityResult> wifiConnectionChecker(
    {required Function() onHasConnection, required Function() onNotHasConnection}) {
  return Connectivity().onConnectivityChanged.listen(
    (ConnectivityResult result) async {
      bool hasConnection = await InternetConnectionChecker().hasConnection;
      if (hasConnection) {
        onHasConnection();
      } else {
        onNotHasConnection();
      }
    },
  );
}

/// Method that allows to get device current location
/// @param onGetPosition -> Method to run when we get the device location
/// @param context -> current app context

Future<void> getCurrentPosition(
  BuildContext context,
  Function(Position position) onGetPosition,
) async {
  await handleLocationPermission(context).then((hasPermission) async {
    if (!hasPermission) {
      showDialog(
          context: context,
          builder: (context) {
            AppLocalizations localizations = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(localizations.no_localization.capitalize()),
              content: Text(localizations.no_localization_body.capitalize()),
            );
          });
      return;
    }

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.reduced)
        .then((dynamic position) {
      onGetPosition(position);
    }).catchError((e) {
      debugPrint(e.toString());
    });
  });
}
