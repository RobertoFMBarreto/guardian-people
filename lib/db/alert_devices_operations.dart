import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/models/data_models/Alerts/alert_devices.dart';

Future<AlertDevices> addAlertDevice(AlertDevices device) async {
  final db = await GuardianDatabase.instance.database;
  final id = await db.insert(tableAlertDevices, device.toJson());

  return device.copy(id: id);
}
