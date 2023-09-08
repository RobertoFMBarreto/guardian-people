import 'package:drift/drift.dart';

class UserAlert extends Table {
  TextColumn get alertId => text()();
  BoolColumn get hasNotification => boolean()();
  TextColumn get parameter => text()();
  TextColumn get comparisson => text()();
  RealColumn get value => real()();
  @override
  Set<Column> get primaryKey => {alertId};
}
