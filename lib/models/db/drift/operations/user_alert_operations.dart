import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';

Future<UserAlertCompanion> createAlert(UserAlertCompanion alert) async {
  final db = Get.find<GuardianDb>();

  db.into(db.userAlert).insertOnConflictUpdate(alert);
  return alert;
}

Future<UserAlertCompanion> updateUserAlert(UserAlertCompanion alert) async {
  final db = Get.find<GuardianDb>();
  db.update(db.userAlert).replace(alert);

  return alert;
}

Future<void> deleteAlert(String alertId) async {
  final db = Get.find<GuardianDb>();
  await removeAllAlertDevices(alertId);
  (db.delete(db.userAlert)..where((tbl) => tbl.alertId.equals(alertId))).go();
}

Future<void> deleteAllAlerts() async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.userAlert)).go();
}

Future<UserAlertData> getAlert(String alertId) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.userAlert)
        ..where(
          (tbl) => tbl.alertId.equals(alertId),
        ))
      .getSingle();
  return data;
}

Future<List<UserAlertCompanion>> getUserAlerts() async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.userAlert)).get();
  return data.map((e) => e.toCompanion(true)).toList();
}
