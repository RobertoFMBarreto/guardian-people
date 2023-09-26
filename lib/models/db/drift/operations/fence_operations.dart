import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';

/// Method for creating a fence [fence] returning it as a [FenceCompanion]
Future<FenceCompanion> createFence(FenceCompanion fence) async {
  final db = Get.find<GuardianDb>();
  db.into(db.fence).insertOnConflictUpdate(fence);

  return fence;
}

/// Method for updating a fence [fence] returning it as a [FenceCompanion]
Future<FenceCompanion> updateFence(FenceCompanion fence) async {
  final db = Get.find<GuardianDb>();
  db.update(db.fence).replace(fence);
  return fence;
}

/// Method to remove a fence [idFence]
Future<void> removeFence(BigInt idFence) async {
  final db = Get.find<GuardianDb>();
  await removeAllFenceAnimals(idFence);
  await removeAllFencePoints(idFence);
  (db.delete(db.fence)..where((tbl) => tbl.idFence.equals(idFence))).go();
}

/// Method to get a fence [idFence] as [FenceData]
Future<FenceData> getFence(BigInt idFence) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.fence)..where((tbl) => tbl.idFence.equals(idFence))).getSingle();
  return data;
}

/// Method to get all user fences [List<FenceData>]
Future<List<FenceData>> getUserFences() async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.fence)).get();

  return data;
}

/// Method to search fences by a [searchString]
Future<List<FenceData>> searchFences(String searchString) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.fence)
        ..where(
          (tbl) => tbl.name.like('%$searchString%'),
        ))
      .get();

  return data;
}
