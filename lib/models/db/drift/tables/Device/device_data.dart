import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Device/device.dart';

class DeviceLocations extends Table {
  TextColumn get deviceDataId => text()();
  TextColumn get deviceId => text().references(Device, #deviceId)();
  IntColumn get dataUsage => integer()();
  RealColumn get temperature => real()();
  IntColumn get battery => integer()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  RealColumn get elevation => real()();
  RealColumn get accuracy => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get state => text()();

  @override
  Set<Column> get primaryKey => {deviceDataId};
}
