import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

Future<AnimalLocationsCompanion> createDeviceData(AnimalLocationsCompanion deviceData) async {
  final db = Get.find<GuardianDb>();
  db.into(db.animalLocations).insertOnConflictUpdate(deviceData);
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

Future<AnimalLocationsCompanion?> getLastDeviceData(BigInt idAnimal) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.animalLocations)
        ..where(
          (tbl) => tbl.idAnimal.equals(idAnimal),
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
      SELECT IFNULL(MAX(${db.animalLocations.elevation.name}),0) AS maxElevation FROM ${db.animal.actualTableName}
      LEFT JOIN ${db.animalLocations.actualTableName} ON ${db.animalLocations.actualTableName}.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
    ''').getSingle();

  return double.parse(data.data['maxElevation'].toString());
}

Future<double> getMaxTemperature() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
      SELECT IFNULL(MAX(${db.animalLocations.temperature.name}),0) AS maxTemperature FROM ${db.animal.actualTableName}
      LEFT JOIN ${db.animalLocations.actualTableName} ON ${db.animalLocations.actualTableName}.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
    ''').getSingle();

  return double.parse(data.data['maxTemperature'].toString());
}

Future<List<AnimalLocationsCompanion>> getAnimalData({
  DateTime? startDate,
  DateTime? endDate,
  required BigInt idAnimal,
  bool isInterval = false,
}) async {
  final db = Get.find<GuardianDb>();
  List<AnimalLocationsCompanion> deviceData = [];
  List<AnimalLocation> data = [];
  if (isInterval && startDate!.difference(endDate!).inSeconds.abs() > 60) {
    // AND ${db.deviceLocations.date.name} BETWEEN ? AND ?
    //   JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.idDevice.name} = ${db.deviceLocations.actualTableName}.${db.deviceLocations.idDevice.name}
    //   JOIN ${db.animal.actualTableName} ON ${db.animal.actualTableName}.${db.animal.idDevice.name} = ${db.device.actualTableName}.${db.device.idDevice.name}
    //   WHERE ${db.animal.idAnimal.name} = ?
    //   ORDER BY ${db.deviceLocations.date.name} DESC
    final dt = await db.customSelect('''
      SELECT * FROM ${db.animalLocations.actualTableName}
      JOIN ${db.animal.actualTableName} ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = ${db.animalLocations.actualTableName}.${db.animalLocations.idAnimal.name}
      WHERE ${db.animal.actualTableName}.${db.animal.idAnimal.name} = ? AND ${db.animalLocations.date.name} BETWEEN ? AND ?
      ORDER BY ${db.animalLocations.date.name} DESC
    ''', variables: [
      drift.Variable.withBigInt(idAnimal),
      drift.Variable.withDateTime(startDate),
      drift.Variable.withDateTime(endDate)
    ]).get();
    if (dt.isNotEmpty) {
      for (var locationData in dt) {
        deviceData.add(
          AnimalLocationsCompanion(
            accuracy: drift.Value(locationData.data[db.animalLocations.accuracy.name]),
            battery: drift.Value(locationData.data[db.animalLocations.battery.name]),
            dataUsage: drift.Value(locationData.data[db.animalLocations.dataUsage.name]),
            date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                locationData.data[db.animalLocations.date.name])),
            animalDataId:
                drift.Value(BigInt.from(locationData.data[db.animalLocations.animalDataId.name])),
            idAnimal: drift.Value(BigInt.from(locationData.data[db.animal.idAnimal.name])),
            elevation: drift.Value(locationData.data[db.animalLocations.elevation.name]),
            lat: drift.Value(locationData.data[db.animalLocations.lat.name]),
            lon: drift.Value(locationData.data[db.animalLocations.lon.name]),
            state: drift.Value(locationData.data[db.animalLocations.state.name]),
            temperature: drift.Value(locationData.data[db.animalLocations.temperature.name]),
          ),
        );
      }
    }
  } else {
    final dt = await (db.select(db.animalLocations)
          ..orderBy(
            [(tbl) => drift.OrderingTerm.desc(db.animalLocations.date)],
          )
          ..where(
            (tbl) => tbl.idAnimal.equals(idAnimal),
          ))
        .get();
    if (dt.isNotEmpty) {
      deviceData.add(dt.first.toCompanion(true));
    }
  }

  deviceData.addAll(data.map((e) => e.toCompanion(true)));
  return deviceData;
}
