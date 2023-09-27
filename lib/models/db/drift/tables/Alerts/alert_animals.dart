import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Alerts/user_alert.dart';
import 'package:guardian/models/db/drift/tables/animal.dart';

/// This class represents the AlertAnimals database table
///
/// [idAnimal] and [idAlert] are the primary keys
///
/// [idAnimal] relates with the table [Animal] on its primary key
/// [idAlert] relates with the table [UserAlert] on its primary key
class AlertAnimals extends Table {
  Int64Column get idAnimal => int64().references(Animal, #idAnimal)();
  Int64Column get idAlert => int64().references(UserAlert, #idAlert)();
  @override
  Set<Column> get primaryKey => {idAnimal, idAlert};
}
