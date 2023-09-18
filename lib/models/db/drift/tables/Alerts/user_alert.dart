import 'package:drift/drift.dart';

class UserAlert extends Table {
  Int64Column get idAlert => int64()();
  BoolColumn get hasNotification => boolean()();
  TextColumn get parameter => text()();
  TextColumn get comparisson => text()();
  RealColumn get value => real()();
  @override
  Set<Column> get primaryKey => {idAlert};
}
