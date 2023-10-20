import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

/// Method for creating animal location data [animalData] returning it as [AnimalLocationsCompanion]
Future<AnimalLocationsCompanion> createAnimalData(AnimalLocationsCompanion animalData) async {
  final db = Get.find<GuardianDb>();
  db.into(db.animalLocations).insertOnConflictUpdate(animalData);
  return animalData;
}

/// Method to get last animal data from a single animal [idAnimal] returning as a [AnimalLocationsCompanion]
Future<AnimalLocationsCompanion?> getLastAnimalData(String idAnimal) async {
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

/// Method to get the current registered max elevation in the database
Future<double> getMaxElevation() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
      SELECT IFNULL(MAX(${db.animalLocations.elevation.name}),0) AS maxElevation FROM ${db.animal.actualTableName}
      LEFT JOIN ${db.animalLocations.actualTableName} ON ${db.animalLocations.actualTableName}.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
    ''').getSingle();

  return double.parse(data.data['maxElevation'].toString());
}

/// Method to get the current registered max temperature in the database
Future<double> getMaxTemperature() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
      SELECT IFNULL(MAX(${db.animalLocations.temperature.name}),0) AS maxTemperature FROM ${db.animal.actualTableName}
      LEFT JOIN ${db.animalLocations.actualTableName} ON ${db.animalLocations.actualTableName}.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
    ''').getSingle();

  return double.parse(data.data['maxTemperature'].toString());
}

/// Method to get all animal data from a single animal [idAnimal]
///
/// If the [isInterval] parameter is `false` the method returns the last registered data
///
/// If the [isInterval] parameter is `true` than [startDate] and [endDate] must be set and with a diffence of
/// at least 60 seconds. Then the query will select all animal data between [startDate] and [endDate]
///
/// Returns the animal data as a [List<AnimalLocationsCompanion>]
Future<List<AnimalLocationsCompanion>> getAnimalData({
  DateTime? startDate,
  DateTime? endDate,
  required String idAnimal,
  bool isInterval = false,
}) async {
  final db = Get.find<GuardianDb>();
  List<AnimalLocationsCompanion> animalData = [];
  List<AnimalLocation> data = [];
  if (isInterval && startDate!.difference(endDate!).inSeconds.abs() > 60) {
    final dt = await db.customSelect('''
      SELECT * FROM ${db.animalLocations.actualTableName}
      JOIN ${db.animal.actualTableName} ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = ${db.animalLocations.actualTableName}.${db.animalLocations.idAnimal.name}
      WHERE ${db.animal.actualTableName}.${db.animal.idAnimal.name} = ? AND ${db.animalLocations.date.name} BETWEEN ? AND ?
      ORDER BY ${db.animalLocations.date.name} DESC
    ''', variables: [
      drift.Variable.withString(idAnimal),
      drift.Variable.withDateTime(startDate),
      drift.Variable.withDateTime(endDate)
    ]).get();
    if (dt.isNotEmpty) {
      for (var locationData in dt) {
        animalData.add(
          AnimalLocationsCompanion(
            accuracy: drift.Value(locationData.data[db.animalLocations.accuracy.name]),
            battery: drift.Value(locationData.data[db.animalLocations.battery.name]),
            dataUsage: drift.Value(locationData.data[db.animalLocations.dataUsage.name]),
            date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                locationData.data[db.animalLocations.date.name])),
            animalDataId:
                drift.Value(locationData.data[db.animalLocations.animalDataId.name]),
            idAnimal: drift.Value(locationData.data[db.animal.idAnimal.name]),
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
      animalData.add(dt.first.toCompanion(true));
    }
  }

  animalData.addAll(data.map((e) => e.toCompanion(true)));
  return animalData;
}
