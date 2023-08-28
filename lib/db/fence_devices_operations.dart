import 'package:guardian/db/device_operations.dart';
import 'package:guardian/db/fence_operations.dart';
import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/data_models/Fences/fence_devices.dart';
import 'package:sqflite/sqflite.dart';

Future<FenceDevices> createFenceDevice(FenceDevices fenceDevice) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableFenceDevices,
    where: '${FenceDevicesFields.deviceId} = ? AND ${FenceDevicesFields.fenceId} = ?',
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
    where: '${FenceDevicesFields.deviceId} = ?',
    whereArgs: [deviceId],
  );
  if (data.isNotEmpty) {
    return await getFence(FenceDevices.fromJson(data.first).fenceId);
  }
  return null;
}

Future<void> removeDeviceFence(String fenceId, String deviceId) async {
  final db = await GuardianDatabase().database;
  await db.delete(
    tableFenceDevices,
    where: '${FenceDevicesFields.fenceId} = ? AND ${FenceDevicesFields.deviceId} = ?',
    whereArgs: [fenceId, deviceId],
  );
}

Future<void> removeAllFenceDevices(String fenceId) async {
  final db = await GuardianDatabase().database;
  await db.delete(
    tableFenceDevices,
    where: '${FenceDevicesFields.fenceId} = ?',
    whereArgs: [fenceId],
  );
}

Future<List<Device>> getFenceDevices(String fenceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableFenceDevices,
    where: '${FenceDevicesFields.fenceId} = ?',
    whereArgs: [fenceId],
  );

  List<Device> fenceDevices = [];

  if (data.isNotEmpty) {
    for (var dev in data) {
      final device = await getDeviceWithData(FenceDevices.fromJson(dev).deviceId);
      if (device != null) {
        fenceDevices.add(device);
      }
    }
  }
  return fenceDevices;
}
