import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_notifications_operations.dart';
import 'package:guardian/models/db/drift/operations/sensors_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';

Future<void> parseNotifications(String body) async {
  final data = jsonDecode(body);
  for (var dt in data) {
    await createSensor(
      SensorsCompanion(
        idSensor: Value(dt['sensor']['idSensor']),
        sensorName: Value(dt['sensor']['sensorName']),
        fullSensorName: Value(dt['sensor']['fullSensorName']),
        canAlert: Value(dt['sensor']['canAlert']),
      ),
    );

    await createAlert(
      UserAlertCompanion(
        idAlert: Value(dt['userAlert']['idUserAlert']),
        comparisson: Value(dt['userAlert']['comparisson']),
        conditionCompTo: Value(dt['userAlert']['conditionCompTo']),
        durationSeconds: Value(dt['userAlert']['durationSeconds']),
        hasNotification: Value(dt['userAlert']['sendNotification']),
        isStateParam: Value(dt['userAlert']['isStateParam']),
        isTimed: Value(dt['userAlert']['isTimed']),
        parameter: Value(dt['userAlert']['idConditionParameter']),
      ),
    );

    await createAlertNotification(AlertNotificationCompanion(
      idAlert: Value(dt['idAlert']),
      idAnimal: Value(dt['idAnimal']),
      idNotification: Value(dt['idNotification']),
    ));
  }
}
