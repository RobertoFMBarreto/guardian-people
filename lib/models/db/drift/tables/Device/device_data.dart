import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Device/device.dart';

class DeviceLocations extends Table {
  TextColumn get deviceDataId => text()();
  TextColumn get deviceId => text().references(Device, #deviceId).nullable()();
  IntColumn get dataUsage => integer().nullable()();
  RealColumn get temperature => real().nullable()();
  IntColumn get battery => integer().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  RealColumn get elevation => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get state => text().nullable()();

  @override
  Set<Column> get primaryKey => {deviceDataId};
}
