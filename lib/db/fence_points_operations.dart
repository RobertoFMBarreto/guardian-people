import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Fences/fence_points.dart';
import 'package:latlong2/latlong.dart';

Future<FencePoints> createFencePoint(FencePoints point) async {
  final db = await GuardianDatabase.instance.database;
  final id = await db.insert(tableFencePoints, point.toJson());

  return point.copy(id: id);
}

Future<List<LatLng>> getFencePoints(String fenceId) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableFencePoints,
    where: '${FencePointsFields.fenceId} = ?',
    whereArgs: [fenceId],
  );

  List<LatLng> fencePoints = [];
  if (data.isNotEmpty) {
    fencePoints.addAll(
      data.map((e) {
        final point = FencePoints.fromJson(e);
        return LatLng(point.lat, point.lon);
      }).toList(),
    );
  }

  return fencePoints;
}
