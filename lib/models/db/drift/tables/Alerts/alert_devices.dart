import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Alerts/user_alert.dart';
import 'package:guardian/models/db/drift/tables/Device/device.dart';

class AlertDevices extends Table {
  TextColumn get alertDeviceId => text()();
  TextColumn get deviceId => text().references(Device, #deviceId)();
  TextColumn get alertId => text().references(UserAlert, #alertId)();
  @override
  Set<Column> get primaryKey => {alertDeviceId};
}
