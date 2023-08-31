import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

Future<bool> checkInternetConnection(BuildContext context) async {
  return await InternetAddress.lookup('google.com').then((result) {
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print("Has Connection");
          return true;
        }
      }).catchError((_) {
        print("No Connection");
        return false;
      }) ??
      false;
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
