import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence.dart';
import 'package:guardian/models/db/drift/tables/animal.dart';

/// This class represents the FenceAnimals database table
///
/// [idFence] and [idAnimal] are the primary keys
///
/// [idFence] relates with the table [Fence] on its primary key
/// [idAnimal] relates with the table [Animal] on its primary key
class FenceAnimals extends Table {
  TextColumn get idFence => text().references(Fence, #idFence)();
  TextColumn get idAnimal => text().references(Animal, #idAnimal)();

  @override
  Set<Column> get primaryKey => {idFence, idAnimal};
}
