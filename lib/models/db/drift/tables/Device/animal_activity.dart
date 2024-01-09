import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/animal.dart';

/// This class represents the AnimalActivity database table
///
/// [animalDataActivityId] is the primary key
///
/// [idAnimalActivity] relates with the table [Animal] on its primary key
class AnimalActivity extends Table {
  TextColumn get animalDataActivityId => text()();
  TextColumn get idAnimalActivity => text().references(Animal, #idAnimal).nullable()();
  TextColumn get activity => text()();
  DateTimeColumn get activityDate => dateTime()();
  @override
  Set<Column> get primaryKey => {animalDataActivityId};
}
