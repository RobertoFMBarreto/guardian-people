import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

Future<DeviceLocationsCompanion> createDeviceData(DeviceLocationsCompanion deviceData) async {
  final db = Get.find<GuardianDb>();
  db.into(db.deviceLocations).insertOnConflictUpdate(deviceData);
  return deviceData;
}

// Future<List<DeviceData>?> getAllDeviceData(String idDevice) async {
//   final db = await GuardianDatabase().database;
//   final data = await db.query(
//     tableDeviceData,
//     where: '${DeviceDataFields.idDevice} = ?',
//     whereArgs: [idDevice],
//   );

//   if (data.isNotEmpty) {
//     return data.map((e) => DeviceData.fromJson(e)).toList();
//   }
//   return null;
// }

Future<DeviceLocationsCompanion?> getLastDeviceData(BigInt idDevice) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.deviceLocations)
        ..where(
          (tbl) => tbl.idDevice.equals(idDevice),
        )
        ..orderBy(
          [(tbl) => drift.OrderingTerm.desc(tbl.date)],
        ))
      .getSingleOrNull();
  return data?.toCompanion(true);
}

Future<double> getMaxElevation() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
      SELECT IFNULL(MAX(${db.deviceLocations.elevation.name}),0) AS maxElevation FROM ${db.device.actualTableName}
      LEFT JOIN ${db.deviceLocations.actualTableName} ON ${db.deviceLocations.actualTableName}.${db.deviceLocations.idDevice.name} = ${db.device.actualTableName}.${db.deviceLocations.idDevice.name}
    ''').getSingle();

  return data.data['maxElevation'];
}

Future<double> getMaxTemperature() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
      SELECT IFNULL(MAX(${db.deviceLocations.temperature.name}),0) AS maxTemperature FROM ${db.device.actualTableName}
      LEFT JOIN ${db.deviceLocations.actualTableName} ON ${db.deviceLocations.actualTableName}.${db.deviceLocations.idDevice.name} = ${db.device.actualTableName}.${db.deviceLocations.idDevice.name}
    ''').getSingle();

  return data.data['maxTemperature'];
}

Future<List<DeviceLocationsCompanion>> getAnimalData({
  DateTime? startDate,
  DateTime? endDate,
  required BigInt idAnimal,
  bool isInterval = false,
}) async {
  final db = Get.find<GuardianDb>();
  List<DeviceLocation> data = [];
  if (isInterval && startDate!.difference(endDate!).inSeconds.abs() > 60) {
    data = await (db.select(db.deviceLocations)
          ..join([
            drift.innerJoin(db.device, db.device.idDevice.equalsExp(db.deviceLocations.idDevice))
          ])
          ..join([drift.innerJoin(db.animal, db.animal.idDevice.equalsExp(db.device.idDevice))])
          ..orderBy([(tbl) => drift.OrderingTerm.desc(db.deviceLocations.date)])
          ..where((tbl) =>
              db.animal.idAnimal.equals(idAnimal) &
              db.deviceLocations.date.isBiggerOrEqualValue(startDate) &
              db.deviceLocations.date.isSmallerOrEqualValue(endDate)))
        .get();
  } else {
    final dt = await (db.select(db.deviceLocations)
          ..orderBy(
            [(tbl) => drift.OrderingTerm.desc(db.deviceLocations.date)],
          )
          ..where(
            (tbl) => tbl.idDevice.equals(idAnimal),
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
