import 'package:drift/drift.dart';

class User extends Table {
  Int64Column get idUser => int64()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  IntColumn? get phone => integer()();
  BoolColumn get isSuperuser => boolean()();
  BoolColumn get isProducer => boolean()();
  @override
  Set<Column> get primaryKey => {idUser};
}
