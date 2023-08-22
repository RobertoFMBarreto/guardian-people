import 'package:flutter/material.dart';
import 'package:guardian/db/device_data_operations.dart';
import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Device/device_data.dart';
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

Future<int> deleteDevice(int id) async {
  final db = await GuardianDatabase().database;

  return db.delete(
    tableDevices,
    where: '${DeviceFields.deviceId} = ?',
    whereArgs: [id],
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

Future<List<Device>> getUserDevices(String uid) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableDevices,
    where: '${DeviceFields.uid} = ?',
    whereArgs: [uid],
  );

  List<Device> devices = [];

  if (data.isNotEmpty) {
    data.map((device) async {
      Device finalDevice = Device.fromJson(device);
      finalDevice.data = await getDeviceData(finalDevice.deviceId);
      devices.add(finalDevice);
    });
  }
  return devices;
}

Future<List<Device>> getUserDevicesWithData(String uid) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableDevices,
    where: '${DeviceFields.uid} = ?',
    whereArgs: [uid],
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
  required String uid,
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
          $tableDevices.${DeviceFields.deviceId},
          ${DeviceFields.imei},
          ${DeviceFields.color},
          ${DeviceFields.name},
          ${DeviceFields.isActive}
        FROM $tableDevices 
        JOIN (
            SELECT 
              ${DeviceDataFields.deviceId},
              ${DeviceDataFields.dataUsage},
              ${DeviceDataFields.temperature},
              ${DeviceDataFields.battery},
              ${DeviceDataFields.lat},
              ${DeviceDataFields.lon},
              ${DeviceDataFields.elevation},
              ${DeviceDataFields.accuracy},
              ${DeviceDataFields.dateTime},
              ${DeviceDataFields.state}
            FROM $tableDeviceData
            ORDER BY ${DeviceDataFields.dateTime} DESC
            LIMIT 1
          ) deviceData ON $tableDevices.${DeviceFields.deviceId} = deviceData.${DeviceDataFields.deviceId}
        WHERE 
          ${DeviceFields.uid} = ? AND
          deviceData.${DeviceDataFields.dataUsage} >= ? AND  deviceData.${DeviceDataFields.dataUsage} <= ? AND
          deviceData.${DeviceDataFields.temperature} >= ? AND deviceData.${DeviceDataFields.temperature} <= ? AND
          deviceData.${DeviceDataFields.battery} >= ? AND deviceData.${DeviceDataFields.battery} <= ? AND
          deviceData.${DeviceDataFields.elevation} >= ? AND deviceData.${DeviceDataFields.elevation} <= ? AND
          (${DeviceFields.name} LIKE ? OR ${DeviceFields.imei} LIKE ?)
    ''',
    [
      uid,
      dtUsageRangeValues.start,
      dtUsageRangeValues.end,
      tmpRangeValues.start,
      tmpRangeValues.end,
      batteryRangeValues.start,
      batteryRangeValues.end,
      elevationRangeValues.start,
      elevationRangeValues.end,
      '%$searchString%',
      '%$searchString%'
    ],
  );

  List<Device> devices = [];
  if (data.isNotEmpty) {
    devices.addAll(
      (data.map((e) async {
        Device device = Device.fromJson(e);
        DeviceData data = DeviceData.fromJson(e);
        device.data = [data];
      }).toList()) as Iterable<Device>,
    );
  }
  return devices;
}
