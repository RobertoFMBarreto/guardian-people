import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Device/device_data.dart';
import 'package:sqflite/sqflite.dart';

Future<DeviceData> createDeviceData(DeviceData deviceData) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableDeviceData,
    where: '''${DeviceDataFields.deviceId} = ? AND 
              ${DeviceDataFields.accuracy} = ? AND 
              ${DeviceDataFields.battery} = ? AND 
              ${DeviceDataFields.dataUsage} = ? AND 
              ${DeviceDataFields.dateTime} = ? AND 
              ${DeviceDataFields.elevation} = ? AND 
              ${DeviceDataFields.lat} = ? AND 
              ${DeviceDataFields.lon} = ? AND 
              ${DeviceDataFields.state} = ? AND 
              ${DeviceDataFields.temperature} = ?''',
    whereArgs: [
      deviceData.deviceId,
      deviceData.accuracy,
      deviceData.battery,
      deviceData.dataUsage,
      deviceData.dateTime.toIso8601String(),
      deviceData.elevation,
      deviceData.lat,
      deviceData.lon,
      deviceData.state.toString(),
      deviceData.temperature,
    ],
  );
  if (data.isEmpty) {
    await db.insert(tableDeviceData, deviceData.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  return deviceData;
}

Future<List<DeviceData>?> getAllDeviceData(String deviceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableDeviceData,
    where: '${DeviceDataFields.deviceId} = ?',
    whereArgs: [deviceId],
  );

  if (data.isNotEmpty) {
    return data.map((e) => DeviceData.fromJson(e)).toList();
  }
  return null;
}

Future<DeviceData?> getLastDeviceData(String deviceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableDeviceData,
    where: '${DeviceDataFields.deviceId} = ?',
    whereArgs: [deviceId],
    orderBy: '${DeviceDataFields.dateTime} DESC',
  );
  if (data.isNotEmpty) {
    final deviceData = data.map((e) => DeviceData.fromJson(e)).toList();
    if (deviceData.isNotEmpty) {
      return deviceData.first;
    }
  }
  return null;
}

Future<List<DeviceData>> getDeviceData({
  DateTime? startDate,
  DateTime? endDate,
  required String deviceId,
  bool isInterval = false,
}) async {
  final db = await GuardianDatabase().database;
  final data = isInterval && startDate!.difference(endDate!).inSeconds.abs() > 60
      ? await db.query(
          tableDeviceData,
          where: '''${DeviceDataFields.deviceId} = ? AND
                  ${DeviceDataFields.dateTime} >= ? AND 
                  ${DeviceDataFields.dateTime} <= ?''',
          whereArgs: [deviceId, startDate.toIso8601String(), endDate.toIso8601String()],
          orderBy: '${DeviceDataFields.dateTime} DESC',
        )
      : await db.query(
          tableDeviceData,
          where: '${DeviceDataFields.deviceId} = ?',
          whereArgs: [deviceId],
          orderBy: '${DeviceDataFields.dateTime} DESC',
        );

  List<DeviceData> deviceData = [];

  if (data.isNotEmpty) {
    if (isInterval) {
      deviceData.addAll(data.map((e) => DeviceData.fromJson(e)).toList());
    } else {
      deviceData.add(DeviceData.fromJson(data.first));
    }
  }
  return deviceData;
}
