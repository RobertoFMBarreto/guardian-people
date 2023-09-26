import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

Future<AnimalCompanion> createAnimal(
  AnimalCompanion animal,
) async {
  final db = Get.find<GuardianDb>();
  await db.into(db.animal).insertOnConflictUpdate(animal);
  return animal;
}

Future<void> deleteAnimal(BigInt idAnimal) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.animal)..where((tbl) => tbl.idAnimal.equals(idAnimal))).go();
}

Future<AnimalCompanion> updateAnimal(AnimalCompanion animal) async {
  final db = Get.find<GuardianDb>();
  db.update(db.animal).replace(animal);

  return animal;
}

Future<AnimalData> getAnimal(BigInt idAnimal) async {
  final db = Get.find<GuardianDb>();
  final data =
      await (db.select(db.animal)..where((tbl) => tbl.idAnimal.equals(idAnimal))).getSingle();

  return data;
}

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

Future<Animal> getAnimalWithData(BigInt idDevice) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT * FROM ${db.animal.actualTableName}
      JOIN (
        SELECT * FROM (SELECT * FROM ${db.animalLocations.actualTableName} ORDER BY ${db.animalLocations.date.name} DESC) A
        GROUP BY A.${db.animalLocations.idAnimal.name}
      ) as device_data ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = device_data.${db.animalLocations.idAnimal.name}
      WHERE ${db.animal.actualTableName}.${db.animalLocations.idAnimal.name} = ?
    ''',
    variables: [
      drift.Variable.withBigInt(idDevice),
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
          dataUsage: drift.Value(data.data['data_usage']),
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
        ${db.animalLocations.dataUsage.name},
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
        SELECT * FROM (SELECT * FROM ${db.animalLocations.actualTableName} ORDER BY ${db.animalLocations.date.name} DESC) A
        GROUP BY A.${db.animalLocations.idAnimal.name}
      ) as device_data ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = device_data.${db.animalLocations.idAnimal.name}
    ''').get();

  List<Animal> animals = [];

  for (var deviceData in data) {
    Animal animal = Animal(
        animal: AnimalCompanion(
          animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
          isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
          animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
          idUser: drift.Value(BigInt.from(deviceData.data[db.animal.idUser.name])),
          animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
          idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
        ),
        data: [
          if (deviceData.data[db.animalLocations.date.name] != null)
            AnimalLocationsCompanion(
              accuracy: drift.Value(deviceData.data[db.animalLocations.accuracy.name]),
              battery: drift.Value(deviceData.data[db.animalLocations.battery.name]),
              dataUsage: drift.Value(deviceData.data[db.animalLocations.dataUsage.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  deviceData.data[db.animalLocations.date.name])),
              animalDataId:
                  drift.Value(BigInt.from(deviceData.data[db.animalLocations.animalDataId.name])),
              idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
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
        ${db.animalLocations.dataUsage.name},
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
        SELECT * FROM
          (
            SELECT * FROM ${db.animalLocations.actualTableName}
            ORDER BY ${db.animalLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.animalLocations.idAnimal.name}
      ) deviceData ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = deviceData.${db.animalLocations.idAnimal.name}
      WHERE
        (deviceData.${db.animalLocations.dataUsage.name} >= ? AND  deviceData.${db.animalLocations.dataUsage.name} <= ? AND
        deviceData.${db.animalLocations.temperature.name} >= ? AND deviceData.${db.animalLocations.temperature.name} <= ? AND
        deviceData.${db.animalLocations.battery.name} >= ? AND deviceData.${db.animalLocations.battery.name} <= ? AND
        deviceData.${db.animalLocations.elevation.name} >= ? AND deviceData.${db.animalLocations.elevation.name} <= ? AND
        ${db.animal.animalIdentification.name} LIKE ?) OR (${db.animal.animalIdentification.name} LIKE ? AND deviceData.${db.animalLocations.temperature.name} IS NULL)
      ORDER BY
        ${db.animal.animalIdentification.name}
    ''',
    variables: [
      drift.Variable.withInt(dtUsageRangeValues.start.toInt()),
      drift.Variable.withInt(dtUsageRangeValues.end.toInt()),
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
          idUser: drift.Value(BigInt.from(deviceData.data[db.animal.idUser.name])),
          animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
          idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
        ),
        data: [
          if (deviceData.data[db.animalLocations.date.name] != null)
            AnimalLocationsCompanion(
              accuracy: drift.Value(deviceData.data[db.animalLocations.accuracy.name]),
              battery: drift.Value(deviceData.data[db.animalLocations.battery.name]),
              dataUsage: drift.Value(deviceData.data[db.animalLocations.dataUsage.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  deviceData.data[db.animalLocations.date.name])),
              animalDataId:
                  drift.Value(BigInt.from(deviceData.data[db.animalLocations.animalDataId.name])),
              idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
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

Future<List<Animal>> getUserFenceUnselectedAnimalsFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
  required BigInt idFence,
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
        ${db.animalLocations.dataUsage.name},
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
        SELECT * FROM
          (
            SELECT * FROM ${db.animalLocations.actualTableName}
            ORDER BY ${db.animalLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.animalLocations.idAnimal.name}
      ) deviceData ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = deviceData.${db.animalLocations.idAnimal.name}
      WHERE
        ((deviceData.${db.animalLocations.dataUsage.name} >= ? AND  deviceData.${db.animalLocations.dataUsage.name} <= ? AND
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
      drift.Variable.withInt(dtUsageRangeValues.start.toInt()),
      drift.Variable.withInt(dtUsageRangeValues.end.toInt()),
      drift.Variable.withReal(tmpRangeValues.start),
      drift.Variable.withReal(tmpRangeValues.end),
      drift.Variable.withInt(batteryRangeValues.start.toInt()),
      drift.Variable.withInt(batteryRangeValues.end.toInt()),
      drift.Variable.withReal(elevationRangeValues.start),
      drift.Variable.withReal(elevationRangeValues.end),
      drift.Variable.withString('%$searchString%'),
      drift.Variable.withString('%$searchString%'),
      drift.Variable.withBigInt(idFence),
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
            idUser: drift.Value(BigInt.from(deviceData.data[db.animal.idUser.name])),
            animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
            idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
          ),
          data: [
            if (deviceData.data[db.animalLocations.date.name] != null)
              AnimalLocationsCompanion(
                accuracy: drift.Value(deviceData.data[db.animalLocations.accuracy.name]),
                battery: drift.Value(deviceData.data[db.animalLocations.battery.name]),
                dataUsage: drift.Value(deviceData.data[db.animalLocations.dataUsage.name]),
                date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                    deviceData.data[db.animalLocations.date.name])),
                animalDataId:
                    drift.Value(BigInt.from(deviceData.data[db.animalLocations.animalDataId.name])),
                idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
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

Future<List<Animal>> getUserAlertUnselectedAnimalsFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
  required BigInt idAlert,
}) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT
        ${db.animal.idUser.name},
        ${db.animal.animalName.name},
        ${db.animal.animalIdentification.name},
        ${db.animal.animalColor.name},
        ${db.animal.actualTableName}.${db.animal.idAnimal.name},
        ${db.animal.actualTableName}.${db.animal.isActive.name},
        ${db.animal.actualTableName}.${db.animal.isActive.name},
        ${db.animalLocations.animalDataId.name},
        ${db.animalLocations.dataUsage.name},
        ${db.animalLocations.temperature.name},
        ${db.animalLocations.battery.name},
        ${db.animalLocations.lat.name},
        ${db.animalLocations.lon.name},
        ${db.animalLocations.elevation.name},
        ${db.animalLocations.accuracy.name},
        ${db.animalLocations.date.name},
        ${db.animalLocations.state.name},
      FROM ${db.animal.actualTableName}
      LEFT JOIN (
        SELECT * FROM
          (
            SELECT * FROM ${db.animalLocations.actualTableName}
            ORDER BY ${db.animalLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.animalLocations.idAnimal}
      ) deviceData ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = deviceData.${db.animalLocations.idAnimal.name}
      WHERE
        (deviceData.${db.animalLocations.dataUsage.name} >= ? AND  deviceData.${db.animalLocations.dataUsage.name} <= ? AND
        deviceData.${db.animalLocations.temperature.name} >= ? AND deviceData.${db.animalLocations.temperature.name} <= ? AND
        deviceData.${db.animalLocations.battery.name} >= ? AND deviceData.${db.animalLocations.battery.name} <= ? AND
        deviceData.${db.animalLocations.elevation.name} >= ? AND deviceData.${db.animalLocations.elevation.name} <= ?
        ${db.animal.animalName.name} LIKE ?) OR 
        (${db.animal.animalName.name} LIKE ? AND deviceData.${db.animalLocations.temperature.name} IS NULL) AND
        ${db.animal.actualTableName}.${db.animal.idAnimal.name} NOT IN (SELECT ${db.animal.idAnimal.name} FROM ${db.alertAnimals.actualTableName})
      ORDER BY
        ${db.animal.animalName.name}
    ''',
    variables: [
      drift.Variable.withInt(dtUsageRangeValues.start.toInt()),
      drift.Variable.withInt(dtUsageRangeValues.end.toInt()),
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

  List<Animal> devices = [];
  if (data.isNotEmpty) {
    for (var deviceData in data) {
      devices.add(
        Animal(
          animal: AnimalCompanion(
            animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
            isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
            animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
            idUser: drift.Value(BigInt.from(deviceData.data[db.animal.idUser.name])),
            animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
            idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
          ),
          data: [
            if (deviceData.data[db.animalLocations.date.name] != null)
              AnimalLocationsCompanion(
                accuracy: drift.Value(deviceData.data[db.animalLocations.accuracy.name]),
                battery: drift.Value(deviceData.data[db.animalLocations.battery.name]),
                dataUsage: drift.Value(deviceData.data[db.animalLocations.dataUsage.name]),
                date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                    deviceData.data[db.animalLocations.date.name])),
                animalDataId:
                    drift.Value(BigInt.from(deviceData.data[db.animalLocations.animalDataId.name])),
                idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
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
