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

Future<UserAlert?> getAlert(String alertId) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableUserAlerts,
    where: '${UserAlertFields.alertId} = ?',
    whereArgs: [alertId],
  );

  if (data.isNotEmpty) {
    return UserAlert.fromJson(data.first);
  }
  return null;
}

Future<UserAlert?> getUserAlerts(String uid) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableUserAlerts,
    where: '${UserAlertFields.uid} = ?',
    whereArgs: [uid],
  );

  if (data.isNotEmpty) {
    return UserAlert.fromJson(data.first);
  }
  return null;
}

Future<List<UserAlert>> getUserDeviceAlerts(String deviceId) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableUserAlerts,
    where: '${UserAlertFields.deviceId} = ?',
    whereArgs: [deviceId],
  );
  List<UserAlert> alerts = [];

  if (data.isNotEmpty) {
    alerts.addAll(data.map((e) => UserAlert.fromJson(e)).toList());
  }
  return alerts;
}
