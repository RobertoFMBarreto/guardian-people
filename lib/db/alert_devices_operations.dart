import 'package:guardian/db/device_operations.dart';
import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/db/user_alert_operations.dart';
import 'package:guardian/models/data_models/Alerts/alert_devices.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:sqflite/sqflite.dart';

Future<AlertDevices> addAlertDevice(AlertDevices alertDevice) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableAlertDevices,
    where: '''${AlertDevicesFields.deviceId} = ? AND 
              ${AlertDevicesFields.alertId} = ? ''',
    whereArgs: [
      alertDevice.deviceId,
      alertDevice.deviceId,
    ],
  );
  if (data.isEmpty) {
    await db.insert(
      tableAlertDevices,
      alertDevice.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  return alertDevice;
}

Future<void> removeAlertDevice(String alertId, String deviceId) async {
  final db = await GuardianDatabase().database;
  await db.delete(
    tableAlertDevices,
    where: '${AlertDevicesFields.alertId} = ? AND ${AlertDevicesFields.deviceId} = ?',
    whereArgs: [alertId, deviceId],
  );
}

Future<Device?> getAlertDevice(String alertId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableAlertDevices,
    where: '${AlertDevicesFields.alertId} = ?',
    whereArgs: [alertId],
  );

  if (data.isNotEmpty) {
    final deviceId = AlertDevices.fromJson(data.first).deviceId;
    return await getDevice(deviceId);
  }
  return null;
}

Future<List<UserAlert>> getDeviceAlerts(String deviceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableAlertDevices,
    where: '${AlertDevicesFields.deviceId} = ?',
    whereArgs: [deviceId],
  );
  List<UserAlert> alerts = [];
  print('Alert Devices: $data');

  if (data.isNotEmpty) {
    for (var alertData in data) {
      final alertId = AlertDevices.fromJson(alertData).alertId;
      final alert = await getAlert(alertId);
      if (alert != null) alerts.add(alert);
    }
  }
  return alerts;
}

Future<List<UserAlert>> getDeviceUnselectedAlerts(String deviceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.rawQuery(
    '''
      SELECT 
        $tableUserAlerts.${AlertDevicesFields.alertId}
      FROM $tableUserAlerts
      LEFT JOIN $tableAlertDevices ON $tableAlertDevices.${AlertDevicesFields.alertId} = $tableUserAlerts.${AlertDevicesFields.alertId}
      WHERE $tableAlertDevices.${AlertDevicesFields.alertId} IS NULL
    ''',
  );
  List<UserAlert> alerts = [];

  if (data.isNotEmpty) {
    for (var alertData in data) {
      final alertId = alertData[AlertDevicesFields.alertId] as String;
      final alert = await getAlert(alertId);
      if (alert != null) alerts.add(alert);
    }
  }
  return alerts;
}
