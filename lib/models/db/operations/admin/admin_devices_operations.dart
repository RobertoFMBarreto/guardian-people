import 'package:flutter/material.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/data_models/Device/device_data.dart';
import 'package:guardian/models/db/operations/guardian_database.dart';

class AdminDevicesOperations {
  static Future<List<Device>> getUserDevicesFiltered({
    required RangeValues batteryRangeValues,
    required RangeValues dtUsageRangeValues,
    required RangeValues tmpRangeValues,
    required RangeValues elevationRangeValues,
    required String searchString,
    required String uid,
  }) async {
    final db = await GuardianDatabase().database;
    final data = await db.rawQuery(
      '''
      SELECT
        ${DeviceFields.uid},
        ${DeviceFields.imei},
        ${DeviceFields.color},
        ${DeviceFields.name},
        ${DeviceFields.isActive},
        ${DeviceDataFields.dataUsage},
        ${DeviceDataFields.temperature},
        ${DeviceDataFields.battery},
        ${DeviceDataFields.lat},
        ${DeviceDataFields.lon},
        ${DeviceDataFields.elevation},
        ${DeviceDataFields.accuracy},
        ${DeviceDataFields.dateTime},
        ${DeviceDataFields.state},
        $tableDevices.${DeviceFields.deviceId}
      FROM $tableDevices
      LEFT JOIN (
        SELECT * FROM 
          (
            SELECT * FROM $tableDeviceData
            ORDER BY ${DeviceDataFields.dateTime} DESC 
          ) as deviceDt
        GROUP BY deviceDt.${DeviceDataFields.deviceId}
      ) deviceData ON $tableDevices.${DeviceFields.deviceId} = deviceData.${DeviceDataFields.deviceId}
      WHERE (${DeviceFields.uid} = ? AND
        deviceData.${DeviceDataFields.dataUsage} >= ? AND  deviceData.${DeviceDataFields.dataUsage} <= ? AND
        deviceData.${DeviceDataFields.temperature} >= ? AND deviceData.${DeviceDataFields.temperature} <= ? AND
        deviceData.${DeviceDataFields.battery} >= ? AND deviceData.${DeviceDataFields.battery} <= ? AND
        deviceData.${DeviceDataFields.elevation} >= ? AND deviceData.${DeviceDataFields.elevation} <= ? AND
        ${DeviceFields.name} LIKE ?) OR (${DeviceFields.uid} = ? AND ${DeviceFields.name} LIKE ? AND deviceData.${DeviceDataFields.temperature} IS NULL)
      ORDER BY
        ${DeviceFields.name}
    ''',
      [
        uid,
        dtUsageRangeValues.start,
        dtUsageRangeValues.end,
        tmpRangeValues.start,
        tmpRangeValues.end,
        batteryRangeValues.start,
        batteryRangeValues.end,
        elevationRangeValues.start,
        elevationRangeValues.end,
        '%$searchString%',
        uid,
        '%$searchString%',
      ],
    );
    List<Device> devices = [];
    if (data.isNotEmpty) {
      for (var dt in data) {
        Device device = Device.fromJson(dt);
        // if there is device data
        if (dt['temperature'] != null) {
          DeviceData data = DeviceData.fromJson(dt);
          device.data = [data];
        }
        devices.add(device);
      }
    }
    return devices;
  }
}
