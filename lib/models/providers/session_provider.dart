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

  //!TODO call logout service
}

Future<bool> hasUserSession() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String? uid = prefs.getString('uid');
  return uid != null;
}
