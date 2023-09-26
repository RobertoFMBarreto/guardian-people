import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setUserSession(BigInt idUser, String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // !TODO: Store jwt token
  await prefs.setString("token", token);
  await prefs.setString("idUser", idUser.toString());
}

Future<void> clearUserSession() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // remove all session data
  await prefs.clear();
}

Future<bool> hasUserSession() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String? idUser = prefs.getString('idUser');
  return idUser != null;
}

Future<bool> hasShownNoWifiDialog() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  bool? hasShowed = prefs.getBool('showedNoWifi');
  if (hasShowed == null) {
    hasShowed = false;
    setShownNoWifiDialog(false);
  }
  return hasShowed;
}

Future<bool> hasShownNoServerConnection() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  bool? hasShowed = prefs.getBool('showedNoServerConnection');
  if (hasShowed == null) {
    hasShowed = false;
    setShownNoServerConnection(false);
  }
  return hasShowed;
}

Future<void> setShownNoWifiDialog(bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setBool('showedNoWifi', value);
}

Future<void> setShownNoServerConnection(bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setBool('showedNoServerConnection', value);
}

Future<void> setSessionToken(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setString('token', value);
}

Future<BigInt?> getUid(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? dt = prefs.getString('idUser');
  if (dt != null) {
    BigInt? idUser = BigInt.from(int.parse(dt));
    return idUser;
  } else {
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      CustomPageRouter(page: '/login'),
    );
  }
  return null;
}

Future<String?> getToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String? token = prefs.getString('token');
  return token;
}
