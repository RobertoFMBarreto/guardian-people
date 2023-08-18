import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Device/device_data.dart';

Future<DeviceData> createDeviceData(DeviceData deviceData) async {
  final db = await GuardianDatabase.instance.database;
  final id = await db.insert(tableDeviceData, deviceData.toJson());

  return deviceData.copy(id: id);
}

Future<List<DeviceData>?> getDeviceData(String deviceId) async {
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
