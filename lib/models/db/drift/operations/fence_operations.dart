import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';

Future<FenceCompanion> createFence(FenceCompanion fence) async {
  final db = Get.find<GuardianDb>();
  db.into(db.fence).insertOnConflictUpdate(fence);

  return fence;
}

Future<FenceCompanion> updateFence(FenceCompanion fence) async {
  final db = Get.find<GuardianDb>();
  db.update(db.fence).replace(fence);
  return fence;
}

Future<void> removeFence(FenceCompanion fence) async {
  final db = Get.find<GuardianDb>();
  await removeAllFenceAnimals(fence.idFence.value);
  await removeAllFencePoints(fence.idFence.value);
  (db.delete(db.fence)..where((tbl) => tbl.idFence.equals(fence.idFence.value))).go();
}

Future<FenceData> getFence(BigInt idFence) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.fence)..where((tbl) => tbl.idFence.equals(idFence))).getSingle();
  return data;
}

Future<List<FenceData>> getUserFences() async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.fence)).get();

  return data;
}

Future<List<FenceData>> searchFences(String searchString) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.fence)
        ..where(
          (tbl) => tbl.name.like('%$searchString%'),
        ))
      .get();

  return data;
}
