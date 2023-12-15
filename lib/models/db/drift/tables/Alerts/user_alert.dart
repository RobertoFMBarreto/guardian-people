import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/sensors.dart';

/// This class represents the UserAlert database table
///
/// [idAlert] is the primary key
class UserAlert extends Table {
  TextColumn get idAlert => text()();
  TextColumn get comparisson => text()();
  TextColumn get conditionCompTo => text()();
  IntColumn get durationSeconds => integer()();
  BoolColumn get hasNotification => boolean()();
  BoolColumn get isTimed => boolean()();
  BoolColumn get isStateParam => boolean()();
  TextColumn get parameter => text().references(Sensors, #idSensor)();
  @override
  Set<Column> get primaryKey => {idAlert};
}
