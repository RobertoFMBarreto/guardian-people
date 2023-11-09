import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

/// Method for creating an [animal] returning it as an [AnimalCompanion]
Future<AnimalCompanion> createAnimal(
  AnimalCompanion animal,
) async {
  final db = Get.find<GuardianDb>();
  await db.into(db.animal).insertOnConflictUpdate(animal);
  return animal;
}

/// Method for deleting an animal [idAnimal]
Future<void> deleteAnimal(String idAnimal) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.animal)..where((tbl) => tbl.idAnimal.equals(idAnimal))).go();
}

/// Method for updating an [animal] returning it as an [AnimalCompanion]
Future<AnimalCompanion> updateAnimal(AnimalCompanion animal) async {
  final db = Get.find<GuardianDb>();
  db.update(db.animal).replace(animal);

  return animal;
}

/// Method to get animal [idAnimal] information as [AnimalData]
Future<AnimalData> getAnimal(String idAnimal) async {
  final db = Get.find<GuardianDb>();
  final data =
      await (db.select(db.animal)..where((tbl) => tbl.idAnimal.equals(idAnimal))).getSingle();

  return data;
}

/// Method to get all user animals as a [List<AnimalData>]
Future<List<AnimalData>> getUserAnimals() async {
  final db = Get.find<GuardianDb>();

  final data = await db.select(db.animal).get();

  List<Animal> animals = [];
  for (var animal in data) {
    final data = await (db.select(db.animalLocations)
          ..where((tbl) => tbl.idAnimal.equals(animal.idAnimal)))
        .get();
    Animal finalDevice = Animal(
        animal: animal.toCompanion(true), data: data.map((e) => e.toCompanion(true)).toList());
    animals.add(finalDevice);
  }

  return data;
}

/// Method to get an animal [idAnimal] information with all its locations data as an [Animal]
Future<Animal> getAnimalWithData(String idAnimal) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT * FROM ${db.animal.actualTableName}
      JOIN (
          SELECT * FROM ${db.animalLocations.actualTableName} 
          GROUP BY ${db.animalLocations.idAnimal.name}
          ORDER BY ${db.animalLocations.date.name} DESC 
      ) deviceData ON deviceData.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
      WHERE ${db.animal.actualTableName}.${db.animalLocations.idAnimal.name} = ?
    ''',
    variables: [
      drift.Variable.withString(idAnimal),
    ],
  ).getSingle();

  return Animal(
      animal: AnimalCompanion(
        animalColor: drift.Value(data.data[db.animal.animalColor.name]),
        idAnimal: drift.Value(data.data[db.animal.idAnimal.name]),
        isActive: drift.Value(data.data[db.animal.isActive.name] == 1),
        animalName: drift.Value(data.data[db.animal.animalName.name]),
        idUser: drift.Value(data.data[db.animal.idUser.name]),
        animalIdentification: drift.Value(data.data[db.animal.animalIdentification.name]),
      ),
      data: [
        AnimalLocationsCompanion(
          accuracy: drift.Value(data.data['accuracy']),
          battery: drift.Value(data.data['battery']),
          date: drift.Value(data.data['date']),
          animalDataId: drift.Value(data.data['animal_data_id']),
          idAnimal: drift.Value(data.data['device_id']),
          elevation: drift.Value(data.data['elevation']),
          lat: drift.Value(data.data['lat']),
          lon: drift.Value(data.data['lon']),
          state: drift.Value(data.data['state']),
          temperature: drift.Value(data.data['temperature']),
        ),
      ]);
}

/// Method to get all user animals information with last location data as a [List<Animal>]
Future<List<Animal>> getUserAnimalsWithData() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
      SELECT 
        ${db.animal.idUser.name},
        ${db.animal.animalName.name},
        ${db.animal.animalIdentification.name},
        ${db.animal.animalColor.name},
        ${db.animal.actualTableName}.${db.animal.isActive.name},
        ${db.animalLocations.animalDataId.name},
        ${db.animalLocations.temperature.name},
        ${db.animalLocations.battery.name},
        ${db.animalLocations.lat.name},
        ${db.animalLocations.lon.name},
        ${db.animalLocations.elevation.name},
        ${db.animalLocations.accuracy.name},
        ${db.animalLocations.date.name},
        ${db.animalLocations.state.name},
        ${db.animal.actualTableName}.${db.animal.idAnimal.name}
      FROM ${db.animal.actualTableName}
      LEFT JOIN (
          SELECT * FROM ${db.animalLocations.actualTableName} 
          GROUP BY ${db.animalLocations.idAnimal.name}
          ORDER BY ${db.animalLocations.date.name} DESC 
      ) A ON A.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
    ''').get();

  List<Animal> animals = [];
  for (var deviceData in data) {
    Animal animal = Animal(
        animal: AnimalCompanion(
          animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
          isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
          animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
          idUser: drift.Value(deviceData.data[db.animal.idUser.name]),
          animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
          idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
        ),
        data: [
          if (deviceData.data[db.animalLocations.date.name] != null)
            AnimalLocationsCompanion(
              accuracy: drift.Value(deviceData.data[db.animalLocations.accuracy.name]),
              battery: drift.Value(deviceData.data[db.animalLocations.battery.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  deviceData.data[db.animalLocations.date.name] * 1000)),
              animalDataId: drift.Value(deviceData.data[db.animalLocations.animalDataId.name]),
              idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
              elevation: drift.Value(deviceData.data[db.animalLocations.elevation.name]),
              lat: drift.Value(deviceData.data[db.animalLocations.lat.name]),
              lon: drift.Value(deviceData.data[db.animalLocations.lon.name]),
              state: drift.Value(deviceData.data[db.animalLocations.state.name]),
              temperature: drift.Value(deviceData.data[db.animalLocations.temperature.name]),
            ),
        ]);
    animals.add(animal);
  }

  return animals;
}

/// Method to get all user animals information with last location data as a [List<Animal>]
Future<List<Animal>> getUserAnimalsWithLastLocation() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
      SELECT 
        ${db.animal.idUser.name},
        ${db.animal.animalName.name},
        ${db.animal.animalIdentification.name},
        ${db.animal.animalColor.name},
        ${db.animal.actualTableName}.${db.animal.isActive.name},
        ${db.animalLocations.animalDataId.name},
        ${db.animalLocations.temperature.name},
        ${db.animalLocations.battery.name},
        ${db.animalLocations.lat.name},
        ${db.animalLocations.lon.name},
        ${db.animalLocations.elevation.name},
        ${db.animalLocations.accuracy.name},
        ${db.animalLocations.date.name},
        ${db.animalLocations.state.name},
        ${db.animal.actualTableName}.${db.animal.idAnimal.name}
      FROM ${db.animal.actualTableName}
      JOIN (
          SELECT * FROM ${db.animalLocations.actualTableName} 
          GROUP BY ${db.animalLocations.idAnimal.name}
          HAVING ${db.animalLocations.lat.name} IS NOT NULL AND ${db.animalLocations.lon.name} IS NOT NULL
          ORDER BY ${db.animalLocations.date.name} DESC 
      ) A ON A.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
    ''').get();
//${db.animalLocations.actualTableName} ON ${db.animalLocations.actualTableName}.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
  List<Animal> animals = [];

  for (var deviceData in data) {
    Animal animal = Animal(
        animal: AnimalCompanion(
          animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
          isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
          animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
          idUser: drift.Value(deviceData.data[db.animal.idUser.name]),
          animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
          idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
        ),
        data: [
          if (deviceData.data[db.animalLocations.date.name] != null)
            AnimalLocationsCompanion(
              accuracy: drift.Value(deviceData.data[db.animalLocations.accuracy.name]),
              battery: drift.Value(deviceData.data[db.animalLocations.battery.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  deviceData.data[db.animalLocations.date.name] * 1000)),
              animalDataId: drift.Value(deviceData.data[db.animalLocations.animalDataId.name]),
              idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
              elevation: drift.Value(deviceData.data[db.animalLocations.elevation.name]),
              lat: drift.Value(deviceData.data[db.animalLocations.lat.name]),
              lon: drift.Value(deviceData.data[db.animalLocations.lon.name]),
              state: drift.Value(deviceData.data[db.animalLocations.state.name]),
              temperature: drift.Value(deviceData.data[db.animalLocations.temperature.name]),
            ),
        ]);
    animals.add(animal);
  }

  return animals;
}

/// Method to get all user animals information with last location data as a [List<Animal>]
Future<List<Animal>> getUserAnimalWithLastLocation(String idAnimal) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT 
        ${db.animal.idUser.name},
        ${db.animal.animalName.name},
        ${db.animal.animalIdentification.name},
        ${db.animal.animalColor.name},
        ${db.animal.actualTableName}.${db.animal.isActive.name},
        ${db.animalLocations.animalDataId.name},
        ${db.animalLocations.temperature.name},
        ${db.animalLocations.battery.name},
        ${db.animalLocations.lat.name},
        ${db.animalLocations.lon.name},
        ${db.animalLocations.elevation.name},
        ${db.animalLocations.accuracy.name},
        ${db.animalLocations.date.name},
        ${db.animalLocations.state.name},
        ${db.animal.actualTableName}.${db.animal.idAnimal.name}
      FROM ${db.animal.actualTableName}
      JOIN (
          SELECT * FROM ${db.animalLocations.actualTableName} 
          GROUP BY ${db.animalLocations.idAnimal.name}
          HAVING ${db.animalLocations.lat.name} IS NOT NULL AND ${db.animalLocations.lon.name} IS NOT NULL
          ORDER BY ${db.animalLocations.date.name} DESC 
      ) A ON A.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
      WHERE ${db.animal.actualTableName}.${db.animal.idAnimal.name} = ?
    ''',
    variables: [
      drift.Variable.withString(idAnimal),
    ],
  ).get();
//${db.animalLocations.actualTableName} ON ${db.animalLocations.actualTableName}.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
  List<Animal> animals = [];

  for (var deviceData in data) {
    Animal animal = Animal(
        animal: AnimalCompanion(
          animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
          isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
          animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
          idUser: drift.Value(deviceData.data[db.animal.idUser.name]),
          animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
          idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
        ),
        data: [
          if (deviceData.data[db.animalLocations.date.name] != null)
            AnimalLocationsCompanion(
              accuracy: drift.Value(deviceData.data[db.animalLocations.accuracy.name]),
              battery: drift.Value(deviceData.data[db.animalLocations.battery.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  deviceData.data[db.animalLocations.date.name] * 1000)),
              animalDataId: drift.Value(deviceData.data[db.animalLocations.animalDataId.name]),
              idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
              elevation: drift.Value(deviceData.data[db.animalLocations.elevation.name]),
              lat: drift.Value(deviceData.data[db.animalLocations.lat.name]),
              lon: drift.Value(deviceData.data[db.animalLocations.lon.name]),
              state: drift.Value(deviceData.data[db.animalLocations.state.name]),
              temperature: drift.Value(deviceData.data[db.animalLocations.temperature.name]),
            ),
        ]);

    animals.add(animal);
  }

  return animals;
}

/// Method to search [searchString] all user animals and get them with information and last location data as a [List<Animal>]
///
/// These animals can be filtered by ranges: [batteryRangeValues], [dtUsageRangeValues], [tmpRangeValues], [elevationRangeValues]
Future<List<Animal>> getUserAnimalsFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
}) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT
        ${db.animal.idUser.name},
        ${db.animal.animalName.name},
        ${db.animal.animalIdentification.name},
        ${db.animal.animalColor.name},
        ${db.animal.actualTableName}.${db.animal.isActive.name},
        ${db.animalLocations.animalDataId.name},
        ${db.animalLocations.temperature.name},
        ${db.animalLocations.battery.name},
        ${db.animalLocations.lat.name},
        ${db.animalLocations.lon.name},
        ${db.animalLocations.elevation.name},
        ${db.animalLocations.accuracy.name},
        ${db.animalLocations.date.name},
        ${db.animalLocations.state.name},
        ${db.animal.actualTableName}.${db.animal.idAnimal.name}
      FROM ${db.animal.actualTableName}
      LEFT JOIN (
          SELECT * FROM ${db.animalLocations.actualTableName} 
          GROUP BY ${db.animalLocations.idAnimal.name}
          HAVING ${db.animalLocations.lat.name} IS NOT NULL AND ${db.animalLocations.lon.name} IS NOT NULL
          ORDER BY ${db.animalLocations.date.name} DESC 
      ) deviceData ON deviceData.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
      WHERE
        (
        deviceData.${db.animalLocations.temperature.name} >= ? AND deviceData.${db.animalLocations.temperature.name} <= ? AND
        deviceData.${db.animalLocations.battery.name} >= ? AND deviceData.${db.animalLocations.battery.name} <= ? AND
        deviceData.${db.animalLocations.elevation.name} >= ? AND deviceData.${db.animalLocations.elevation.name} <= ? AND
        ${db.animal.animalIdentification.name} LIKE ?) OR (${db.animal.animalIdentification.name} LIKE ? AND deviceData.${db.animalLocations.temperature.name} IS NULL)
      ORDER BY
        ${db.animal.animalIdentification.name}
    ''',
    variables: [
      drift.Variable.withReal(tmpRangeValues.start),
      drift.Variable.withReal(tmpRangeValues.end),
      drift.Variable.withInt(batteryRangeValues.start.toInt()),
      drift.Variable.withInt(batteryRangeValues.end.toInt()),
      drift.Variable.withReal(elevationRangeValues.start),
      drift.Variable.withReal(elevationRangeValues.end),
      drift.Variable.withString('%$searchString%'),
      drift.Variable.withString('%$searchString%'),
    ],
  ).get();
  List<Animal> animals = [];
  for (var deviceData in data) {
    Animal animal = Animal(
        animal: AnimalCompanion(
          animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
          isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
          animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
          idUser: drift.Value(deviceData.data[db.animal.idUser.name]),
          animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
          idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
        ),
        data: [
          if (deviceData.data[db.animalLocations.date.name] != null)
            AnimalLocationsCompanion(
              accuracy: drift.Value(deviceData.data[db.animalLocations.accuracy.name]),
              battery: drift.Value(deviceData.data[db.animalLocations.battery.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  deviceData.data[db.animalLocations.date.name] * 1000)),
              animalDataId: drift.Value(deviceData.data[db.animalLocations.animalDataId.name]),
              idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
              elevation: drift.Value(deviceData.data[db.animalLocations.elevation.name]),
              lat: drift.Value(deviceData.data[db.animalLocations.lat.name]),
              lon: drift.Value(deviceData.data[db.animalLocations.lon.name]),
              state: drift.Value(deviceData.data[db.animalLocations.state.name]),
              temperature: drift.Value(deviceData.data[db.animalLocations.temperature.name]),
            ),
        ]);

    animals.add(animal);
  }

  return animals;
}

/// Method to get all user animals with last location [List<Animal>] that aren't selected for a fence [idFence] allowing to filter and search them
///
/// These animals can be filtered by ranges: [batteryRangeValues], [dtUsageRangeValues], [tmpRangeValues], [elevationRangeValues]
Future<List<Animal>> getUserFenceUnselectedAnimalsFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
  required String idFence,
}) async {
  final db = Get.find<GuardianDb>();

  final data = await db.customSelect(
    '''
      SELECT
        ${db.animal.idUser.name},
        ${db.animal.animalName.name},
        ${db.animal.actualTableName}.${db.animal.idAnimal.name},
        ${db.animal.animalIdentification.name},
        ${db.animal.animalColor.name},
        ${db.animal.actualTableName}.${db.animal.isActive.name},
        ${db.animalLocations.animalDataId.name},
        ${db.animalLocations.temperature.name},
        ${db.animalLocations.battery.name},
        ${db.animalLocations.lat.name},
        ${db.animalLocations.lon.name},
        ${db.animalLocations.elevation.name},
        ${db.animalLocations.accuracy.name},
        ${db.animalLocations.date.name},
        ${db.animalLocations.state.name}
      FROM ${db.animal.actualTableName}
      LEFT JOIN (
          SELECT * FROM ${db.animalLocations.actualTableName}
          GROUP BY ${db.animalLocations.idAnimal.name}
          HAVING ${db.animalLocations.lat.name} IS NOT NULL AND ${db.animalLocations.lon.name} IS NOT NULL
          ORDER BY ${db.animalLocations.date.name} DESC
      ) deviceData ON deviceData.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
      WHERE
        ((
          deviceData.${db.animalLocations.temperature.name} >= ? AND deviceData.${db.animalLocations.temperature.name} <= ? AND
          deviceData.${db.animalLocations.battery.name} >= ? AND deviceData.${db.animalLocations.battery.name} <= ? AND
          deviceData.${db.animalLocations.elevation.name} >= ? AND deviceData.${db.animalLocations.elevation.name} <= ? AND
          ${db.animal.animalName.name} LIKE ?) OR
          (${db.animal.animalName.name} LIKE ? AND deviceData.${db.animalLocations.temperature.name} IS NULL))
        AND
        ${db.animal.actualTableName}.${db.animal.idAnimal.name} NOT IN (
            SELECT ${db.animal.idAnimal.name} FROM ${db.fenceAnimals.actualTableName}
            WHERE ${db.fenceAnimals.actualTableName}.${db.fenceAnimals.idFence.name} = ?
        )
      ORDER BY
        ${db.animal.actualTableName}.${db.animal.animalName.name}
    ''',
    variables: [
      drift.Variable.withReal(tmpRangeValues.start),
      drift.Variable.withReal(tmpRangeValues.end),
      drift.Variable.withInt(batteryRangeValues.start.toInt()),
      drift.Variable.withInt(batteryRangeValues.end.toInt()),
      drift.Variable.withReal(elevationRangeValues.start),
      drift.Variable.withReal(elevationRangeValues.end),
      drift.Variable.withString('%$searchString%'),
      drift.Variable.withString('%$searchString%'),
      drift.Variable.withString(idFence),
    ],
  ).get();

  List<Animal> devices = [];
  if (data.isNotEmpty) {
    for (var deviceData in data) {
      devices.add(Animal(
          animal: AnimalCompanion(
            animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
            isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
            animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
            idUser: drift.Value(deviceData.data[db.animal.idUser.name]),
            animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
            idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
          ),
          data: [
            if (deviceData.data[db.animalLocations.date.name] != null)
              AnimalLocationsCompanion(
                accuracy: drift.Value(deviceData.data[db.animalLocations.accuracy.name]),
                battery: drift.Value(deviceData.data[db.animalLocations.battery.name]),
                date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                    deviceData.data[db.animalLocations.date.name] * 1000)),
                animalDataId: drift.Value(deviceData.data[db.animalLocations.animalDataId.name]),
                idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
                elevation: drift.Value(deviceData.data[db.animalLocations.elevation.name]),
                lat: drift.Value(deviceData.data[db.animalLocations.lat.name]),
                lon: drift.Value(deviceData.data[db.animalLocations.lon.name]),
                state: drift.Value(deviceData.data[db.animalLocations.state.name]),
                temperature: drift.Value(deviceData.data[db.animalLocations.temperature.name]),
              ),
          ]));
    }
  }
  return devices;
}

/// Method to get all user animals with last location [List<Animal>] that aren't selected for an alert [idAlert] allowing to filter and search them
///
/// These animals can be filtered by ranges: [batteryRangeValues], [dtUsageRangeValues], [tmpRangeValues], [elevationRangeValues]
Future<List<Animal>> getUserAlertUnselectedAnimalsFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
  required String idAlert,
}) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT
        ${db.animal.idUser.name},
        ${db.animal.animalName.name},
        ${db.animal.actualTableName}.${db.animal.idAnimal.name},
        ${db.animal.animalIdentification.name},
        ${db.animal.animalColor.name},
        ${db.animal.actualTableName}.${db.animal.isActive.name},
        ${db.animalLocations.animalDataId.name},
        ${db.animalLocations.temperature.name},
        ${db.animalLocations.battery.name},
        ${db.animalLocations.lat.name},
        ${db.animalLocations.lon.name},
        ${db.animalLocations.elevation.name},
        ${db.animalLocations.accuracy.name},
        ${db.animalLocations.date.name},
        ${db.animalLocations.state.name}
      FROM ${db.animal.actualTableName}
      LEFT JOIN (
          SELECT * FROM ${db.animalLocations.actualTableName}
          GROUP BY ${db.animalLocations.idAnimal.name}
          HAVING ${db.animalLocations.lat.name} IS NOT NULL AND ${db.animalLocations.lon.name} IS NOT NULL
          ORDER BY ${db.animalLocations.date.name} DESC
      ) deviceData ON deviceData.${db.animalLocations.idAnimal.name} = ${db.animal.actualTableName}.${db.animal.idAnimal.name}
      WHERE
        ((
          deviceData.${db.animalLocations.temperature.name} >= ? AND deviceData.${db.animalLocations.temperature.name} <= ? AND
          deviceData.${db.animalLocations.battery.name} >= ? AND deviceData.${db.animalLocations.battery.name} <= ? AND
          deviceData.${db.animalLocations.elevation.name} >= ? AND deviceData.${db.animalLocations.elevation.name} <= ? AND
          ${db.animal.animalName.name} LIKE ?) OR
          (${db.animal.animalName.name} LIKE ? AND deviceData.${db.animalLocations.temperature.name} IS NULL))
        AND
        ${db.animal.actualTableName}.${db.animal.idAnimal.name} NOT IN (
            SELECT ${db.animal.idAnimal.name} FROM ${db.alertAnimals.actualTableName}
            WHERE ${db.alertAnimals.actualTableName}.${db.alertAnimals.idAlert.name} = ?
        )
      ORDER BY
        ${db.animal.actualTableName}.${db.animal.animalName.name}
    ''',
    variables: [
      drift.Variable.withReal(tmpRangeValues.start),
      drift.Variable.withReal(tmpRangeValues.end),
      drift.Variable.withInt(batteryRangeValues.start.toInt()),
      drift.Variable.withInt(batteryRangeValues.end.toInt()),
      drift.Variable.withReal(elevationRangeValues.start),
      drift.Variable.withReal(elevationRangeValues.end),
      drift.Variable.withString('%$searchString%'),
      drift.Variable.withString('%$searchString%'),
      drift.Variable.withString(idAlert),
    ],
  ).get();

  List<Animal> devices = [];
  if (data.isNotEmpty) {
    for (var deviceData in data) {
      devices.add(
        Animal(
          animal: AnimalCompanion(
            animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
            isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
            animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
            idUser: drift.Value(deviceData.data[db.animal.idUser.name]),
            animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
            idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
          ),
          data: [
            if (deviceData.data[db.animalLocations.date.name] != null)
              AnimalLocationsCompanion(
                accuracy: drift.Value(deviceData.data[db.animalLocations.accuracy.name]),
                battery: drift.Value(deviceData.data[db.animalLocations.battery.name]),
                date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                    deviceData.data[db.animalLocations.date.name] * 1000)),
                animalDataId: drift.Value(deviceData.data[db.animalLocations.animalDataId.name]),
                idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
                elevation: drift.Value(deviceData.data[db.animalLocations.elevation.name]),
                lat: drift.Value(deviceData.data[db.animalLocations.lat.name]),
                lon: drift.Value(deviceData.data[db.animalLocations.lon.name]),
                state: drift.Value(deviceData.data[db.animalLocations.state.name]),
                temperature: drift.Value(deviceData.data[db.animalLocations.temperature.name]),
              ),
          ],
        ),
      );
    }
  }
  return devices;
}
