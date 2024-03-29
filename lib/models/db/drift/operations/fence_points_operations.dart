import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

/// Method for creating fence [idFence] points from a list of coordinates [points]
///
/// In case there are already fence points for the [idFence] they are getting removed and added again from the list [points]
Future<void> createFencePointFromList(List<LatLng> points, String idFence) async {
  final db = Get.find<GuardianDb>();

  /// remove all fence [idFence] points so that they dont stack
  await (db.delete(db.fencePoints)..where((tbl) => tbl.idFence.equals(idFence))).go();

  if (points.length == 2) {
    db.fencePoints.insertOnConflictUpdate(
      FencePointsCompanion(
        idFence: drift.Value(idFence),
        idFencePoint: drift.Value(const Uuid().v4()),
        lat: drift.Value(points[0].latitude),
        lon: drift.Value(points[0].longitude),
        isCenter: const drift.Value(true),
      ),
    );
    db.fencePoints.insertOnConflictUpdate(
      FencePointsCompanion(
        idFence: drift.Value(idFence),
        idFencePoint: drift.Value(const Uuid().v4()),
        lat: drift.Value(points[1].latitude),
        lon: drift.Value(points[1].longitude),
        isCenter: const drift.Value(false),
      ),
    );
  } else {
    /// add all received [points]
    await db.batch((batch) {
      batch.insertAll(
        db.fencePoints,
        points.map(
          (e) => FencePointsCompanion(
            idFence: drift.Value(idFence),
            idFencePoint: drift.Value(const Uuid().v4()),
            lat: drift.Value(e.latitude),
            lon: drift.Value(e.longitude),
            isCenter: const drift.Value(false),
          ),
        ),
      );
    });
  }
}

/// Method for creating a fence point [point]
Future<FencePointsCompanion> createFencePoint(FencePointsCompanion point) async {
  final db = Get.find<GuardianDb>();
  db.into(db.fencePoints).insertOnConflictUpdate(point);

  return point;
}

/// Method to get all points [List<LatLng>] from fence [idFence]
Future<List<FencePoint>> getFencePoints(String idFence) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.fencePoints)..where((tbl) => tbl.idFence.equals(idFence))).get();

  return data;
}

/// Method to get all points [List<LatLng>] from fence [idFence]
Future<List<FencePoint>> getOriginalFencePoints(String idFence) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.fencePoints)..where((tbl) => tbl.idFence.equals(idFence))).get();

  return data;
}

/// Method to remove all points from a fence [idFence]
Future<void> removeAllFencePoints(String idFence) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.fencePoints)..where((tbl) => tbl.idFence.equals(idFence))).go();
}
