import 'package:guardian/db/fence_operations.dart';
import 'package:guardian/db/guardian_database.dart';
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
