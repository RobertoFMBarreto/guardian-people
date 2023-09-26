import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/user.dart';

/// This class represents the animal database table
///
/// [idAnimal] is the primary key
///
/// [idUser] relates with the table [User] on its primary key
class Animal extends Table {
  Int64Column get idAnimal => int64()();
  Int64Column get idUser => int64().references(User, #idUser)();
  TextColumn get animalIdentification => text()();
  TextColumn get animalName => text()();
  TextColumn get animalColor => text()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {idAnimal};
}
