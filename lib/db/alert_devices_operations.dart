import 'package:guardian/db/device_operations.dart';
import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/db/user_alert_operations.dart';
import 'package:guardian/models/data_models/Alerts/alert_devices.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/data_models/Device/device.dart';

Future<AlertDevices> addAlertDevice(AlertDevices device) async {
  final db = await GuardianDatabase.instance.database;
  final id = await db.insert(tableAlertDevices, device.toJson());

  return device.copy(id: id);
}

Future<Device?> getAlertDevice(String alertId) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableAlertDevices,
    where: '${UserAlertFields.alertId} = ?',
    whereArgs: [alertId],
  );

  if (data.isNotEmpty) {
    final deviceId = AlertDevices.fromJson(data.first).deviceId;
    return await getDevice(deviceId);
  }
  return null;
}

Future<List<UserAlert>> getDeviceAlerts(String deviceId) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableAlertDevices,
    where: '${UserAlertFields.deviceId} = ?',
    whereArgs: [deviceId],
  );

  List<UserAlert> alerts = [];

  if (data.isNotEmpty) {
    alerts.addAll(data.map((e) async {
      final alertId = AlertDevices.fromJson(e).alertId;
      return await getAlert(alertId);
    }) as Iterable<UserAlert>);
  }
  return alerts;
}
