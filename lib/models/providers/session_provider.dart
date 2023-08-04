import 'package:shared_preferences/shared_preferences.dart';

Future<void> setUserSession(int uid, int role) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // !TODO: Store jwt token
  // await prefs.setString("token", token);
  await prefs.setInt("uid", uid);
  await prefs.setInt("role", role);
}
