import 'package:flutter/material.dart';
import 'package:guardian/models/db/data_models/Alerts/alert_devices.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/data_models/Device/device_data.dart';
import 'package:guardian/models/db/data_models/Fences/fence_devices.dart';
import 'package:guardian/models/db/operations/device_data_operations.dart';
import 'package:guardian/models/db/guardian_database.dart';
import 'package:sqflite/sqflite.dart';

Future<Device> createDevice(Device device) async {
  final db = await GuardianDatabase().database;
  final id = await db.insert(
    tableDevices,
    device.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  return device.copy(id: id);
}

Future<int> deleteDevice(String deviceId) async {
  final db = await GuardianDatabase().database;

  return db.delete(
    tableDevices,
    where: '${DeviceFields.deviceId} = ?',
    whereArgs: [deviceId],
  );
}

Future<Device> updateDevice(Device device) async {
  final db = await GuardianDatabase().database;
  final id = await db.update(
    tableDevices,
    device.toJson(),
    where: '${DeviceFields.deviceId} = ?',
    whereArgs: [device.deviceId],
  );

  return device.copy(id: id);
}

Future<Device?> getDevice(String deviceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableDevices,
    where: '${DeviceFields.deviceId} = ?',
    whereArgs: [deviceId],
  );

  if (data.isNotEmpty) {
    return Device.fromJson(data.first);
  }
  return null;
}

Future<Device?> getDeviceWithData(String deviceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableDevices,
    where: '${DeviceFields.deviceId} = ?',
    whereArgs: [deviceId],
    orderBy: DeviceFields.name,
  );

  if (data.isNotEmpty) {
    Device device = Device.fromJson(data.first);
    device.data = [(await getLastDeviceData(device.deviceId)) as DeviceData];
    return device;
  }
  return null;
}

Future<List<Device>> getUserDevices() async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableDevices,
    orderBy: DeviceFields.name,
  );

  List<Device> devices = [];

  if (data.isNotEmpty) {
    for (var device in data) {
      Device finalDevice = Device.fromJson(device);
      finalDevice.data = await getDeviceData(deviceId: finalDevice.deviceId);
      devices.add(finalDevice);
    }
  }
  return devices;
}

Future<List<Device>> getUserDevicesWithData() async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableDevices,
    orderBy: DeviceFields.name,
  );

  List<Device> devices = [];

  if (data.isNotEmpty) {
    for (var deviceData in data) {
      Device device = Device.fromJson(deviceData);
      device.data = [(await getLastDeviceData(device.deviceId)) as DeviceData];
      if (device.data!.isNotEmpty) devices.add(device);
    }
  }

  return devices;
}

Future<List<Device>> getUserDevicesFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
}) async {
  final db = await GuardianDatabase().database;
  final data = await db.rawQuery(
    '''
      SELECT
        ${DeviceFields.uid},
        ${DeviceFields.imei},
        ${DeviceFields.color},
        ${DeviceFields.name},
        ${DeviceFields.isActive},
        ${DeviceDataFields.dataUsage},
        ${DeviceDataFields.temperature},
        ${DeviceDataFields.battery},
        ${DeviceDataFields.lat},
        ${DeviceDataFields.lon},
        ${DeviceDataFields.elevation},
        ${DeviceDataFields.accuracy},
        ${DeviceDataFields.dateTime},
        ${DeviceDataFields.state},
        $tableDevices.${DeviceFields.deviceId}
      FROM $tableDevices
      LEFT JOIN (
        SELECT * FROM 
          (
            SELECT * FROM $tableDeviceData
            ORDER BY ${DeviceDataFields.dateTime} DESC 
          ) as deviceDt
        GROUP BY deviceDt.${DeviceDataFields.deviceId}
      ) deviceData ON $tableDevices.${DeviceFields.deviceId} = deviceData.${DeviceDataFields.deviceId}
      WHERE
        (deviceData.${DeviceDataFields.dataUsage} >= ? AND  deviceData.${DeviceDataFields.dataUsage} <= ? AND
        deviceData.${DeviceDataFields.temperature} >= ? AND deviceData.${DeviceDataFields.temperature} <= ? AND
        deviceData.${DeviceDataFields.battery} >= ? AND deviceData.${DeviceDataFields.battery} <= ? AND
        deviceData.${DeviceDataFields.elevation} >= ? AND deviceData.${DeviceDataFields.elevation} <= ? AND
        ${DeviceFields.name} LIKE ?) OR (${DeviceFields.name} LIKE ? AND deviceData.${DeviceDataFields.temperature} IS NULL)
      ORDER BY
        ${DeviceFields.name}
    ''',
    [
      dtUsageRangeValues.start,
      dtUsageRangeValues.end,
      tmpRangeValues.start,
      tmpRangeValues.end,
      batteryRangeValues.start,
      batteryRangeValues.end,
      elevationRangeValues.start,
      elevationRangeValues.end,
      '%$searchString%',
      '%$searchString%',
    ],
  );
  List<Device> devices = [];
  if (data.isNotEmpty) {
    for (var dt in data) {
      Device device = Device.fromJson(dt);
      // if there is device data
      if (dt['temperature'] != null) {
        DeviceData data = DeviceData.fromJson(dt);
        device.data = [data];
      }
      devices.add(device);
    }
  }
  return devices;
}

Future<double> getMaxElevation() async {
  final db = await GuardianDatabase().database;
  final data = await db.rawQuery('''
      SELECT IFNULL(MAX(${DeviceDataFields.elevation}),0) AS maxElevation FROM $tableDevices
      LEFT JOIN $tableDeviceData ON $tableDeviceData.${DeviceDataFields.deviceId} = $tableDevices.${DeviceFields.deviceId}
    ''');
  return data.first['maxElevation'] as double;
}

Future<double> getMaxTemperature() async {
  final db = await GuardianDatabase().database;
  final data = await db.rawQuery('''
      SELECT IFNULL(MAX(${DeviceDataFields.temperature}),0) AS maxTemperature FROM $tableDevices
      LEFT JOIN $tableDeviceData ON $tableDeviceData.${DeviceDataFields.deviceId} = $tableDevices.${DeviceFields.deviceId}
    ''');
  return data.first['maxTemperature'] as double;
}

Future<List<Device>> getUserFenceUnselectedDevicesFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
  required String fenceId,
}) async {
  final db = await GuardianDatabase().database;
  final data = await db.rawQuery(
    '''
      SELECT
        ${DeviceFields.uid},
        ${DeviceFields.imei},
        ${DeviceFields.color},
        ${DeviceFields.name},
        ${DeviceFields.isActive},
        ${DeviceDataFields.dataUsage},
        ${DeviceDataFields.temperature},
        ${DeviceDataFields.battery},
        ${DeviceDataFields.lat},
        ${DeviceDataFields.lon},
        ${DeviceDataFields.elevation},
        ${DeviceDataFields.accuracy},
        ${DeviceDataFields.dateTime},
        ${DeviceDataFields.state},
        $tableDevices.${DeviceFields.deviceId}
      FROM $tableDevices
      LEFT JOIN (
        SELECT * FROM 
          (
            SELECT * FROM $tableDeviceData
            ORDER BY ${DeviceDataFields.dateTime} DESC 
          ) as deviceDt
        GROUP BY deviceDt.${DeviceDataFields.deviceId}
      ) deviceData ON $tableDevices.${DeviceFields.deviceId} = deviceData.${DeviceDataFields.deviceId}
      WHERE
        deviceData.${DeviceDataFields.dataUsage} >= ? AND  deviceData.${DeviceDataFields.dataUsage} <= ? AND
        deviceData.${DeviceDataFields.temperature} >= ? AND deviceData.${DeviceDataFields.temperature} <= ? AND
        deviceData.${DeviceDataFields.battery} >= ? AND deviceData.${DeviceDataFields.battery} <= ? AND
        deviceData.${DeviceDataFields.elevation} >= ? AND deviceData.${DeviceDataFields.elevation} <= ? AND
        ${DeviceFields.name} LIKE ? AND $tableDevices.${DeviceFields.deviceId} NOT IN (SELECT ${DeviceFields.deviceId} FROM $tableFenceDevices)
      ORDER BY
        ${DeviceFields.name}
    ''',
    [
      dtUsageRangeValues.start,
      dtUsageRangeValues.end,
      tmpRangeValues.start,
      tmpRangeValues.end,
      batteryRangeValues.start,
      batteryRangeValues.end,
      elevationRangeValues.start,
      elevationRangeValues.end,
      '%$searchString%',
    ],
  );

  List<Device> devices = [];
  if (data.isNotEmpty) {
    for (var dt in data) {
      Device device = Device.fromJson(dt);
      DeviceData data = DeviceData.fromJson(dt);
      device.data = [data];
      devices.add(device);
    }
  }
  return devices;
}

Future<List<Device>> getUserAlertUnselectedDevicesFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
  required String alertId,
}) async {
  final db = await GuardianDatabase().database;

  // !TODO: se poder ter várias fences adicionar denovo
  // $tableDevices.${DeviceFields.deviceId} NOT IN (SELECT ${DeviceFields.deviceId} FROM $tableFenceDevices WHERE ${FenceDevicesFields.fenceId} = ?)

  final data = await db.rawQuery(
    '''
      SELECT
        ${DeviceFields.uid},
        ${DeviceFields.imei},
        ${DeviceFields.color},
        ${DeviceFields.name},
        ${DeviceFields.isActive},
        ${DeviceDataFields.dataUsage},
        ${DeviceDataFields.temperature},
        ${DeviceDataFields.battery},
        ${DeviceDataFields.lat},
        ${DeviceDataFields.lon},
        ${DeviceDataFields.elevation},
        ${DeviceDataFields.accuracy},
        ${DeviceDataFields.dateTime},
        ${DeviceDataFields.state},
        $tableDevices.${DeviceFields.deviceId}
      FROM $tableDevices
      LEFT JOIN (
        SELECT * FROM 
          (
            SELECT * FROM $tableDeviceData
            ORDER BY ${DeviceDataFields.dateTime} DESC 
          ) as deviceDt
        GROUP BY deviceDt.${DeviceDataFields.deviceId}
      ) deviceData ON $tableDevices.${DeviceFields.deviceId} = deviceData.${DeviceDataFields.deviceId}
      WHERE
        deviceData.${DeviceDataFields.dataUsage} >= ? AND  deviceData.${DeviceDataFields.dataUsage} <= ? AND
        deviceData.${DeviceDataFields.temperature} >= ? AND deviceData.${DeviceDataFields.temperature} <= ? AND
        deviceData.${DeviceDataFields.battery} >= ? AND deviceData.${DeviceDataFields.battery} <= ? AND
        deviceData.${DeviceDataFields.elevation} >= ? AND deviceData.${DeviceDataFields.elevation} <= ? AND
        ${DeviceFields.name} LIKE ? AND $tableDevices.${DeviceFields.deviceId} NOT IN (SELECT ${DeviceFields.deviceId} FROM $tableAlertDevices)
      ORDER BY
        ${DeviceFields.name}
    ''',
    [
      dtUsageRangeValues.start,
      dtUsageRangeValues.end,
      tmpRangeValues.start,
      tmpRangeValues.end,
      batteryRangeValues.start,
      batteryRangeValues.end,
      elevationRangeValues.start,
      elevationRangeValues.end,
      '%$searchString%',
    ],
  );

  List<Device> devices = [];
  if (data.isNotEmpty) {
    for (var dt in data) {
      Device device = Device.fromJson(dt);
      DeviceData data = DeviceData.fromJson(dt);
      device.data = [data];
      devices.add(device);
    }
  }
  return devices;
}
