import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Device/device.dart';
import 'package:guardian/models/db/drift/tables/user.dart';

class Animal extends Table {
  Int64Column get idAnimal => int64()();
  Int64Column get idDevice => int64().references(Device, #idDevice)();
  Int64Column get idUser => int64().references(User, #idUser)();
  TextColumn get animalIdentification => text()();
  TextColumn get animalName => text()();
  TextColumn get animalColor => text()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column> get primaryKey => {idAnimal};
}
