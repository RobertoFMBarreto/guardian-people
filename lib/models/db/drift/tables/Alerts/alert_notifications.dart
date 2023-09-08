import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Alerts/user_alert.dart';
import 'package:guardian/models/db/drift/tables/Device/device.dart';

class AlertNotification extends Table {
  TextColumn get notificationId => text()();
  TextColumn get deviceId => text().references(Device, #deviceId)();
  TextColumn get alertId => text().references(UserAlert, #alertId)();

  @override
  Set<Column> get primaryKey => {notificationId};
}
