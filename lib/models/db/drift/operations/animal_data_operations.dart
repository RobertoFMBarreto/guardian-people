import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

/// Method for creating animal location data [animalData] returning it as [AnimalLocationsCompanion]
Future<AnimalLocationsCompanion> createAnimalData(AnimalLocationsCompanion animalData) async {
  final db = Get.find<GuardianDb>();
  await db.into(db.animalLocations).insertOnConflictUpdate(animalData);
  return animalData;
}

/// Method for creating animal activity data [animalActivity] returning it as [AnimalActivityCompanion]
Future<AnimalActivityCompanion> createAnimalActivity(AnimalActivityCompanion animalActivity) async {
  final db = Get.find<GuardianDb>();
  await db.into(db.animalActivity).insertOnConflictUpdate(animalActivity);
  return animalActivity;
}

/// Method that allows to delete animal data by [AnimalDataId]
Future<void> deleteAnimalData(String idData) async {
  final db = Get.find<GuardianDb>();

  await (db.delete(db.animalLocations)..where((tbl) => tbl.animalDataId.equals(idData))).go();
}

/// Method that allows to delete animal activity by [AnimalDataId]
Future<void> deleteAnimalActivity(String idData) async {
  final db = Get.find<GuardianDb>();

  await (db.delete(db.animalActivity)..where((tbl) => tbl.animalDataActivityId.equals(idData)))
      .go();
}

/// Method that allows to delete animal [idAnimal] data between [startDate] and [endDate]
Future<void> deleteAnimalDataInInterval({
  DateTime? startDate,
  DateTime? endDate,
  required String idAnimal,
  bool isInterval = false,
}) async {
  final data = await getAnimalData(
      startDate: startDate, endDate: endDate, idAnimal: idAnimal, isInterval: isInterval);

  for (AnimalLocationsCompanion location in data) {
    await deleteAnimalData(location.animalDataId.value);
  }
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
  if (isInterval &&
      (startDate!.difference(endDate ?? DateTime.now()).inSeconds.abs() > 60 || endDate == null)) {
    final dt = await db.customSelect('''
      SELECT * FROM ${db.animalLocations.actualTableName}
      JOIN ${db.animal.actualTableName} ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = ${db.animalLocations.actualTableName}.${db.animalLocations.idAnimal.name}
      WHERE ${db.animal.actualTableName}.${db.animal.idAnimal.name} = ? AND ${db.animalLocations.date.name} BETWEEN ? AND ?
      ORDER BY ${db.animalLocations.date.name} DESC
    ''', variables: [
      drift.Variable.withString(idAnimal),
      drift.Variable.withDateTime(startDate),
      drift.Variable.withDateTime(endDate ?? DateTime.now().add(const Duration(seconds: 60)))
    ]).get();
    if (dt.isNotEmpty) {
      for (var locationData in dt) {
        animalData.add(
          AnimalLocationsCompanion(
            accuracy: drift.Value(locationData.data[db.animalLocations.accuracy.name]),
            battery: drift.Value(locationData.data[db.animalLocations.battery.name]),
            date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                locationData.data[db.animalLocations.date.name] * 1000)),
            animalDataId: drift.Value(locationData.data[db.animalLocations.animalDataId.name]),
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

/// Method to get all animal activity from a single animal [idAnimal]
///
/// If the [isInterval] parameter is `false` the method returns the last registered data
///
/// If the [isInterval] parameter is `true` than [startDate] and [endDate] must be set and with a diffence of
/// at least 60 seconds. Then the query will select all animal data between [startDate] and [endDate]
///
/// Returns the animal data as a [List<AnimalLocationsCompanion>]
Future<List<AnimalLocationsCompanion>> getAnimalActivity(
    {required DateTime startDate, required DateTime endDate, required String idAnimal}) async {
  final db = Get.find<GuardianDb>();
  List<AnimalLocationsCompanion> animalData = [];
  if (startDate.difference(endDate).inSeconds.abs() > 60) {
    final dt = await db.customSelect('''
      SELECT * FROM ${db.animalActivity.actualTableName}
      WHERE ${db.animalActivity.actualTableName}.${db.animalActivity.idAnimalActivity.name} = ?
        AND ${db.animalActivity.activityDate.name} BETWEEN ? AND ?
      ORDER BY ${db.animalActivity.activityDate.name} DESC
    ''', variables: [
      drift.Variable.withString(idAnimal),
      drift.Variable.withDateTime(startDate),
      drift.Variable.withDateTime(endDate)
    ]).get();

    if (dt.isNotEmpty) {
      for (var activityData in dt) {
        await getClosestAnimalActivity(
          idAnimal: idAnimal,
          time: DateTime.fromMillisecondsSinceEpoch(
            activityData.data[db.animalActivity.activityDate.name] * 1000,
          ),
        ).then(
          (locationData) => animalData.add(
            locationData.copyWith(
              state: drift.Value(activityData.data[db.animalActivity.activity.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  activityData.data[db.animalActivity.activityDate.name] * 1000)),
              animalDataId:
                  drift.Value(activityData.data[db.animalActivity.animalDataActivityId.name]),
            ),
          ),
        );
      }
    }
  }

  return animalData;
}

/// Method that allows to get the closest data from time
Future<AnimalLocationsCompanion> getClosestAnimalActivity(
    {required DateTime time, required String idAnimal}) async {
  final db = Get.find<GuardianDb>();

  final dt = await db.customSelect('''
      SELECT 
        *
      FROM 
        ${db.animalLocations.actualTableName}
      WHERE
        ${db.animalLocations.actualTableName}.${db.animalLocations.idAnimal.name} = ?
        AND 
        ${db.animalLocations.actualTableName}.${db.animalLocations.date.name} < ?
      ORDER BY
        ${db.animalLocations.actualTableName}.${db.animalLocations.date.name} DESC
      LIMIT 1
    ''', variables: [
    drift.Variable.withString(idAnimal),
    drift.Variable.withDateTime(time),
  ]).getSingleOrNull();
  if (dt != null) {
    return AnimalLocationsCompanion(
      accuracy: drift.Value(dt.data[db.animalLocations.accuracy.name]),
      battery: drift.Value(dt.data[db.animalLocations.battery.name]),
      date: drift.Value(
        DateTime.fromMillisecondsSinceEpoch(
          dt.data[db.animalLocations.date.name] * 1000,
        ),
      ),
      animalDataId: drift.Value(dt.data[db.animalLocations.animalDataId.name]),
      idAnimal: drift.Value(dt.data[db.animal.idAnimal.name]),
      elevation: drift.Value(dt.data[db.animalLocations.elevation.name]),
      lat: drift.Value(dt.data[db.animalLocations.lat.name]),
      lon: drift.Value(dt.data[db.animalLocations.lon.name]),
      state: drift.Value(dt.data[db.animalLocations.state.name]),
      temperature: drift.Value(dt.data[db.animalLocations.temperature.name]),
    );
  } else {
    return AnimalLocationsCompanion();
  }
}
