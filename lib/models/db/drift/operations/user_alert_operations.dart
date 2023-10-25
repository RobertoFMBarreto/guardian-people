import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';

/// Method for creating an user created alert [alert] returning an [UserAlertCompanion]
Future<UserAlertCompanion> createAlert(UserAlertCompanion alert) async {
  final db = Get.find<GuardianDb>();

  db.into(db.userAlert).insertOnConflictUpdate(alert);
  return alert;
}

/// Method for updating an user created alert [alert] returning an [UserAlertCompanion]
Future<UserAlertCompanion> updateUserAlert(UserAlertCompanion alert) async {
  final db = Get.find<GuardianDb>();
  db.update(db.userAlert).replace(alert);

  return alert;
}

/// Method for deleting an user created alert [idAlert]
///
/// This process removes all associated animals from the alert
Future<void> deleteAlert(String idAlert) async {
  final db = Get.find<GuardianDb>();
  await removeAllAlertAnimals(idAlert);
  (db.delete(db.userAlert)..where((tbl) => tbl.idAlert.equals(idAlert))).go();
}

/// Method for deleting all user created alerts
Future<void> deleteAllAlerts() async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.userAlert)).go();
}

/// Method to get a user created alert [idAlert] information [UserAlertData]
Future<UserAlertData> getAlert(String idAlert) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.userAlert)
        ..where(
          (tbl) => tbl.idAlert.equals(idAlert),
        ))
      .getSingle();
  return data;
}

/// Method to get all user created alerts [List<UserAlertCompanion>]
Future<List<UserAlertCompanion>> getUserAlerts() async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.userAlert)).get();
  return data.map((e) => e.toCompanion(true)).toList();
}
