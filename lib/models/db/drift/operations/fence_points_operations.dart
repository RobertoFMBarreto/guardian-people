import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:latlong2/latlong.dart';

Future<void> createFencePointFromList(List<LatLng> points, BigInt idFence) async {
  final db = Get.find<GuardianDb>();
  final dt = await (db.select(db.fencePoints)..where((tbl) => tbl.idFence.equals(idFence))).get();
  print(dt);
  print(dt.length);
  // first remove all points

  (db.delete(db.fencePoints)..where((tbl) => tbl.idFence.equals(idFence))).go();

  final dt2 = await (db.select(db.fencePoints)..where((tbl) => tbl.idFence.equals(idFence))).get();
  print(dt2);
  print(dt2.length);
  // second add all points again
  await db.batch((batch) {
    batch.insertAll(
      db.fencePoints,
      points.map(
        (e) => FencePointsCompanion(
          idFence: drift.Value(idFence),
          lat: drift.Value(e.latitude),
          lon: drift.Value(e.longitude),
        ),
      ),
    );
  });
}

Future<FencePointsCompanion> createFencePoint(FencePointsCompanion point) async {
  final db = Get.find<GuardianDb>();
  db.into(db.fencePoints).insertOnConflictUpdate(point);

  return point;
}

Future<List<LatLng>> getFencePoints(BigInt idFence) async {
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

Future<void> removeAllFencePoints(BigInt idFence) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.fencePoints)..where((tbl) => tbl.idFence.equals(idFence))).go();
}
