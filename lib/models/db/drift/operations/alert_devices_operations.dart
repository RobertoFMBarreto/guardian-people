import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/models/db/drift/query_models/device.dart';

Future<AlertDevicesCompanion> addAlertDevice(AlertDevicesCompanion alertDevice) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.alertDevices)
        ..where((tbl) =>
            tbl.deviceId.equals(alertDevice.deviceId.value) &
            tbl.alertId.equals(alertDevice.alertId.value)))
      .get();
  if (data.isEmpty) {
    db.into(db.alertDevices).insertOnConflictUpdate(alertDevice);
  }
  return alertDevice;
}

Future<void> removeAllAlertDevices(String alertId) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertDevices)..where((tbl) => tbl.alertId.equals(alertId))).go();
}

Future<void> removeAlertDevice(String alertId, String deviceId) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertDevices)
        ..where(
          (tbl) => tbl.alertId.equals(alertId) & tbl.deviceId.equals(deviceId),
        ))
      .go();
}

Future<List<Device>> getAlertDevices(String alertId) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.customSelect(
    '''
      SELECT 
        ${db.device.uid.name},
        ${db.device.imei.name},
        ${db.device.color.name},
        ${db.device.name.name},
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
        ${db.device.actualTableName}.${db.device.deviceId.name}
      FROM ${db.alertDevices.actualTableName}
      LEFT JOIN ${db.userAlert.actualTableName} ON ${db.userAlert.actualTableName}.${db.userAlert.alertId.name} = ${db.alertDevices.actualTableName}.${db.alertDevices.alertId.name}
      LEFT JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.deviceId.name} = ${db.alertDevices.actualTableName}.${db.alertDevices.deviceId.name}
      LEFT JOIN (
        SELECT * FROM 
          (
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC 
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.deviceId.name}
      ) deviceData ON ${db.device.actualTableName}.${db.device.deviceId.name} = deviceData.${db.deviceLocations.deviceId.name}
      WHERE ${db.alertDevices.actualTableName}.${db.alertDevices.alertId.name} = ?
    ''',
    variables: [
      drift.Variable.withString(alertId),
    ],
  )).get();

  List<Device> devices = [];
  devices.addAll(
    data.map(
      (deviceData) => Device(
        device: DeviceCompanion(
          color: drift.Value(deviceData.data['color']),
          deviceId: drift.Value(deviceData.data['device_id']),
          imei: drift.Value(deviceData.data['imei']),
          isActive: drift.Value(deviceData.data['is_active'] == 1),
          name: drift.Value(deviceData.data['name']),
          uid: drift.Value(deviceData.data['uid']),
        ),
        data: [
          if (deviceData.data['accuracy'] != null)
            DeviceLocationsCompanion(
              accuracy: drift.Value(deviceData.data['accuracy']),
              battery: drift.Value(deviceData.data['battery']),
              dataUsage: drift.Value(deviceData.data['data_usage']),
              date: drift.Value(DateTime.fromMillisecondsSinceEpoch(deviceData.data['date'])),
              deviceDataId: drift.Value(deviceData.data['device_data_id']),
              deviceId: drift.Value(deviceData.data['device_id']),
              elevation: drift.Value(deviceData.data['elevation']),
              lat: drift.Value(deviceData.data['lat']),
              lon: drift.Value(deviceData.data['lon']),
              state: drift.Value(deviceData.data['state']),
              temperature: drift.Value(deviceData.data['temperature']),
            ),
        ],
      ),
    ),
  );
  return devices;
}

Future<List<UserAlertCompanion>> getDeviceAlerts(String deviceId) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.alertDevices).join([
    drift.innerJoin(db.userAlert, db.userAlert.alertId.equalsExp(db.alertDevices.alertId)),
  ])
        ..where(db.alertDevices.deviceId.equals(deviceId)))
      .get();
  List<UserAlertCompanion> alerts = [];

  alerts.addAll(
    data.map(
      (e) => UserAlertCompanion(
        alertId: drift.Value(e.readTable(db.userAlert).alertId),
        comparisson: drift.Value(e.readTable(db.userAlert).comparisson),
        hasNotification: drift.Value(e.readTable(db.userAlert).hasNotification),
        parameter: drift.Value(e.readTable(db.userAlert).parameter),
        value: drift.Value(e.readTable(db.userAlert).value),
      ),
    ),
  );

  return alerts;
}

Future<List<UserAlertCompanion>> getDeviceUnselectedAlerts(String deviceId) async {
  final db = Get.find<GuardianDb>();
  // final data = await (db.select(db.userAlert).join(
  //   [
  //     drift.leftOuterJoin(
  //         db.alertDevices, db.alertDevices.alertId.equalsExp(db.alertDevices.alertId))
  //   ],
  // )..where(db.alertDevices.deviceId.isNotValue(deviceId)))
  //     .get();

  final data = await (db.customSelect('''
      SELECT 
        ${db.userAlert.actualTableName}.${db.userAlert.alertId.name},
        ${db.userAlert.comparisson.name},
        ${db.userAlert.parameter.name},
        ${db.userAlert.hasNotification.name},
        ${db.userAlert.value.name}
      FROM ${db.userAlert.actualTableName}
      LEFT JOIN ${db.alertDevices.actualTableName} ON ${db.alertDevices.actualTableName}.${db.alertDevices.alertId.name} = ${db.userAlert.actualTableName}.${db.userAlert.alertId.name}
      WHERE ${db.alertDevices.actualTableName}.${db.alertDevices.deviceId.name} != ? OR ${db.alertDevices.actualTableName}.${db.alertDevices.deviceId.name} IS NULL
''', variables: [drift.Variable(deviceId)])).get();

  print('data: ${data.first.data}');

  List<UserAlertCompanion> alerts = [];

  alerts.addAll(
    data.map(
      (e) => UserAlertCompanion(
        alertId: drift.Value(e.data[db.userAlert.alertId.name]),
        comparisson: drift.Value(e.data[db.userAlert.comparisson.name]),
        hasNotification: drift.Value(e.data[db.userAlert.hasNotification.name] == 1),
        parameter: drift.Value(e.data[db.userAlert.parameter.name]),
        value: drift.Value(e.data[db.userAlert.value.name]),
      ),
    ),
  );

  return alerts;
}
