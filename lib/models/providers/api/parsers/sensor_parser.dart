import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/sensors_operations.dart';

Future<void> parseSensors(String body) async {
  final data = jsonDecode(body);
  for (var dt in data) {
    await createSensor(
      SensorsCompanion(
        idSensor: Value(dt['idSensor']),
        sensorName: Value(dt['sensorName']),
        fullSensorName: Value(dt['fullSensorName']),
        canAlert: Value(dt['canAlert']),
      ),
    );
  }
}
