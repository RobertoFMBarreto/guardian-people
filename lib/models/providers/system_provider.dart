import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guardian/models/custom_alert_dialogs.dart';
import 'package:guardian/models/providers/session_provider.dart';

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