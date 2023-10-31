import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence.dart';

/// This class represents the FencePoints database table
///
/// [idFencePoint] is the primary key
///
/// [idFence] relates with the table [Fence] on its primary key
class FencePoints extends Table {
  TextColumn get idFencePoint => text()();
  TextColumn get idFence => text().references(Fence, #idFence)();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  BoolColumn get isCenter => boolean()();
  @override
  Set<Column> get primaryKey => {idFencePoint};
}
