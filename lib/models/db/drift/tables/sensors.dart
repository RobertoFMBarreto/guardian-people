import 'package:drift/drift.dart';

/// This class represents the sensor database table
///
/// [idSensor] is the primary key of the table
class Sensors extends Table {
  TextColumn get idSensor => text()();
  TextColumn get sensorName => text()();
  TextColumn get fullSensorName => text()();
  BoolColumn get canAlert => boolean()();
  @override
  Set<Column> get primaryKey => {idSensor};
}
