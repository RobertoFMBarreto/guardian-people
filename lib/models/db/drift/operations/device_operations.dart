import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

Future<DeviceCompanion> createDevice(
  DeviceCompanion device,
) async {
  final db = Get.find<GuardianDb>();
  await db.into(db.device).insertOnConflictUpdate(device);
  return device;
}

Future<void> deleteDevice(BigInt idDevice) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.device)..where((tbl) => tbl.idDevice.equals(idDevice))).go();
}

Future<DeviceCompanion> updateDevice(DeviceCompanion device) async {
  final db = Get.find<GuardianDb>();
  db.update(db.device).replace(device);

  return device;
}
