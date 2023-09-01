import 'package:guardian/models/db/data_models/user.dart';
import 'package:guardian/models/db/operations/user_operations.dart';
import 'package:guardian/models/helpers/navigator_key_helper.dart';
import 'package:guardian/models/providers/session_provider.dart';

Future<User?> getSessionUserData() async {
  return await getUid(navigatorKey.currentContext!).then((uid) {
    if (uid != null) {
      return getUser(uid).then((userData) {
        if (userData != null) {
          return userData;
        }
        return null;
      });
    }
    return null;
  });
}
