import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:sqflite/sqflite.dart';

Future<UserAlert> createAlert(UserAlert alert) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableUserAlerts,
    where: '''
              ${UserAlertFields.alertId} = ? AND 
              ${UserAlertFields.comparisson} = ? AND 
              ${UserAlertFields.hasNotification} = ? AND 
              ${UserAlertFields.parameter} = ? AND 
              ${UserAlertFields.value} = ? 
          ''',
    whereArgs: [
      alert.alertId,
      alert.comparisson.toString(),
      alert.hasNotification ? 1 : 0,
      alert.parameter.toString(),
      alert.value,
    ],
  );

  if (data.isEmpty) {
    await db.insert(
      tableUserAlerts,
      alert.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  return alert;
}

Future<UserAlert> updateUserAlert(UserAlert alert) async {
  final db = await GuardianDatabase().database;
  await db.update(
    tableUserAlerts,
    alert.toJson(),
    where: '${UserAlertFields.alertId} = ?',
    whereArgs: [alert.alertId],
  );

  return alert;
}

Future<int> deleteAlert(String alertId) async {
  final db = await GuardianDatabase().database;
  return db.delete(
    tableUserAlerts,
    where: '${UserAlertFields.alertId} = ?',
    whereArgs: [alertId],
  );
}

Future<int> deleteAllAlerts() async {
  final db = await GuardianDatabase().database;
  return db.delete(
    tableUserAlerts,
  );
}

Future<UserAlert?> getAlert(String alertId) async {
  final db = await GuardianDatabase().database;
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

Future<List<UserAlert>> getUserAlerts(String uid) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableUserAlerts,
  );
  List<UserAlert> alerts = [];
  if (data.isNotEmpty) {
    alerts.addAll(data.map((e) => UserAlert.fromJson(e)).toList());
  }
  return alerts;
}

Future<List<UserAlert>> getUserDeviceAlerts(String deviceId) async {
  final db = await GuardianDatabase().database;
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
