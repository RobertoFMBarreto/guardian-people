import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/user.dart';

/// This class represents the fence database table
///
/// [idFence] is the primary key
class Fence extends Table {
  TextColumn get idFence => text()();
  TextColumn get idUser => text().references(User, #idUser)();
  TextColumn get name => text()();
  TextColumn get color => text()();
  BoolColumn get isStayInside => boolean()();
  @override
  Set<Column> get primaryKey => {idFence};
}
