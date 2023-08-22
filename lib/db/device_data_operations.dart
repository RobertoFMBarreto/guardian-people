import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Device/device_data.dart';

Future<DeviceData> createDeviceData(DeviceData deviceData) async {
  final db = await GuardianDatabase.instance.database;
  final id = await db.insert(tableDeviceData, deviceData.toJson());

  return deviceData.copy(id: id);
}

Future<List<DeviceData>?> getAllDeviceData(String deviceId) async {
  final db = await GuardianDatabase.instance.database;
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
  final db = await GuardianDatabase.instance.database;
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

Future<List<DeviceData>> getDeviceData(String deviceId) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableDeviceData,
    where: '${DeviceDataFields.deviceId} = ?',
    whereArgs: [deviceId],
    orderBy: '${DeviceDataFields.dateTime} DESC',
  );

  List<DeviceData> deviceData = [];

  if (data.isNotEmpty) {
    if (deviceData.isNotEmpty) {
      deviceData.addAll(data.map((e) => DeviceData.fromJson(e)).toList());
    }
  }
  return deviceData;
}
