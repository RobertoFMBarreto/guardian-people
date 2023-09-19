import 'package:drift/drift.dart';

class Device extends Table {
  Int64Column get idDevice => int64()();
  TextColumn get deviceName => text()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {idDevice};
}
