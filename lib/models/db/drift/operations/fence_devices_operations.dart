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
        ${db.animal.actualTableName}.${db.animal.idAnimal.name} as idDevice
      FROM ${db.fence.actualTableName}
      LEFT JOIN ${db.fenceAnimals.actualTableName} ON ${db.fenceAnimals.actualTableName}.${db.fenceAnimals.idFence.name} = ${db.fence.actualTableName}.${db.fence.idFence.name}
      JOIN ${db.animal.actualTableName} ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = ${db.fenceAnimals.actualTableName}.${db.fenceAnimals.idAnimal.name}
      JOIN (
        SELECT * FROM
          (
            SELECT * FROM ${db.animalLocations.actualTableName}
            ORDER BY ${db.animalLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.animalLocations.idAnimal.name}
      ) deviceData ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = deviceData.${db.animalLocations.idAnimal.name}
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
              dataUsage: drift.Value(deviceData.data[db.animalLocations.dataUsage.name]),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                  deviceData.data[db.animalLocations.date.name])),
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
    ),
  );

  return fenceAnimals;
}
