import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Alerts/user_alert.dart';
import 'package:guardian/models/db/drift/tables/Device/device.dart';

class AlertDevices extends Table {
  Int64Column get alertDeviceId => int64()();
  Int64Column get idDevice => int64().references(Device, #idDevice)();
  Int64Column get idAlert => int64().references(UserAlert, #idAlert)();
  @override
  Set<Column> get primaryKey => {alertDeviceId};
}
