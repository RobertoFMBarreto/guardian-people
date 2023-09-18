import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

Future<List<Animal>> getProducerDevicesFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
  required BigInt idUser,
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
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC 
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.idDevice}
      ) deviceData ON ${db.device.actualTableName}.${db.device.idDevice.name} = deviceData.${db.deviceLocations.idDevice.name}
      WHERE (${db.animal.idUser.name} = ? AND
        deviceData.${db.deviceLocations.dataUsage.name} >= ? AND  deviceData.${db.deviceLocations.dataUsage.name} <= ? AND
        deviceData.${db.deviceLocations.temperature.name} >= ? AND deviceData.${db.deviceLocations.temperature.name} <= ? AND
        deviceData.${db.deviceLocations.battery.name} >= ? AND deviceData.${db.deviceLocations.battery.name} <= ? AND
        deviceData.${db.deviceLocations.elevation.name} >= ? AND deviceData.${db.deviceLocations.elevation.name} <= ? AND
        ${db.animal.animalName.name} LIKE ?) OR (${db.animal.idUser.name} = ? AND ${db.animal.animalName.name} LIKE ? AND deviceData.${db.deviceLocations.temperature.name} IS NULL)
      ORDER BY
        ${db.animal.animalName.name}
    ''',
    variables: [
      drift.Variable.withBigInt(idUser),
      drift.Variable.withInt(dtUsageRangeValues.start.toInt()),
      drift.Variable.withInt(dtUsageRangeValues.end.toInt()),
      drift.Variable.withReal(tmpRangeValues.start),
      drift.Variable.withReal(tmpRangeValues.end),
      drift.Variable.withInt(batteryRangeValues.start.toInt()),
      drift.Variable.withInt(batteryRangeValues.end.toInt()),
      drift.Variable.withReal(elevationRangeValues.start),
      drift.Variable.withReal(elevationRangeValues.end),
      drift.Variable.withString('%$searchString%'),
      drift.Variable.withBigInt(idUser),
      drift.Variable.withString('%$searchString%'),
    ],
  ).get();
  List<Animal> devices = [];

  devices.addAll(data.map((deviceData) => Animal(
        animal: AnimalCompanion(
          animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
          idDevice: drift.Value(deviceData.data[db.animal.idDevice.name]),
          isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
          animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
          idUser: drift.Value(deviceData.data[db.animal.idUser.name]),
          animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
        ),
        data: [
          if (deviceData.data[db.deviceLocations.accuracy.name] != null)
            DeviceLocationsCompanion(
              accuracy: drift.Value(deviceData.data[db.deviceLocations.accuracy.name]),
              battery: drift.Value(deviceData.data[db.deviceLocations.battery.name]),
              dataUsage: drift.Value(deviceData.data[db.deviceLocations.dataUsage.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  deviceData.data[db.deviceLocations.date.name])),
              deviceDataId: drift.Value(deviceData.data[db.deviceLocations.deviceDataId.name]),
              idDevice: drift.Value(deviceData.data[db.deviceLocations.idDevice.name]),
              elevation: drift.Value(deviceData.data[db.deviceLocations.elevation.name]),
              lat: drift.Value(deviceData.data[db.deviceLocations.lat.name]),
              lon: drift.Value(deviceData.data[db.deviceLocations.lon.name]),
              state: drift.Value(deviceData.data[db.deviceLocations.state.name]),
              temperature: drift.Value(deviceData.data[db.deviceLocations.temperature.name]),
            ),
        ],
      )));
  return devices;
}

Future<List<Animal>> getProducerDevices(BigInt idUser) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.animal)..where((tbl) => tbl.idUser.equals(idUser))).get();
  return data.map((e) => Animal(animal: e.toCompanion(true), data: [])).toList();
}
