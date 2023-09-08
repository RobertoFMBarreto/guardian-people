import 'package:drift/drift.dart';

class User extends Table {
  TextColumn get uid => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  IntColumn get phone => integer()();
  BoolColumn get isAdmin => boolean()();
  @override
  Set<Column> get primaryKey => {uid};
}
