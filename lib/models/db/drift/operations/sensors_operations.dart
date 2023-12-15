import 'package:get/get.dart';
import 'package:guardian/models/db/drift/database.dart';

/// Method for creating a sensor [sensor] returning a [SensorsCompanion]
Future<SensorsCompanion> createSensor(SensorsCompanion sensor) async {
  final db = Get.find<GuardianDb>();

  db.into(db.sensors).insertOnConflictUpdate(sensor);
  return sensor;
}

/// Method that allows to get all alertable sensors
Future<List<Sensor>> getLocalAlertableSensors() async {
  final db = Get.find<GuardianDb>();
  final data = await (db.select(db.sensors)..where((tbl) => tbl.canAlert.equals(true))).get();
  return data;
}
