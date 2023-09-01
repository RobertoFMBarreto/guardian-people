import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Fences/fence_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';

Future<void> createFencePointFromList(List<LatLng> points, String fenceId) async {
  final db = await GuardianDatabase().database;
  // first remove all points
  await db.delete(
    tableFencePoints,
    where: '${FencePointFields.fenceId} = ?',
    whereArgs: [fenceId],
  );
  // second add all points again
  for (LatLng point in points) {
    await db.insert(
      tableFencePoints,
      FencePoint(fenceId: fenceId, lat: point.latitude, lon: point.longitude).toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

Future<FencePoint> createFencePoint(FencePoint point) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableFencePoints,
    where: '''${FencePointFields.fenceId} = ? AND
              ${FencePointFields.lat} = ? AND 
              ${FencePointFields.lon} = ?''',
    whereArgs: [point.fenceId, point.lat, point.lon],
  );
  if (data.isEmpty) {
    await db.insert(
      tableFencePoints,
      point.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  return point;
}

Future<List<LatLng>> getFencePoints(String fenceId) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableFencePoints,
    where: '${FencePointFields.fenceId} = ?',
    whereArgs: [fenceId],
  );
  List<LatLng> fencePoints = [];
  if (data.isNotEmpty) {
    fencePoints.addAll(
      data.map((e) {
        final point = FencePoint.fromJson(e);
        return LatLng(point.lat, point.lon);
      }).toList(),
    );
  }

  return fencePoints;
}

Future<void> removeAllFencePoints(String fenceId) async {
  final db = await GuardianDatabase().database;
  await db.delete(
    tableFencePoints,
    where: '${FencePointFields.fenceId} = ?',
    whereArgs: [fenceId],
  );
}
