import 'package:drift/drift.dart';

/// This class represents the user database table
///
/// [idUser] is the primary key of the table
class User extends Table {
  TextColumn get idUser => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  IntColumn? get phone => integer()();
  BoolColumn get isSuperuser => boolean()();
  BoolColumn get isProducer => boolean()();
  @override
  Set<Column> get primaryKey => {idUser};
}
