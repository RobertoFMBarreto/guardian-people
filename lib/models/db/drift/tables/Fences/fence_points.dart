import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence.dart';

class FencePoints extends Table {
  Int64Column get idFencePoint => int64()();
  Int64Column get idFence => int64().references(Fence, #idFence)();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  @override
  Set<Column> get primaryKey => {idFencePoint};
}
