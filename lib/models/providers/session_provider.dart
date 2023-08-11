import 'package:shared_preferences/shared_preferences.dart';

Future<void> setUserSession(String uid, int role) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // !TODO: Store jwt token
  // await prefs.setString("token", token);
  await prefs.setString("uid", uid);
  await prefs.setInt("role", role);
}

Future<void> clearUserSession() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // remove all session data
  await prefs.clear();

  //!TODO call logout service
}

Future<int?> hasUserSession() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  int? role = prefs.getInt('role');
  return role;
}

Future<int?> getSessionRole() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  int? role = prefs.getInt('role');
  return role;
}
