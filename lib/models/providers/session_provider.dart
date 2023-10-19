import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Method for setting the user session with [idUser] and the session token [token]
Future<void> setUserSession(BigInt idUser, String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setString("token", token);
  await prefs.setString("idUser", idUser.toString());
}

/// Method for clearing the shared preferences of the app
Future<void> clearUserSession() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.clear();
}

/// Method that checks if there is session
///
/// It verifies if there is user data stored in the shared preferences
Future<bool> hasUserSession() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String? idUser = prefs.getString('idUser');
  return idUser != null;
}

/// Method that checks the [showedNoWifi]
///
/// If [showedNoWifi] is null it returns false
Future<bool> hasShownNoWifiDialog() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  bool? hasShowed = prefs.getBool('showedNoWifi');
  if (hasShowed == null) {
    hasShowed = false;
    setShownNoWifiDialog(false);
  }
  return hasShowed;
}

/// Method that checks the [showedNoServerConnection]
///
/// If [showedNoServerConnection] is null it returns false
Future<bool> hasShownNoServerConnection() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  bool? hasShowed = prefs.getBool('showedNoServerConnection');
  if (hasShowed == null) {
    hasShowed = false;
    setShownNoServerConnection(false);
  }
  return hasShowed;
}

/// Method that sets [showedNoWifi] value
Future<void> setShownNoWifiDialog(bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setBool('showedNoWifi', value);
}

/// Method that sets [showedNoServerConnection] value
Future<void> setShownNoServerConnection(bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setBool('showedNoServerConnection', value);
}

/// Method that sets the user session token
Future<void> setSessionToken(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setString('token', value);
}

/// Method that allows to get the id of the user
///
/// If the id isn't setted then the user will be redirected to login
Future<BigInt?> getUid(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? dt = prefs.getString('idUser');
  if (dt != null) {
    BigInt? idUser = BigInt.from(int.parse(dt));
    return idUser;
  } else {
    clearUserSession().then((_) => deleteEverything().then(
          (_) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
          },
        ));
  }
  return null;
}

/// Method that allows to get the session token
Future<String?> getToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String? token = prefs.getString('token');
  return token;
}
