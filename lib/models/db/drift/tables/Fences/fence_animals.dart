import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence.dart';
import 'package:guardian/models/db/drift/tables/animal.dart';

class FenceAnimals extends Table {
  Int64Column get idFence => int64().references(Fence, #idFence)();
  Int64Column get idAnimal => int64().references(Animal, #idAnimal)();

  @override
  Set<Column> get primaryKey => {idFence, idAnimal};
}
