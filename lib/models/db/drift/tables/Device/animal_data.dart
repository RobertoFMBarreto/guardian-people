import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/animal.dart';

class AnimalLocations extends Table {
  Int64Column get animalDataId => int64()();
  Int64Column get idAnimal => int64().references(Animal, #idAnimal).nullable()();
  IntColumn get dataUsage => integer().nullable()();
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
