import 'package:drift/drift.dart';

/// This class represents the fence database table
///
/// [idFence] is the primary key
class Fence extends Table {
  Int64Column get idFence => int64()();
  TextColumn get name => text()();
  TextColumn get color => text()();
  @override
  Set<Column> get primaryKey => {idFence};
}
