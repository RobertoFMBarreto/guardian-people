import 'package:drift/drift.dart';

class Fence extends Table {
  TextColumn get fenceId => text()();
  TextColumn get name => text()();
  TextColumn get color => text()();
  @override
  Set<Column> get primaryKey => {fenceId};
}
