import 'package:guardian/models/db/data_models/Alerts/alert_devices.dart';
import 'package:guardian/models/db/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/data_models/Device/device_data.dart';
import 'package:guardian/models/db/guardian_database.dart';
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
  final data = await db.rawQuery(
    '''
      SELECT 
        *
      FROM $tableAlertDevices
      LEFT JOIN $tableUserAlerts ON $tableUserAlerts.${UserAlertFields.alertId} = $tableAlertDevices.${AlertDeviceFields.alertId}
      LEFT JOIN $tableDevices ON $tableDevices.${DeviceFields.deviceId} = $tableAlertDevices.${AlertDeviceFields.deviceId}
      LEFT JOIN (
        SELECT * FROM 
          (
            SELECT * FROM $tableDeviceData
            ORDER BY ${DeviceDataFields.dateTime} DESC 
          ) as deviceDt
        GROUP BY deviceDt.${DeviceDataFields.deviceId}
      ) deviceData ON $tableDevices.${DeviceFields.deviceId} = deviceData.${DeviceDataFields.deviceId}
      WHERE $tableAlertDevices.${AlertDeviceFields.alertId} = ?
    ''',
    [alertId],
  );

  List<Device> devices = [];

  if (data.isNotEmpty) {
    for (var alertData in data) {
      Device device = Device.fromJson(alertData);
      DeviceData? lastDeviceData;
      if (alertData.containsKey(DeviceDataFields.battery)) {
        lastDeviceData = DeviceData.fromJson(alertData);
      }
      List<DeviceData> deviceData = lastDeviceData != null ? [lastDeviceData] : [];
      device.data = deviceData;
      devices.add(device);
    }
  }
  return devices;
}

Future<List<UserAlert>> getDeviceAlerts(String deviceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.rawQuery(
    '''
      SELECT 
        *
      FROM $tableAlertDevices
      JOIN $tableUserAlerts ON $tableUserAlerts.${UserAlertFields.alertId} = $tableAlertDevices.${AlertDeviceFields.alertId}
      WHERE $tableAlertDevices.${AlertDeviceFields.deviceId} = ?
    ''',
    [deviceId],
  );
  List<UserAlert> alerts = [];

  if (data.isNotEmpty) {
    for (var alertData in data) {
      final alert = UserAlert.fromJson(alertData);
      alerts.add(alert);
    }
  }
  return alerts;
}

Future<List<UserAlert>> getDeviceUnselectedAlerts() async {
  final db = await GuardianDatabase().database;
  final data = await db.rawQuery(
    '''
      SELECT 
        *
      FROM $tableAlertDevices
      LEFT JOIN $tableUserAlerts ON $tableUserAlerts.${UserAlertFields.alertId} = $tableAlertDevices.${AlertDeviceFields.alertId}
      WHERE $tableAlertDevices.${AlertDeviceFields.deviceId} IS NULL
    ''',
  );
  List<UserAlert> alerts = [];

  if (data.isNotEmpty) {
    for (var alertData in data) {
      final alert = UserAlert.fromJson(alertData);
      alerts.add(alert);
    }
  }
  return alerts;
}
