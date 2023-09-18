import 'package:drift/drift.dart';

class Fence extends Table {
  Int64Column get idFence => int64()();
  TextColumn get name => text()();
  TextColumn get color => text()();
  @override
  Set<Column> get primaryKey => {idFence};
}
