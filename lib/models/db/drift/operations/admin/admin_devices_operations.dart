import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

/// Allows to get a producer [idUser] animals filtered
///
/// The animals can be filtered by ranges: [batteryRangeValues], [dtUsageRangeValues], [tmpRangeValues], [elevationRangeValues]
///
/// With the [searchString] these animals are searched by name
///
/// Finally returns [Future<List<Animal>>] with all animals filtered
Future<List<Animal>> getProducerAnimalsFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
  required String idUser,
}) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT
        *
      FROM ${db.animal.actualTableName}
      LEFT JOIN (
        SELECT * FROM 
          (
            SELECT * FROM ${db.animalLocations.actualTableName}
            ORDER BY ${db.animalLocations.date.name} DESC 
          ) as deviceDt
        GROUP BY deviceDt.${db.animalLocations.idAnimal}
      ) deviceData ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = deviceData.${db.animalLocations.idAnimal.name}
      WHERE (${db.animal.idUser.name} = ? AND
        deviceData.${db.animalLocations.temperature.name} >= ? AND deviceData.${db.animalLocations.temperature.name} <= ? AND
        deviceData.${db.animalLocations.battery.name} >= ? AND deviceData.${db.animalLocations.battery.name} <= ? AND
        deviceData.${db.animalLocations.elevation.name} >= ? AND deviceData.${db.animalLocations.elevation.name} <= ? AND
        ${db.animal.animalName.name} LIKE ?) OR (${db.animal.idUser.name} = ? AND ${db.animal.animalName.name} LIKE ? AND deviceData.${db.animalLocations.temperature.name} IS NULL)
      ORDER BY
        ${db.animal.animalName.name}
    ''',
    variables: [
      drift.Variable.withString(idUser),
      drift.Variable.withInt(dtUsageRangeValues.start.toInt()),
      drift.Variable.withInt(dtUsageRangeValues.end.toInt()),
      drift.Variable.withReal(tmpRangeValues.start),
      drift.Variable.withReal(tmpRangeValues.end),
      drift.Variable.withInt(batteryRangeValues.start.toInt()),
      drift.Variable.withInt(batteryRangeValues.end.toInt()),
      drift.Variable.withReal(elevationRangeValues.start),
      drift.Variable.withReal(elevationRangeValues.end),
      drift.Variable.withString('%$searchString%'),
      drift.Variable.withString(idUser),
      drift.Variable.withString('%$searchString%'),
    ],
  ).get();
  List<Animal> devices = [];

  devices.addAll(data.map((deviceData) => Animal(
        animal: AnimalCompanion(
          animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
          idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
          isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
          animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
          idUser: drift.Value(deviceData.data[db.animal.idUser.name]),
          animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
        ),
        data: [
          if (deviceData.data[db.animalLocations.accuracy.name] != null)
            AnimalLocationsCompanion(
              accuracy: drift.Value(deviceData.data[db.animalLocations.accuracy.name]),
              battery: drift.Value(deviceData.data[db.animalLocations.battery.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  deviceData.data[db.animalLocations.date.name] * 1000)),
              animalDataId: drift.Value(deviceData.data[db.animalLocations.animalDataId.name]),
              idAnimal: drift.Value(deviceData.data[db.animalLocations.idAnimal.name]),
              elevation: drift.Value(deviceData.data[db.animalLocations.elevation.name]),
              lat: drift.Value(deviceData.data[db.animalLocations.lat.name]),
              lon: drift.Value(deviceData.data[db.animalLocations.lon.name]),
              state: drift.Value(deviceData.data[db.animalLocations.state.name]),
              temperature: drift.Value(deviceData.data[db.animalLocations.temperature.name]),
            ),
        ],
      )));
  return devices;
}

/// Allows to get all producer animals from the user [idUser]
///
/// Finally returns [Future<List<Animal>>] with all the producer animals
Future<List<Animal>> getProducerAnimals(String idUser) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.animal)..where((tbl) => tbl.idUser.equals(idUser))).get();
  return data.map((e) => Animal(animal: e.toCompanion(true), data: [])).toList();
}
