import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

Future<DeviceLocationsCompanion> createDeviceData(DeviceLocationsCompanion deviceData) async {
  final db = Get.find<GuardianDb>();
  db.into(db.deviceLocations).insertOnConflictUpdate(deviceData);
  return deviceData;
}

// Future<List<DeviceData>?> getAllDeviceData(String deviceId) async {
//   final db = await GuardianDatabase().database;
//   final data = await db.query(
//     tableDeviceData,
//     where: '${DeviceDataFields.deviceId} = ?',
//     whereArgs: [deviceId],
//   );

//   if (data.isNotEmpty) {
//     return data.map((e) => DeviceData.fromJson(e)).toList();
//   }
//   return null;
// }

Future<DeviceLocationsCompanion?> getLastDeviceData(String deviceId) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.deviceLocations)
        ..where(
          (tbl) => tbl.deviceId.equals(deviceId),
        )
        ..orderBy(
          [(tbl) => OrderingTerm.desc(tbl.date)],
        ))
      .getSingleOrNull();
  return data?.toCompanion(true);
}

Future<List<DeviceLocationsCompanion>> getDeviceData({
  DateTime? startDate,
  DateTime? endDate,
  required String deviceId,
  bool isInterval = false,
}) async {
  final db = Get.find<GuardianDb>();
  print('GdDebug> $startDate | $endDate');
  List<DeviceLocation> data = [];
  if (isInterval && startDate!.difference(endDate!).inSeconds.abs() > 60) {
    data = await (db.select(db.deviceLocations)
          ..orderBy([(tbl) => OrderingTerm.desc(db.deviceLocations.date)])
          ..where(
            (tbl) =>
                tbl.deviceId.equals(deviceId) &
                tbl.date.isBiggerOrEqualValue(startDate) &
                tbl.date.isSmallerOrEqualValue(endDate),
          ))
        .get();
  } else {
    final dt = await (db.select(db.deviceLocations)
          ..orderBy(
            [(tbl) => OrderingTerm.desc(db.deviceLocations.date)],
          )
          ..where(
            (tbl) => tbl.deviceId.equals(deviceId),
          ))
        .get();
    if (dt.isNotEmpty) {
      data.add(dt.first);
    }
  }

  List<DeviceLocationsCompanion> deviceData = [];

  deviceData.addAll(data.map((e) => e.toCompanion(true)));
  return deviceData;
}
