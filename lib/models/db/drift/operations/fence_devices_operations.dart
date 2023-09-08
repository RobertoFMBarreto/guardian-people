import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';

Future<FenceDevicesCompanion> createFenceDevice(FenceDevicesCompanion fenceDevice) async {
  final db = Get.find<GuardianDb>();
  db.into(db.fenceDevices).insertOnConflictUpdate(fenceDevice);

  return fenceDevice;
}

Future<FenceData?> getDeviceFence(String deviceId) async {
  // TODO check if works
  final db = Get.find<GuardianDb>();
  final data = db
      .select(db.fenceDevices)
      .join([drift.leftOuterJoin(db.fence, db.fence.fenceId.equalsExp(db.fenceDevices.fenceId))])
    ..where(db.fenceDevices.deviceId.equals(deviceId));

  final dt = await data.map((row) => row.readTable(db.fence)).getSingleOrNull();

  return dt;
}

Future<void> removeDeviceFence(String fenceId, String deviceId) async {
  final db = Get.find<GuardianDb>();

  (db.delete(db.fenceDevices)
        ..where(
          (tbl) => tbl.fenceId.equals(fenceId) & tbl.deviceId.equals(deviceId),
        ))
      .go();
}

Future<void> removeAllFenceDevices(String fenceId) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.fenceDevices)
        ..where(
          (tbl) => tbl.fenceId.equals(fenceId),
        ))
      .go();
}

Future<List<Device>> getFenceDevices(String fenceId) async {
  final db = Get.find<GuardianDb>();
  // TODO try join
  final data = await db.customSelect(
    '''
      SELECT
        ${db.device.actualTableName}.${db.device.uid.name},
        ${db.device.imei.name},
        ${db.device.actualTableName}.${db.device.color.name} as deviceColor,
        ${db.device.actualTableName}.${db.device.name.name},
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
      FROM ${db.fence.actualTableName}
      LEFT JOIN ${db.fenceDevices.actualTableName} ON ${db.fenceDevices.actualTableName}.${db.fenceDevices.fenceId.name} = ${db.fence.actualTableName}.${db.fence.fenceId.name}
      LEFT JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.deviceId.name} = ${db.fenceDevices.actualTableName}.${db.fenceDevices.deviceId.name}
      LEFT JOIN (
        SELECT * FROM
          (
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.deviceId.name}
      ) deviceData ON ${db.device.actualTableName}.${db.device.deviceId.name} = deviceData.${db.deviceLocations.deviceId.name}
      WHERE
        ${db.fence.actualTableName}.${db.fence.fenceId.name} = ?
      ORDER BY
        ${db.device.actualTableName}.${db.device.name.name}
    ''',
    variables: [
      drift.Variable.withString(fenceId),
    ],
  ).get();

  List<Device> fenceDevices = [];

  fenceDevices.addAll(
    data.map(
      (deviceData) => Device(
        device: DeviceCompanion(
          color: drift.Value(deviceData.data['deviceColor']),
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

  return fenceDevices;
}
