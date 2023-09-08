import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/admin/admin_users_operations.dart';
import 'package:guardian/models/helpers/navigator_key_helper.dart';
import 'package:guardian/models/providers/session_provider.dart';

Future<UserData?> getSessionUserData() async {
  return await getUid(navigatorKey.currentContext!).then((uid) {
    if (uid != null) {
      return getProducer(uid).then((userData) {
        return userData;
      });
    }
    return null;
  });
}
