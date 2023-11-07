import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';
import 'package:guardian/models/providers/api/parsers/animals_parsers.dart';

/// Method that allows to read json [body] and parse to an [UserAlertCompanion] inserting it on the database in the process
Future<void> alertsFromJson(String body) async {
  final dt = jsonDecode(body);
  await createAlert(UserAlertCompanion(
    comparisson: Value(dt['comparisson']),
    conditionCompTo: Value(dt['conditionCompTo'].toString()),
    durationSeconds: Value(dt['durationSeconds']),
    hasNotification: Value(dt['sendNotification']),
    idAlert: Value(dt['idUserAlert']),
    isStateParam: Value(dt['isStateParam']),
    isTimed: Value(dt['isTimed']),
    parameter: Value(dt['idConditionParameter']),
  ));
  await animalsFromJson(jsonEncode(dt['alertAnimals']));
  for (var animal in dt['alertAnimals']) {
    await addAlertAnimal(AlertAnimalsCompanion(
        idAnimal: Value(animal['idAnimal']), idAlert: Value(dt['idUserAlert'])));
  }
}
