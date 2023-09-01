import 'package:guardian/models/db/data_models/Alerts/alert_devices.dart';
import 'package:guardian/models/db/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/data_models/Device/device_data.dart';
import 'package:guardian/models/db/operations/device_data_operations.dart';
import 'package:guardian/models/db/operations/device_operations.dart';
import 'package:guardian/models/db/operations/guardian_database.dart';
import 'package:guardian/models/db/operations/user_alert_operations.dart';
import 'package:sqflite/sqflite.dart';

Future<AlertDevice> addAlertDevice(AlertDevice alertDevice) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableAlertDevices,
    where: '''${AlertDeviceFields.deviceId} = ? AND 
              ${AlertDeviceFields.alertId} = ? ''',
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

Future<void> removeAllAlertDevices(String alertId) async {
  final db = await GuardianDatabase().database;
  await db.delete(
    tableAlertDevices,
    where: '${AlertDeviceFields.alertId} = ? ',
    whereArgs: [alertId],
  );
}

Future<void> removeAlertDevice(String alertId, String deviceId) async {
  final db = await GuardianDatabase().database;
  await db.delete(
    tableAlertDevices,
    where: '${AlertDeviceFields.alertId} = ? AND ${AlertDeviceFields.deviceId} = ?',
    whereArgs: [alertId, deviceId],
  );
}

Future<List<Device>> getAlertDevices(String alertId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableAlertDevices,
    where: '${AlertDeviceFields.alertId} = ?',
    whereArgs: [alertId],
  );

  List<Device> devices = [];

  if (data.isNotEmpty) {
    for (var alertData in data) {
      final deviceId = AlertDevice.fromJson(alertData).deviceId;
      Device? device = await getDevice(deviceId);
      if (device != null) {
        final lastDeviceData = await getLastDeviceData(deviceId);
        List<DeviceData> deviceData = lastDeviceData != null ? [lastDeviceData] : [];
        device.data = deviceData;
        devices.add(device);
      }
    }
  }
  return devices;
}

Future<List<UserAlert>> getDeviceAlerts(String deviceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableAlertDevices,
    where: '${AlertDeviceFields.deviceId} = ?',
    whereArgs: [deviceId],
  );
  List<UserAlert> alerts = [];

  if (data.isNotEmpty) {
    for (var alertData in data) {
      final alertId = AlertDevice.fromJson(alertData).alertId;
      final alert = await getAlert(alertId);
      if (alert != null) alerts.add(alert);
    }
  }
  return alerts;
}

Future<List<UserAlert>> getDeviceUnselectedAlerts() async {
  final db = await GuardianDatabase().database;
  final data = await db.rawQuery(
    '''
      SELECT 
        $tableUserAlerts.${AlertDeviceFields.alertId}
      FROM $tableUserAlerts
      LEFT JOIN $tableAlertDevices ON $tableAlertDevices.${AlertDeviceFields.alertId} = $tableUserAlerts.${AlertDeviceFields.alertId}
      WHERE $tableAlertDevices.${AlertDeviceFields.deviceId} IS NULL
    ''',
  );
  List<UserAlert> alerts = [];

  if (data.isNotEmpty) {
    for (var alertData in data) {
      final alertId = alertData[AlertDeviceFields.alertId] as String;
      final alert = await getAlert(alertId);
      if (alert != null) alerts.add(alert);
    }
  }
  return alerts;
}
