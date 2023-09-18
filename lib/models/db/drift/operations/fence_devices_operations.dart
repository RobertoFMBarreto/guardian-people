import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

Future<FenceAnimalsCompanion> createFenceDevice(FenceAnimalsCompanion fenceDevice) async {
  final db = Get.find<GuardianDb>();
  db.into(db.fenceAnimals).insertOnConflictUpdate(fenceDevice);

  return fenceDevice;
}

Future<FenceData?> getAnimalFence(BigInt idAnimal) async {
  // TODO check if works
  final db = Get.find<GuardianDb>();
  final data = db
      .select(db.fenceAnimals)
      .join([drift.leftOuterJoin(db.fence, db.fence.idFence.equalsExp(db.fenceAnimals.idFence))])
    ..where(db.fenceAnimals.idAnimal.equals(idAnimal));

  final dt = await data.map((row) => row.readTable(db.fence)).getSingleOrNull();

  return dt;
}

Future<void> removeAnimalFence(BigInt idFence, BigInt idAnimal) async {
  final db = Get.find<GuardianDb>();

  (db.delete(db.fenceAnimals)
        ..where(
          (tbl) => tbl.idFence.equals(idFence) & tbl.idAnimal.equals(idAnimal),
        ))
      .go();
}

Future<void> removeAllFenceAnimals(BigInt idFence) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.fenceAnimals)
        ..where(
          (tbl) => tbl.idFence.equals(idFence),
        ))
      .go();
}

Future<List<Animal>> getFenceAnimals(BigInt idFence) async {
  final db = Get.find<GuardianDb>();
  // TODO try join
  final data = await db.customSelect(
    '''
      SELECT
        ${db.animal.actualTableName}.${db.animal.idUser.name} as deviceUid,
        ${db.animal.animalIdentification.name},
        ${db.animal.actualTableName}.${db.animal.animalColor.name} as animalColor,
        ${db.animal.actualTableName}.${db.animal.animalName.name} as animalName,
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
        ${db.device.actualTableName}.${db.device.idDevice.name} as idDevice
      FROM ${db.fence.actualTableName}
      LEFT JOIN ${db.fenceAnimals.actualTableName} ON ${db.fenceAnimals.actualTableName}.${db.fenceAnimals.idFence.name} = ${db.fence.actualTableName}.${db.fence.idFence.name}
      JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.idDevice.name} = ${db.fenceAnimals.actualTableName}.${db.fenceAnimals.idAnimal.name}
      JOIN ${db.animal.actualTableName} ON ${db.animal.actualTableName}.${db.animal.idDevice.name} = ${db.device.actualTableName}.${db.device.idDevice.name}
      JOIN (
        SELECT * FROM
          (
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.idDevice.name}
      ) deviceData ON ${db.device.actualTableName}.${db.device.idDevice.name} = deviceData.${db.deviceLocations.idDevice.name}
      WHERE
        ${db.fence.actualTableName}.${db.fence.idFence.name} = ?
      ORDER BY
        ${db.animal.actualTableName}.${db.animal.animalName.name}
    ''',
    variables: [
      drift.Variable.withBigInt(idFence),
    ],
  ).get();

  List<Animal> fenceAnimals = [];

  fenceAnimals.addAll(
    data.map(
      (deviceData) => Animal(
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
              idDevice: drift.Value(deviceData.data['idDevice']),
              elevation: drift.Value(deviceData.data[db.deviceLocations.elevation.name]),
              lat: drift.Value(deviceData.data[db.deviceLocations.lat.name]),
              lon: drift.Value(deviceData.data[db.deviceLocations.lon.name]),
              state: drift.Value(deviceData.data[db.deviceLocations.state.name]),
              temperature: drift.Value(deviceData.data[db.deviceLocations.temperature.name]),
            ),
        ],
      ),
    ),
  );

  return fenceAnimals;
}
