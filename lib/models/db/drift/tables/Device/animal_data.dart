import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/animal.dart';

/// This class represents the AnimalLocations database table
///
/// [animalDataId] is the primary key
///
/// [idAnimal] relates with the table [Animal] on its primary key
class AnimalLocations extends Table {
  TextColumn get animalDataId => text()();
  TextColumn get idAnimal => text().references(Animal, #idAnimal).nullable()();
  RealColumn get temperature => real().nullable()();
  IntColumn get battery => integer().nullable()();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  RealColumn get elevation => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get state => text().nullable()();

  @override
  Set<Column> get primaryKey => {animalDataId};
}
