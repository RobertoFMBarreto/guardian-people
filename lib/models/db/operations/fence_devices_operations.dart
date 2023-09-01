import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/data_models/Fences/fence.dart';
import 'package:guardian/models/db/data_models/Fences/fence_devices.dart';
import 'package:guardian/models/db/operations/device_operations.dart';
import 'package:guardian/models/db/operations/fence_operations.dart';
import 'package:guardian/models/db/operations/guardian_database.dart';
import 'package:sqflite/sqflite.dart';

Future<FenceDevice> createFenceDevice(FenceDevice fenceDevice) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableFenceDevices,
    where: '${FenceDeviceFields.deviceId} = ? AND ${FenceDeviceFields.fenceId} = ?',
    whereArgs: [fenceDevice.deviceId, fenceDevice.fenceId],
  );
  if (data.isEmpty) {
    await db.insert(
      tableFenceDevices,
      fenceDevice.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  return fenceDevice;
}

Future<Fence?> getDeviceFence(String deviceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableFenceDevices,
    where: '${FenceDeviceFields.deviceId} = ?',
    whereArgs: [deviceId],
  );
  if (data.isNotEmpty) {
    return await getFence(FenceDevice.fromJson(data.first).fenceId);
  }
  return null;
}

Future<void> removeDeviceFence(String fenceId, String deviceId) async {
  final db = await GuardianDatabase().database;
  await db.delete(
    tableFenceDevices,
    where: '${FenceDeviceFields.fenceId} = ? AND ${FenceDeviceFields.deviceId} = ?',
    whereArgs: [fenceId, deviceId],
  );
}

Future<void> removeAllFenceDevices(String fenceId) async {
  final db = await GuardianDatabase().database;
  await db.delete(
    tableFenceDevices,
    where: '${FenceDeviceFields.fenceId} = ?',
    whereArgs: [fenceId],
  );
}

Future<List<Device>> getFenceDevices(String fenceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableFenceDevices,
    where: '${FenceDeviceFields.fenceId} = ?',
    whereArgs: [fenceId],
  );

  List<Device> fenceDevices = [];

  if (data.isNotEmpty) {
    for (var dev in data) {
      final device = await getDeviceWithData(FenceDevice.fromJson(dev).deviceId);
      if (device != null) {
        fenceDevices.add(device);
      }
    }
  }
  return fenceDevices;
}
