import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Alerts/user_alert.dart';
import 'package:guardian/models/db/drift/tables/animal.dart';

class AlertAnimals extends Table {
  Int64Column get alertAnimalId => int64()();
  Int64Column get idAnimal => int64().references(Animal, #idAnimal)();
  Int64Column get idAlert => int64().references(UserAlert, #idAlert)();
  @override
  Set<Column> get primaryKey => {alertAnimalId};
}
