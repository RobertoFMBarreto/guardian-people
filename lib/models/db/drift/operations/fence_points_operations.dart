import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:latlong2/latlong.dart';

Future<void> createFencePointFromList(List<LatLng> points, String fenceId) async {
  final db = Get.find<GuardianDb>();
  // first remove all points
  db.delete(db.fencePoints).where((tbl) => tbl.fenceId.equals(fenceId));
  // second add all points again
  await db.batch((batch) {
    batch.insertAll(
      db.fencePoints,
      points.map(
        (e) => FencePointsCompanion(
          fenceId: drift.Value(fenceId),
          lat: drift.Value(e.latitude),
          lon: drift.Value(e.longitude),
        ),
      ),
    );
  });
}

Future<FencePointsCompanion> createFencePoint(FencePointsCompanion point) async {
  final db = Get.find<GuardianDb>();
  db.into(db.fencePoints).insert(point);

  return point;
}

Future<List<LatLng>> getFencePoints(String fenceId) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.fencePoints)..where((tbl) => tbl.fenceId.equals(fenceId))).get();

  List<LatLng> fencePoints = [];
  fencePoints.addAll(
    data.map((e) {
      return LatLng(e.lat, e.lon);
    }).toList(),
  );

  return fencePoints;
}

Future<void> removeAllFencePoints(String fenceId) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.fencePoints)..where((tbl) => tbl.fenceId.equals(fenceId))).go();
}
