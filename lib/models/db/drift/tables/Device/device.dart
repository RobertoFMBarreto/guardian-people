import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/user.dart';

class Device extends Table {
  Int64Column get idDevice => int64()();
  TextColumn get deviceName => text()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {idDevice};
}
