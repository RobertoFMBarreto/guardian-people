import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

Future<DeviceLocationsCompanion> createDeviceData(DeviceLocationsCompanion deviceData) async {
  final db = Get.find<GuardianDb>();
  db.into(db.deviceLocations).insertOnConflictUpdate(deviceData);
  return deviceData;
}

// Future<List<DeviceData>?> getAllDeviceData(String idDevice) async {
//   final db = await GuardianDatabase().database;
//   final data = await db.query(
//     tableDeviceData,
//     where: '${DeviceDataFields.idDevice} = ?',
//     whereArgs: [idDevice],
//   );

//   if (data.isNotEmpty) {
//     return data.map((e) => DeviceData.fromJson(e)).toList();
//   }
//   return null;
// }

Future<DeviceLocationsCompanion?> getLastDeviceData(BigInt idDevice) async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.deviceLocations)
        ..where(
          (tbl) => tbl.idDevice.equals(idDevice),
        )
        ..orderBy(
          [(tbl) => drift.OrderingTerm.desc(tbl.date)],
        ))
      .getSingleOrNull();
  return data?.toCompanion(true);
}

Future<double> getMaxElevation() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
      SELECT IFNULL(MAX(${db.deviceLocations.elevation.name}),0) AS maxElevation FROM ${db.device.actualTableName}
      LEFT JOIN ${db.deviceLocations.actualTableName} ON ${db.deviceLocations.actualTableName}.${db.deviceLocations.idDevice.name} = ${db.device.actualTableName}.${db.deviceLocations.idDevice.name}
    ''').getSingle();

  return data.data['maxElevation'];
}

Future<double> getMaxTemperature() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect('''
      SELECT IFNULL(MAX(${db.deviceLocations.temperature.name}),0) AS maxTemperature FROM ${db.device.actualTableName}
      LEFT JOIN ${db.deviceLocations.actualTableName} ON ${db.deviceLocations.actualTableName}.${db.deviceLocations.idDevice.name} = ${db.device.actualTableName}.${db.deviceLocations.idDevice.name}
    ''').getSingle();

  return double.parse(data.data['maxTemperature'].toString());
}

Future<List<DeviceLocationsCompanion>> getAnimalData({
  DateTime? startDate,
  DateTime? endDate,
  required BigInt idAnimal,
  bool isInterval = false,
}) async {
  final db = Get.find<GuardianDb>();
  List<DeviceLocationsCompanion> deviceData = [];
  List<DeviceLocation> data = [];
  if (isInterval && startDate!.difference(endDate!).inSeconds.abs() > 60) {
    final dt = await db.customSelect('''
      SELECT * FROM ${db.deviceLocations.actualTableName}
      JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.idDevice.name} = ${db.deviceLocations.actualTableName}.${db.deviceLocations.idDevice.name}
      JOIN ${db.animal.actualTableName} ON ${db.animal.actualTableName}.${db.animal.idDevice.name} = ${db.device.actualTableName}.${db.device.idDevice.name}
      WHERE ${db.animal.idAnimal.name} = ? AND ${db.deviceLocations.date.name} BETWEEN ? AND ?
      ORDER BY ${db.deviceLocations.date.name} DESC
    ''', variables: [
      drift.Variable.withBigInt(idAnimal),
      drift.Variable.withDateTime(startDate),
      drift.Variable.withDateTime(endDate)
    ]).get();
    if (dt.isNotEmpty) {
      for (var locationData in dt) {
        deviceData.add(
          DeviceLocationsCompanion(
            accuracy: drift.Value(locationData.data[db.deviceLocations.accuracy.name]),
            battery: drift.Value(locationData.data[db.deviceLocations.battery.name]),
            dataUsage: drift.Value(locationData.data[db.deviceLocations.dataUsage.name]),
            date: drift.Value(DateTime.fromMillisecondsSinceEpoch(
                locationData.data[db.deviceLocations.date.name])),
            deviceDataId:
                drift.Value(BigInt.from(locationData.data[db.deviceLocations.deviceDataId.name])),
            idDevice: drift.Value(BigInt.from(locationData.data[db.device.idDevice.name])),
            elevation: drift.Value(locationData.data[db.deviceLocations.elevation.name]),
            lat: drift.Value(locationData.data[db.deviceLocations.lat.name]),
            lon: drift.Value(locationData.data[db.deviceLocations.lon.name]),
            state: drift.Value(locationData.data[db.deviceLocations.state.name]),
            temperature: drift.Value(locationData.data[db.deviceLocations.temperature.name]),
          ),
        );
      }
    }
  } else {
    final dt = await (db.select(db.deviceLocations)
          ..orderBy(
            [(tbl) => drift.OrderingTerm.desc(db.deviceLocations.date)],
          )
          ..where(
            (tbl) => tbl.idDevice.equals(idAnimal),
          ))
        .get();
    if (dt.isNotEmpty) {
      data.add(dt.first);
    }
  }

  deviceData.addAll(data.map((e) => e.toCompanion(true)));
  return deviceData;
}
