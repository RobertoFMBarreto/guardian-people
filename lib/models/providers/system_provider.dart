import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:guardian/models/navigator_key.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../custom_alert_dialogs.dart';

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

StreamSubscription<ConnectivityResult> wifiConnectionChecker() {
  return Connectivity().onConnectivityChanged.listen(
    (ConnectivityResult result) async {
      bool hasConnection = await InternetConnectionChecker().hasConnection;
      if (hasConnection) {
        await setShownNoWifiDialog(false);
      } else {
        await showNoWifiDialog(navigatorKey.currentContext!);
      }
    },
  );
}
