import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:guardian/models/custom_alert_dialogs.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

Future<void> checkInternetConnection(BuildContext context) async {
  InternetAddress.lookup('google.com').then((result) {
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      setShownNoWifiDialog(false);
    }
  }).catchError((_) {
    hasShownNoWifiDialog().then((hasShown) {
      if (!hasShown) {
        showNoWifiDialog(context);
        setShownNoWifiDialog(true);
      }
    });
  });
}

StreamSubscription<ConnectivityResult> wifiConnectionChecker({
  required BuildContext context,
  required Function onHasConnection,
  required Function onNotHasConnection,
}) {
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
