import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setUserSession(String uid) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // !TODO: Store jwt token
  // await prefs.setString("token", token);
  await prefs.setString("uid", uid);
}

Future<void> clearUserSession() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // remove all session data
  await prefs.clear();
}

Future<bool> hasUserSession() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String? uid = prefs.getString('uid');
  return uid != null;
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

Future<void> setShownNoWifiDialog(bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setBool('showedNoWifi', value);
}

Future<String?> getUid(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String? uid = prefs.getString('uid');
  if (uid != null) {
    return uid;
  } else {
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      CustomPageRouter(page: '/login'),
    );
  }
  return null;
}
