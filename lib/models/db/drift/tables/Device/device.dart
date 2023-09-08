import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/user.dart';

class Device extends Table {
  TextColumn get uid => text().references(User, #uid)();
  TextColumn get deviceId => text()();
  TextColumn get imei => text()();
  TextColumn get color => text()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {deviceId};
}
