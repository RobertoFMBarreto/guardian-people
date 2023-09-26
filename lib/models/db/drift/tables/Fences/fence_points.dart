import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence.dart';

/// This class represents the FencePoints database table
///
/// [idFencePoint] is the primary key
///
/// [idFence] relates with the table [Fence] on its primary key
class FencePoints extends Table {
  Int64Column get idFencePoint => int64()();
  Int64Column get idFence => int64().references(Fence, #idFence)();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  @override
  Set<Column> get primaryKey => {idFencePoint};
}
