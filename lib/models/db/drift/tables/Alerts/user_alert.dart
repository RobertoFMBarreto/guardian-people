import 'package:drift/drift.dart';

/// This class represents the UserAlert database table
///
/// [idAlert] is the primary key
class UserAlert extends Table {
  Int64Column get idAlert => int64()();
  BoolColumn get hasNotification => boolean()();
  TextColumn get parameter => text()();
  TextColumn get comparisson => text()();
  RealColumn get value => real()();
  @override
  Set<Column> get primaryKey => {idAlert};
}
