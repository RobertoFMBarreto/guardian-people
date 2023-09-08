import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';

Future<List<Device>> getProducerDevicesFiltered({
  required RangeValues batteryRangeValues,
  required RangeValues dtUsageRangeValues,
  required RangeValues tmpRangeValues,
  required RangeValues elevationRangeValues,
  required String searchString,
  required String uid,
}) async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT
        *
      FROM ${db.device.actualTableName}
      LEFT JOIN (
        SELECT * FROM 
          (
            SELECT * FROM ${db.deviceLocations.actualTableName}
            ORDER BY ${db.deviceLocations.date.name} DESC 
          ) as deviceDt
        GROUP BY deviceDt.${db.deviceLocations.deviceId}
      ) deviceData ON ${db.device.actualTableName}.${db.device.deviceId.name} = deviceData.${db.deviceLocations.deviceId.name}
      WHERE (${db.device.uid.name} = ? AND
        deviceData.${db.deviceLocations.dataUsage.name} >= ? AND  deviceData.${db.deviceLocations.dataUsage.name} <= ? AND
        deviceData.${db.deviceLocations.temperature.name} >= ? AND deviceData.${db.deviceLocations.temperature.name} <= ? AND
        deviceData.${db.deviceLocations.battery.name} >= ? AND deviceData.${db.deviceLocations.battery.name} <= ? AND
        deviceData.${db.deviceLocations.elevation.name} >= ? AND deviceData.${db.deviceLocations.elevation.name} <= ? AND
        ${db.device.name.name} LIKE ?) OR (${db.device.uid.name} = ? AND ${db.device.name.name} LIKE ? AND deviceData.${db.deviceLocations.temperature.name} IS NULL)
      ORDER BY
        ${db.device.name.name}
    ''',
    variables: [
      drift.Variable.withString(uid),
      drift.Variable.withInt(dtUsageRangeValues.start.toInt()),
      drift.Variable.withInt(dtUsageRangeValues.end.toInt()),
      drift.Variable.withReal(tmpRangeValues.start),
      drift.Variable.withReal(tmpRangeValues.end),
      drift.Variable.withInt(batteryRangeValues.start.toInt()),
      drift.Variable.withInt(batteryRangeValues.end.toInt()),
      drift.Variable.withReal(elevationRangeValues.start),
      drift.Variable.withReal(elevationRangeValues.end),
      drift.Variable.withString('%$searchString%'),
      drift.Variable.withString(uid),
      drift.Variable.withString('%$searchString%'),
    ],
  ).get();
  List<Device> devices = [];

  devices.addAll(data.map((deviceData) => Device(
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
      )));
  return devices;
}

Future<List<Device>> getProducerDevices(String uid) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.device)..where((tbl) => tbl.uid.equals(uid))).get();
  return data.map((e) => Device(device: e.toCompanion(true), data: [])).toList();
}
