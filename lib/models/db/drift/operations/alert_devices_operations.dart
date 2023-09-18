import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/models/db/drift/query_models/animal.dart';

Future<AlertDevicesCompanion> addAlertDevice(AlertDevicesCompanion alertDevice) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.alertDevices)
        ..where((tbl) =>
            tbl.idDevice.equals(alertDevice.idDevice.value) &
            tbl.idAlert.equals(alertDevice.idAlert.value)))
      .get();
  if (data.isEmpty) {
    db.into(db.alertDevices).insertOnConflictUpdate(alertDevice);
  }
  return alertDevice;
}

Future<void> removeAllAlertDevices(BigInt idAlert) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertDevices)..where((tbl) => tbl.idAlert.equals(idAlert))).go();
}

Future<void> removeAlertDevice(BigInt idAlert, BigInt idDevice) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertDevices)
        ..where(
          (tbl) => tbl.idAlert.equals(idAlert) & tbl.idDevice.equals(idDevice),
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
      FROM ${db.alertDevices.actualTableName}
      LEFT JOIN ${db.userAlert.actualTableName} ON ${db.userAlert.actualTableName}.${db.userAlert.idAlert.name} = ${db.alertDevices.actualTableName}.${db.alertDevices.idAlert.name}
      LEFT JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.idDevice.name} = ${db.alertDevices.actualTableName}.${db.alertDevices.idDevice.name}
      LEFT JOIN ${db.animal.actualTableName} ON ${db.animal.actualTableName}.${db.animal.idDevice.name} = ${db.device.actualTableName}.${db.device.idDevice.name}
      LEFT JOIN (
        SELECT * FROM 
          (
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC 
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.idDevice.name}
      ) deviceData ON ${db.device.actualTableName}.${db.device.idDevice.name} = deviceData.${db.deviceLocations.idDevice.name}
      WHERE ${db.alertDevices.actualTableName}.${db.alertDevices.idAlert.name} = ?
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
      ),
    ),
  );
  return devices;
}

Future<List<UserAlertCompanion>> getDeviceAlerts(BigInt idDevice) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.alertDevices).join([
    drift.innerJoin(db.userAlert, db.userAlert.idAlert.equalsExp(db.alertDevices.idAlert)),
  ])
        ..where(db.alertDevices.idDevice.equals(idDevice)))
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
      LEFT JOIN ${db.alertDevices.actualTableName} ON ${db.alertDevices.actualTableName}.${db.alertDevices.idAlert.name} = ${db.userAlert.actualTableName}.${db.userAlert.idAlert.name}
      WHERE ${db.alertDevices.actualTableName}.${db.alertDevices.idDevice.name} != ? OR ${db.alertDevices.actualTableName}.${db.alertDevices.idDevice.name} IS NULL
''', variables: [drift.Variable(idDevice)])).get();

  List<UserAlertCompanion> alerts = [];

  alerts.addAll(
    data.map(
      (e) => UserAlertCompanion(
        idAlert: drift.Value(e.data[db.userAlert.idAlert.name]),
        comparisson: drift.Value(e.data[db.userAlert.comparisson.name]),
        hasNotification: drift.Value(e.data[db.userAlert.hasNotification.name] == 1),
        parameter: drift.Value(e.data[db.userAlert.parameter.name]),
        value: drift.Value(e.data[db.userAlert.value.name]),
      ),
    ),
  );

  return alerts;
}
