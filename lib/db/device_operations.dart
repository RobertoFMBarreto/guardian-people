import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Device/device.dart';

Future<Device> createDevice(Device user) async {
  final db = await GuardianDatabase.instance.database;
  final id = await db.insert(tableDevices, user.toJson());

  return user.copy(id: id);
}

Future<int> deleteDevice(int id) async {
  final db = await GuardianDatabase.instance.database;

  return db.delete(
    tableDevices,
    where: '${DeviceFields.id} = ?',
    whereArgs: [id],
  );
}

Future<Device> updateDevice(Device device) async {
  final db = await GuardianDatabase.instance.database;
  final id = await db.update(
    tableDevices,
    device.toJson(),
    where: '${DeviceFields.id} = ?',
    whereArgs: [device.id],
  );

  return device.copy(id: id);
}

Future<Device?> getDevice(String deviceId) async {
  final db = await GuardianDatabase.instance.database;
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
