import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';

Future<UserAlert> createAlert(UserAlert alert) async {
  final db = await GuardianDatabase.instance.database;
  final id = await db.insert(tableUserAlerts, alert.toJson());

  return alert.copy(id: id);
}

Future<int> deleteAlert(String alertId) async {
  final db = await GuardianDatabase.instance.database;
  return db.delete(
    tableUserAlerts,
    where: '${UserAlertFields.id} = ?',
    whereArgs: [alertId],
  );
}
