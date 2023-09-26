import 'package:flutter/material.dart';

/// This class represents the focus manager of the app
class CustomFocusManager {
  /// Method for removing the current app focus
  static void unfocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
