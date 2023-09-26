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
  Int64Column get idFence => int64().references(Fence, #idFence)();
  Int64Column get idAnimal => int64().references(Animal, #idAnimal)();

  @override
  Set<Column> get primaryKey => {idFence, idAnimal};
}
