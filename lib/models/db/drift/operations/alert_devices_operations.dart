import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/models/db/drift/query_models/animal.dart';

Future<AlertAnimalsCompanion> addAlertDevice(AlertAnimalsCompanion alertDevice) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.alertAnimals)
        ..where((tbl) =>
            tbl.idAnimal.equals(alertDevice.idAnimal.value) &
            tbl.idAlert.equals(alertDevice.idAlert.value)))
      .get();
  if (data.isEmpty) {
    db.into(db.alertAnimals).insertOnConflictUpdate(alertDevice);
  }
  return alertDevice;
}

Future<void> removeAllAlertDevices(BigInt idAlert) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertAnimals)..where((tbl) => tbl.idAlert.equals(idAlert))).go();
}

Future<void> removeAlertDevice(BigInt idAlert, BigInt idDevice) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertAnimals)
        ..where(
          (tbl) => tbl.idAlert.equals(idAlert) & tbl.idAnimal.equals(idDevice),
        ))
      .go();
}

Future<List<Animal>> getAlertDevices(BigInt idAlert) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.customSelect(
    '''
      SELECT 
        ${db.animal.idUser.name},
        ${db.animal.animalName.name},
        ${db.animal.animalIdentification.name},
        ${db.animal.animalColor.name},
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
        ${db.animal.actualTableName}.${db.animal.idAnimal.name}
      FROM ${db.alertAnimals.actualTableName}
      LEFT JOIN ${db.animal.actualTableName} ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = ${db.userAlert.actualTableName}.${db.alertAnimals.idAnimal.name}
      LEFT JOIN (
        SELECT * FROM 
          (
            SELECT * FROM ${db.animalLocations.actualTableName}
            ORDER BY ${db.animalLocations.date.name} DESC 
          ) as deviceDt
        GROUP BY deviceDt.${db.animalLocations.idAnimal.name}
      ) deviceData ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = deviceData.${db.animalLocations.idAnimal.name}
      WHERE ${db.alertAnimals.actualTableName}.${db.alertAnimals.idAlert.name} = ?
    ''',
    variables: [
      drift.Variable.withBigInt(idAlert),
    ],
  )).get();

  List<Animal> devices = [];
  devices.addAll(
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
              idAnimal: drift.Value(deviceData.data[db.animalLocations.idAnimal.name]),
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
  return devices;
}

Future<List<UserAlertCompanion>> getDeviceAlerts(BigInt idDevice) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.alertAnimals).join([
    drift.innerJoin(db.userAlert, db.userAlert.idAlert.equalsExp(db.alertAnimals.idAlert)),
  ])
        ..where(db.alertAnimals.idAnimal.equals(idDevice)))
      .get();
  List<UserAlertCompanion> alerts = [];

  alerts.addAll(
    data.map(
      (e) => UserAlertCompanion(
        idAlert: drift.Value(e.readTable(db.userAlert).idAlert),
        comparisson: drift.Value(e.readTable(db.userAlert).comparisson),
        hasNotification: drift.Value(e.readTable(db.userAlert).hasNotification),
        parameter: drift.Value(e.readTable(db.userAlert).parameter),
        value: drift.Value(e.readTable(db.userAlert).value),
      ),
    ),
  );

  return alerts;
}

Future<List<UserAlertCompanion>> getDeviceUnselectedAlerts(String idDevice) async {
  final db = Get.find<GuardianDb>();
  // final data = await (db.select(db.userAlert).join(
  //   [
  //     drift.leftOuterJoin(
  //         db.alertDevices, db.alertDevices.idAlert.equalsExp(db.alertDevices.idAlert))
  //   ],
  // )..where(db.alertDevices.idDevice.isNotValue(idDevice)))
  //     .get();

  final data = await (db.customSelect('''
      SELECT 
        ${db.userAlert.actualTableName}.${db.userAlert.idAlert.name},
        ${db.userAlert.comparisson.name},
        ${db.userAlert.parameter.name},
        ${db.userAlert.hasNotification.name},
        ${db.userAlert.value.name}
      FROM ${db.userAlert.actualTableName}
      WHERE ${db.userAlert.idAlert.name} NOT IN 
        (SELECT ${db.userAlert.idAlert.name} FROM ${db.alertAnimals.actualTableName} WHERE ${db.alertAnimals.idAnimal.name} = ?)
''', variables: [drift.Variable(idDevice)])).get();

  List<UserAlertCompanion> alerts = [];

  alerts.addAll(
    data.map(
      (e) => UserAlertCompanion(
        idAlert: drift.Value(BigInt.from(e.data[db.userAlert.idAlert.name])),
        comparisson: drift.Value(e.data[db.userAlert.comparisson.name]),
        hasNotification: drift.Value(e.data[db.userAlert.hasNotification.name] == 1),
        parameter: drift.Value(e.data[db.userAlert.parameter.name]),
        value: drift.Value(e.data[db.userAlert.value.name]),
      ),
    ),
  );

  return alerts;
}
