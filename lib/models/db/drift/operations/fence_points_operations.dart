import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:latlong2/latlong.dart';

/// Method for creating fence [idFence] points from a list of coordinates [points]
///
/// In case there are already fence points for the [idFence] they are getting removed and added again from the list [points]
Future<void> createFencePointFromList(List<LatLng> points, String idFence) async {
  final db = Get.find<GuardianDb>();

  /// remove all fence [idFence] points so that they dont stack
  (db.delete(db.fencePoints)..where((tbl) => tbl.idFence.equals(idFence))).go();

  if (points.length == 2) {
    db.fencePoints.insertOnConflictUpdate(
      FencePointsCompanion(
        idFence: drift.Value(idFence),
        lat: drift.Value(points[0].latitude),
        lon: drift.Value(points[0].longitude),
        isCenter: const drift.Value(true),
      ),
    );
    db.fencePoints.insertOnConflictUpdate(
      FencePointsCompanion(
        idFence: drift.Value(idFence),
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
Future<List<LatLng>> getFencePoints(String idFence) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.fencePoints)..where((tbl) => tbl.idFence.equals(idFence))).get();

  List<LatLng> fencePoints = [];
  fencePoints.addAll(
    data.map((e) {
      return LatLng(e.lat, e.lon);
    }).toList(),
  );

  return fencePoints;
}

/// Method to remove all points from a fence [idFence]
Future<void> removeAllFencePoints(String idFence) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.fencePoints)..where((tbl) => tbl.idFence.equals(idFence))).go();
}
