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

  List<Animal> devices = [];
  for (var device in data) {
    final data = await (db.select(db.deviceLocations)
          ..where((tbl) => tbl.idDevice.equals(device.idDevice)))
        .get();
    Animal finalDevice = Animal(
        animal: device.toCompanion(true), data: data.map((e) => e.toCompanion(true)).toList());
    devices.add(finalDevice);
  }

  return data;
}

Future<Animal> getAnimalWithData(BigInt idDevice) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT * FROM ${db.animal.actualTableName}
      JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.idDevice.name}=${db.animal.actualTableName}.${db.animal.idDevice.name}
      JOIN (
        SELECT * FROM (SELECT * FROM ${db.deviceLocations.actualTableName} ORDER BY ${db.deviceLocations.date.name} DESC) A
        GROUP BY A.${db.deviceLocations.idDevice.name}
      ) as device_data ON ${db.device.actualTableName}.${db.deviceLocations.idDevice.name} = device_data.${db.deviceLocations.idDevice.name}
      WHERE ${db.device.actualTableName}.${db.deviceLocations.idDevice.name} = ?
    ''',
    variables: [
      drift.Variable.withBigInt(idDevice),
    ],
  ).getSingle();

  return Animal(
      animal: AnimalCompanion(
        animalColor: drift.Value(data.data[db.animal.animalColor.name]),
        idDevice: drift.Value(data.data[db.animal.idDevice.name]),
        isActive: drift.Value(data.data[db.animal.isActive.name] == 1),
        animalName: drift.Value(data.data[db.animal.animalName.name]),
        idUser: drift.Value(data.data[db.animal.idUser.name]),
        animalIdentification: drift.Value(data.data[db.animal.animalIdentification.name]),
      ),
      data: [
        DeviceLocationsCompanion(
          accuracy: drift.Value(data.data['accuracy']),
          battery: drift.Value(data.data['battery']),
          dataUsage: drift.Value(data.data['data_usage']),
          date: drift.Value(data.data['date']),
          deviceDataId: drift.Value(data.data['device_data_id']),
          idDevice: drift.Value(data.data['device_id']),
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
        ${db.animal.idAnimal.name},
        ${db.animal.animalName.name},
        ${db.animal.animalIdentification.name},
        ${db.animal.animalColor.name},
        ${db.animal.actualTableName}.${db.animal.isActive.name},
        ${db.deviceLocations.deviceDataId.name},
        ${db.deviceLocations.dataUsage.name},
        ${db.deviceLocations.temperature.name},
        ${db.deviceLocations.battery.name},
        ${db.deviceLocations.lat.name},
        ${db.deviceLocations.lon.name},
        ${db.deviceLocations.elevation.name},
        ${db.deviceLocations.accuracy.name},
        ${db.deviceLocations.date.name},
        ${db.deviceLocations.state.name},
        ${db.device.actualTableName}.${db.device.idDevice.name}
      FROM ${db.animal.actualTableName}
      LEFT JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.idDevice.name} = ${db.animal.actualTableName}.${db.animal.idDevice.name}
      LEFT JOIN (
        SELECT * FROM (SELECT * FROM ${db.deviceLocations.actualTableName} ORDER BY ${db.deviceLocations.date.name} DESC) A
        GROUP BY A.${db.deviceLocations.idDevice.name}
      ) as device_data ON ${db.device.actualTableName}.${db.deviceLocations.idDevice.name} = device_data.${db.deviceLocations.idDevice.name}
    ''').get();

  List<Animal> animals = [];

  for (var deviceData in data) {
    Animal animal = Animal(
        animal: AnimalCompanion(
          animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
          idDevice: drift.Value(BigInt.from(deviceData.data[db.animal.idDevice.name])),
          isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
          animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
          idUser: drift.Value(BigInt.from(deviceData.data[db.animal.idUser.name])),
          animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
          idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
        ),
        data: [
          if (deviceData.data[db.deviceLocations.date.name] != null)
            DeviceLocationsCompanion(
              accuracy: drift.Value(deviceData.data[db.deviceLocations.accuracy.name]),
              battery: drift.Value(deviceData.data[db.deviceLocations.battery.name]),
              dataUsage: drift.Value(deviceData.data[db.deviceLocations.dataUsage.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  deviceData.data[db.deviceLocations.date.name])),
              deviceDataId:
                  drift.Value(BigInt.from(deviceData.data[db.deviceLocations.deviceDataId.name])),
              idDevice: drift.Value(BigInt.from(deviceData.data[db.device.idDevice.name])),
              elevation: drift.Value(deviceData.data[db.deviceLocations.elevation.name]),
              lat: drift.Value(deviceData.data[db.deviceLocations.lat.name]),
              lon: drift.Value(deviceData.data[db.deviceLocations.lon.name]),
              state: drift.Value(deviceData.data[db.deviceLocations.state.name]),
              temperature: drift.Value(deviceData.data[db.deviceLocations.temperature.name]),
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
        ${db.animal.idAnimal.name},
        ${db.animal.animalIdentification.name},
        ${db.animal.animalColor.name},
        ${db.animal.isActive.name},
        ${db.deviceLocations.deviceDataId.name},
        ${db.deviceLocations.dataUsage.name},
        ${db.deviceLocations.temperature.name},
        ${db.deviceLocations.battery.name},
        ${db.deviceLocations.lat.name},
        ${db.deviceLocations.lon.name},
        ${db.deviceLocations.elevation.name},
        ${db.deviceLocations.accuracy.name},
        ${db.deviceLocations.date.name},
        ${db.deviceLocations.state.name},
        ${db.device.actualTableName}.${db.device.idDevice.name}
      FROM ${db.animal.actualTableName}
      LEFT JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.idDevice.name} = ${db.animal.actualTableName}.${db.animal.idDevice.name}
      LEFT JOIN (
        SELECT * FROM
          (
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.idDevice.name}
      ) deviceData ON ${db.device.actualTableName}.${db.device.idDevice.name} = deviceData.${db.deviceLocations.idDevice.name}
      WHERE
        (deviceData.${db.deviceLocations.dataUsage.name} >= ? AND  deviceData.${db.deviceLocations.dataUsage.name} <= ? AND
        deviceData.${db.deviceLocations.temperature.name} >= ? AND deviceData.${db.deviceLocations.temperature.name} <= ? AND
        deviceData.${db.deviceLocations.battery.name} >= ? AND deviceData.${db.deviceLocations.battery.name} <= ? AND
        deviceData.${db.deviceLocations.elevation.name} >= ? AND deviceData.${db.deviceLocations.elevation.name} <= ? AND
        ${db.animal.animalIdentification.name} LIKE ?) OR (${db.animal.animalIdentification.name} LIKE ? AND deviceData.${db.deviceLocations.temperature.name} IS NULL)
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
          idDevice: drift.Value(BigInt.from(deviceData.data[db.animal.idDevice.name])),
          isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
          animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
          idUser: drift.Value(BigInt.from(deviceData.data[db.animal.idUser.name])),
          animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
          idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
        ),
        data: [
          if (deviceData.data[db.deviceLocations.date.name] != null)
            DeviceLocationsCompanion(
              accuracy: drift.Value(deviceData.data[db.deviceLocations.accuracy.name]),
              battery: drift.Value(deviceData.data[db.deviceLocations.battery.name]),
              dataUsage: drift.Value(deviceData.data[db.deviceLocations.dataUsage.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  deviceData.data[db.deviceLocations.date.name])),
              deviceDataId:
                  drift.Value(BigInt.from(deviceData.data[db.deviceLocations.deviceDataId.name])),
              idDevice: drift.Value(BigInt.from(deviceData.data[db.device.idDevice.name])),
              elevation: drift.Value(deviceData.data[db.deviceLocations.elevation.name]),
              lat: drift.Value(deviceData.data[db.deviceLocations.lat.name]),
              lon: drift.Value(deviceData.data[db.deviceLocations.lon.name]),
              state: drift.Value(deviceData.data[db.deviceLocations.state.name]),
              temperature: drift.Value(deviceData.data[db.deviceLocations.temperature.name]),
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
        ${db.animal.idAnimal.name},
        ${db.animal.animalIdentification.name},
        ${db.animal.animalColor.name},
        ${db.animal.isActive.name},
        ${db.device.isActive.name},
        ${db.deviceLocations.deviceDataId.name},
        ${db.deviceLocations.dataUsage.name},
        ${db.deviceLocations.temperature.name},
        ${db.deviceLocations.battery.name},
        ${db.deviceLocations.lat.name},
        ${db.deviceLocations.lon.name},
        ${db.deviceLocations.elevation.name},
        ${db.deviceLocations.accuracy.name},
        ${db.deviceLocations.date.name},
        ${db.deviceLocations.state.name},
        ${db.device.actualTableName}.${db.device.idDevice.name}
      FROM ${db.animal.actualTableName} 
      LEFT JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.idDevice.name} = ${db.animal.actualTableName}.${db.animal.idDevice.name}
      LEFT JOIN (
        SELECT * FROM
          (
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.idDevice.name}
      ) deviceData ON ${db.device.actualTableName}.${db.device.idDevice.name} = deviceData.${db.deviceLocations.idDevice.name}
      WHERE
        ((deviceData.${db.deviceLocations.dataUsage.name} >= ? AND  deviceData.${db.deviceLocations.dataUsage.name} <= ? AND
          deviceData.${db.deviceLocations.temperature.name} >= ? AND deviceData.${db.deviceLocations.temperature.name} <= ? AND
          deviceData.${db.deviceLocations.battery.name} >= ? AND deviceData.${db.deviceLocations.battery.name} <= ? AND
          deviceData.${db.deviceLocations.elevation.name} >= ? AND deviceData.${db.deviceLocations.elevation.name} <= ? AND
          ${db.animal.animalName.name} LIKE ?) OR 
        (${db.animal.animalName.name} LIKE ? AND deviceData.${db.deviceLocations.temperature.name} IS NULL))
        AND
        ${db.device.actualTableName}.${db.device.idDevice.name} NOT IN (
            SELECT ${db.device.idDevice.name} FROM ${db.fenceAnimals.actualTableName} 
            WHERE ${db.fenceAnimals.actualTableName}.${db.fenceAnimals.idFence.name} = ?
        )
      ORDER BY
        ${db.device.actualTableName}.${db.animal.animalName.name}
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
            idDevice: drift.Value(BigInt.from(deviceData.data[db.animal.idDevice.name])),
            isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
            animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
            idUser: drift.Value(BigInt.from(deviceData.data[db.animal.idUser.name])),
            animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
            idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
          ),
          data: [
            if (deviceData.data[db.deviceLocations.date.name] != null)
              DeviceLocationsCompanion(
                accuracy: drift.Value(deviceData.data[db.deviceLocations.accuracy.name]),
                battery: drift.Value(deviceData.data[db.deviceLocations.battery.name]),
                dataUsage: drift.Value(deviceData.data[db.deviceLocations.dataUsage.name]),
                date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                    deviceData.data[db.deviceLocations.date.name])),
                deviceDataId:
                    drift.Value(BigInt.from(deviceData.data[db.deviceLocations.deviceDataId.name])),
                idDevice: drift.Value(BigInt.from(deviceData.data[db.device.idDevice.name])),
                elevation: drift.Value(deviceData.data[db.deviceLocations.elevation.name]),
                lat: drift.Value(deviceData.data[db.deviceLocations.lat.name]),
                lon: drift.Value(deviceData.data[db.deviceLocations.lon.name]),
                state: drift.Value(deviceData.data[db.deviceLocations.state.name]),
                temperature: drift.Value(deviceData.data[db.deviceLocations.temperature.name]),
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
        ${db.animal.idAnimal.name},
        ${db.animal.isActive.name},
        ${db.device.isActive.name},
        ${db.deviceLocations.deviceDataId.name},
        ${db.deviceLocations.dataUsage.name},
        ${db.deviceLocations.temperature.name},
        ${db.deviceLocations.battery.name},
        ${db.deviceLocations.lat.name},
        ${db.deviceLocations.lon.name},
        ${db.deviceLocations.elevation.name},
        ${db.deviceLocations.accuracy.name},
        ${db.deviceLocations.date.name},
        ${db.deviceLocations.state.name},
        ${db.device.actualTableName}.${db.device.idDevice.name}
      FROM ${db.animal.actualTableName}
      LEFT JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.idDevice.name} = ${db.animal.actualTableName}.${db.animal.idDevice.name}
      LEFT JOIN (
        SELECT * FROM
          (
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.idDevice}
      ) deviceData ON ${db.device.actualTableName}.${db.device.idDevice.name} = deviceData.${db.deviceLocations.idDevice.name}
      WHERE
        (deviceData.${db.deviceLocations.dataUsage.name} >= ? AND  deviceData.${db.deviceLocations.dataUsage.name} <= ? AND
        deviceData.${db.deviceLocations.temperature.name} >= ? AND deviceData.${db.deviceLocations.temperature.name} <= ? AND
        deviceData.${db.deviceLocations.battery.name} >= ? AND deviceData.${db.deviceLocations.battery.name} <= ? AND
        deviceData.${db.deviceLocations.elevation.name} >= ? AND deviceData.${db.deviceLocations.elevation.name} <= ?
        ${db.animal.animalName.name} LIKE ?) OR 
        (${db.animal.animalName.name} LIKE ? AND deviceData.${db.deviceLocations.temperature.name} IS NULL) AND
        ${db.device.actualTableName}.${db.device.idDevice.name} NOT IN (SELECT ${db.device.idDevice.name} FROM ${db.alertDevices.actualTableName})
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
            idDevice: drift.Value(BigInt.from(deviceData.data[db.animal.idDevice.name])),
            isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
            animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
            idUser: drift.Value(BigInt.from(deviceData.data[db.animal.idUser.name])),
            animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
            idAnimal: drift.Value(BigInt.from(deviceData.data[db.animal.idAnimal.name])),
          ),
          data: [
            if (deviceData.data[db.deviceLocations.date.name] != null)
              DeviceLocationsCompanion(
                accuracy: drift.Value(deviceData.data[db.deviceLocations.accuracy.name]),
                battery: drift.Value(deviceData.data[db.deviceLocations.battery.name]),
                dataUsage: drift.Value(deviceData.data[db.deviceLocations.dataUsage.name]),
                date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                    deviceData.data[db.deviceLocations.date.name])),
                deviceDataId:
                    drift.Value(BigInt.from(deviceData.data[db.deviceLocations.deviceDataId.name])),
                idDevice: drift.Value(BigInt.from(deviceData.data[db.device.idDevice.name])),
                elevation: drift.Value(deviceData.data[db.deviceLocations.elevation.name]),
                lat: drift.Value(deviceData.data[db.deviceLocations.lat.name]),
                lon: drift.Value(deviceData.data[db.deviceLocations.lon.name]),
                state: drift.Value(deviceData.data[db.deviceLocations.state.name]),
                temperature: drift.Value(deviceData.data[db.deviceLocations.temperature.name]),
              ),
          ],
        ),
      );
    }
  }
  return devices;
}
