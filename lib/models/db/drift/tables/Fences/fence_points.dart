import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence.dart';

class FencePoints extends Table {
  TextColumn get fenceId => text().references(Fence, #fenceId)();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
}
