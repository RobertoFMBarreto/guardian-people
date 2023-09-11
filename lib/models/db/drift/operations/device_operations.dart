import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';

Future<DeviceCompanion> createDevice(
  DeviceCompanion device,
) async {
  final db = Get.find<GuardianDb>();
  await db.into(db.device).insertOnConflictUpdate(device);
  return device;
}

Future<void> deleteDevice(String deviceId) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.device)..where((tbl) => tbl.deviceId.equals(deviceId))).go();
}

Future<DeviceCompanion> updateDevice(DeviceCompanion device) async {
  final db = Get.find<GuardianDb>();
  db.update(db.device).replace(device);

  return device;
}

Future<DeviceData> getDevice(String deviceId) async {
  final db = Get.find<GuardianDb>();
  final data =
      await (db.select(db.device)..where((tbl) => tbl.deviceId.equals(deviceId))).getSingle();

  return data;
}

Future<Device> getDeviceWithData(String deviceId) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT * FROM ${db.device.actualTableName}
      JOIN (
        SELECT * FROM (SELECT * FROM ${db.deviceLocations.actualTableName} ORDER BY ${db.deviceLocations.date.name} DESC) A
        GROUP BY A.${db.deviceLocations.deviceId.name}
      ) as device_data ON ${db.device.actualTableName}.${db.deviceLocations.deviceId.name} = device_data.${db.deviceLocations.deviceId.name}
      WHERE ${db.device.actualTableName}.${db.deviceLocations.deviceId.name} = ?
    ''',
    variables: [
      drift.Variable.withString(deviceId),
    ],
  ).getSingle();

  Device device = Device(
      device: DeviceCompanion(
        color: drift.Value(data.data['color']),
        deviceId: drift.Value(data.data['device_id']),
        imei: drift.Value(data.data['imei']),
        isActive: drift.Value(data.data['is_active'] == 1),
        name: drift.Value(data.data['name']),
        uid: drift.Value(data.data['uid']),
      ),
      data: [
        DeviceLocationsCompanion(
          accuracy: drift.Value(data.data['accuracy']),
          battery: drift.Value(data.data['battery']),
          dataUsage: drift.Value(data.data['data_usage']),
          date: drift.Value(data.data['date']),
          deviceDataId: drift.Value(data.data['device_data_id']),
          deviceId: drift.Value(data.data['device_id']),
          elevation: drift.Value(data.data['elevation']),
          lat: drift.Value(data.data['lat']),
          lon: drift.Value(data.data['lon']),
          state: drift.Value(data.data['state']),
          temperature: drift.Value(data.data['temperature']),
        ),
      ]);
  return device;
}

Future<List<DeviceData>> getUserDevices() async {
  final db = Get.find<GuardianDb>();

  final data = await db.select(db.device).get();

  List<Device> devices = [];
  for (var device in data) {
    final data = await (db.select(db.deviceLocations)
          ..where((tbl) => tbl.deviceId.equals(device.deviceId)))
        .get();
    Device finalDevice = Device(
        device: device.toCompanion(true), data: data.map((e) => e.toCompanion(true)).toList());
    devices.add(finalDevice);
  }

  return data;
}

Future<List<Device>> getUserDevicesWithData() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
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
      FROM ${db.device.actualTableName}
      LEFT JOIN (
        SELECT * FROM (SELECT * FROM ${db.deviceLocations.actualTableName} ORDER BY ${db.deviceLocations.date.name} DESC) A
        GROUP BY A.${db.deviceLocations.deviceId.name}
      ) as device_data ON ${db.device.actualTableName}.${db.deviceLocations.deviceId.name} = device_data.${db.deviceLocations.deviceId.name}
    ''').get();

  List<Device> devices = [];

  for (var deviceData in data) {
    Device device = Device(
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
        ]);
    devices.add(device);
  }

  return devices;
}

Future<List<Device>> getUserDevicesFiltered({
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
      FROM ${db.device.actualTableName}
      LEFT JOIN (
        SELECT * FROM
          (
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.deviceId.name}
      ) deviceData ON ${db.device.actualTableName}.${db.device.deviceId.name} = deviceData.${db.deviceLocations.deviceId.name}
      WHERE
        (deviceData.${db.deviceLocations.dataUsage.name} >= ? AND  deviceData.${db.deviceLocations.dataUsage.name} <= ? AND
        deviceData.${db.deviceLocations.temperature.name} >= ? AND deviceData.${db.deviceLocations.temperature.name} <= ? AND
        deviceData.${db.deviceLocations.battery.name} >= ? AND deviceData.${db.deviceLocations.battery.name} <= ? AND
        deviceData.${db.deviceLocations.elevation.name} >= ? AND deviceData.${db.deviceLocations.elevation.name} <= ? AND
        ${db.device.name.name} LIKE ?) OR (${db.device.name.name} LIKE ? AND deviceData.${db.deviceLocations.temperature.name} IS NULL)
      ORDER BY
        ${db.device.name.name}
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
  List<Device> devices = [];
  for (var deviceData in data) {
    Device device = Device(
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
    );

    devices.add(device);
  }

  return devices;
}

Future<double> getMaxElevation() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
      SELECT IFNULL(MAX(${db.deviceLocations.elevation.name}),0) AS maxElevation FROM ${db.device.actualTableName}
      LEFT JOIN ${db.deviceLocations.actualTableName} ON ${db.deviceLocations.actualTableName}.${db.deviceLocations.deviceId.name} = ${db.device.actualTableName}.${db.deviceLocations.deviceId.name}
    ''').getSingle();

  return data.data['maxElevation'];
}

Future<double> getMaxTemperature() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
      SELECT IFNULL(MAX(${db.deviceLocations.temperature.name}),0) AS maxTemperature FROM ${db.device.actualTableName}
      LEFT JOIN ${db.deviceLocations.actualTableName} ON ${db.deviceLocations.actualTableName}.${db.deviceLocations.deviceId.name} = ${db.device.actualTableName}.${db.deviceLocations.deviceId.name}
    ''').getSingle();

  return data.data['maxTemperature'];
}

Future<List<Device>> getUserFenceUnselectedDevicesFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
  required String fenceId,
}) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
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
      FROM ${db.device.actualTableName}
      LEFT JOIN (
        SELECT * FROM
          (
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.deviceId.name}
      ) deviceData ON ${db.device.actualTableName}.${db.device.deviceId.name} = deviceData.${db.deviceLocations.deviceId.name}
      WHERE
        ((deviceData.${db.deviceLocations.dataUsage.name} >= ? AND  deviceData.${db.deviceLocations.dataUsage.name} <= ? AND
          deviceData.${db.deviceLocations.temperature.name} >= ? AND deviceData.${db.deviceLocations.temperature.name} <= ? AND
          deviceData.${db.deviceLocations.battery.name} >= ? AND deviceData.${db.deviceLocations.battery.name} <= ? AND
          deviceData.${db.deviceLocations.elevation.name} >= ? AND deviceData.${db.deviceLocations.elevation.name} <= ? AND
          ${db.device.name.name} LIKE ?) OR 
        (${db.device.name.name} LIKE ? AND deviceData.${db.deviceLocations.temperature.name} IS NULL))
        AND
        ${db.device.actualTableName}.${db.device.deviceId.name} NOT IN (
            SELECT ${db.device.deviceId.name} FROM ${db.fenceDevices.actualTableName} 
            WHERE ${db.fenceDevices.actualTableName}.${db.fenceDevices.fenceId.name} = ?
        )
      ORDER BY
        ${db.device.actualTableName}.${db.device.name.name}
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
      drift.Variable.withString(fenceId),
    ],
  ).get();

  List<Device> devices = [];
  if (data.isNotEmpty) {
    for (var deviceData in data) {
      devices.add(Device(
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
      ));
    }
  }
  return devices;
}

Future<List<Device>> getUserAlertUnselectedDevicesFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
  required String alertId,
}) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
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
      FROM ${db.device.actualTableName}
      LEFT JOIN (
        SELECT * FROM
          (
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.deviceId}
      ) deviceData ON ${db.device.actualTableName}.${db.device.deviceId.name} = deviceData.${db.deviceLocations.deviceId.name}
      WHERE
        (deviceData.${db.deviceLocations.dataUsage.name} >= ? AND  deviceData.${db.deviceLocations.dataUsage.name} <= ? AND
        deviceData.${db.deviceLocations.temperature.name} >= ? AND deviceData.${db.deviceLocations.temperature.name} <= ? AND
        deviceData.${db.deviceLocations.battery.name} >= ? AND deviceData.${db.deviceLocations.battery.name} <= ? AND
        deviceData.${db.deviceLocations.elevation.name} >= ? AND deviceData.${db.deviceLocations.elevation.name} <= ?
        ${db.device.name.name} LIKE ?) OR 
        (${db.device.name.name} LIKE ? AND deviceData.${db.deviceLocations.temperature.name} IS NULL) AND
        ${db.device.actualTableName}.${db.device.deviceId.name} NOT IN (SELECT ${db.device.deviceId.name} FROM ${db.alertDevices.actualTableName})
      ORDER BY
        ${db.device.name.name}
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

  List<Device> devices = [];
  if (data.isNotEmpty) {
    for (var deviceData in data) {
      devices.add(Device(
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
      ));
    }
  }
  return devices;

  // !TODO: se poder ter várias fences adicionar denovo
  // $tableDevices.${DeviceFields.deviceId} NOT IN (SELECT ${DeviceFields.deviceId} FROM $tableFenceDevices WHERE ${FenceDevicesFields.fenceId} = ?)

  // final data = await db.rawQuery(
  //   '''
  //     SELECT
  //       ${DeviceFields.uid},
  //       ${DeviceFields.imei},
  //       ${DeviceFields.color},
  //       ${DeviceFields.name},
  //       ${DeviceFields.isActive},
  //       ${DeviceDataFields.dataUsage},
  //       ${DeviceDataFields.temperature},
  //       ${DeviceDataFields.battery},
  //       ${DeviceDataFields.lat},
  //       ${DeviceDataFields.lon},
  //       ${DeviceDataFields.elevation},
  //       ${DeviceDataFields.accuracy},
  //       ${DeviceDataFields.dateTime},
  //       ${DeviceDataFields.state},
  //       $tableDevices.${DeviceFields.deviceId}
  //     FROM $tableDevices
  //     LEFT JOIN (
  //       SELECT * FROM
  //         (
  //           SELECT * FROM $tableDeviceData
  //           ORDER BY ${DeviceDataFields.dateTime} DESC
  //         ) as deviceDt
  //       GROUP BY deviceDt.${DeviceDataFields.deviceId}
  //     ) deviceData ON $tableDevices.${DeviceFields.deviceId} = deviceData.${DeviceDataFields.deviceId}
  //     WHERE
  //       deviceData.${DeviceDataFields.dataUsage} >= ? AND  deviceData.${DeviceDataFields.dataUsage} <= ? AND
  //       deviceData.${DeviceDataFields.temperature} >= ? AND deviceData.${DeviceDataFields.temperature} <= ? AND
  //       deviceData.${DeviceDataFields.battery} >= ? AND deviceData.${DeviceDataFields.battery} <= ? AND
  //       deviceData.${DeviceDataFields.elevation} >= ? AND deviceData.${DeviceDataFields.elevation} <= ? AND
  //       ${DeviceFields.name} LIKE ? AND $tableDevices.${DeviceFields.deviceId} NOT IN (SELECT ${DeviceFields.deviceId} FROM $tableAlertDevices)
  //     ORDER BY
  //       ${DeviceFields.name}
  //   ''',
  //   [
  //     dtUsageRangeValues.start,
  //     dtUsageRangeValues.end,
  //     tmpRangeValues.start,
  //     tmpRangeValues.end,
  //     batteryRangeValues.start,
  //     batteryRangeValues.end,
  //     elevationRangeValues.start,
  //     elevationRangeValues.end,
  //     '%$searchString%',
  //   ],
  // );

  // List<Device> devices = [];
  // if (data.isNotEmpty) {
  //   for (var dt in data) {
  //     Device device = Device.fromJson(dt);
  //     DeviceData data = DeviceData.fromJson(dt);
  //     device.data = [data];
  //     devices.add(device);
  //   }
  // }
  // return devices;
}
