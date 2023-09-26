import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Alerts/user_alert.dart';
import 'package:guardian/models/db/drift/tables/animal.dart';

/// This class represents the AlertNotification database table
///
/// [idNotification] is the primary key
///
/// [idAnimal] relates with the table [Animal] on its primary key
/// [idAlert] relates with the table [UserAlert] on its primary key
class AlertNotification extends Table {
  Int64Column get idNotification => int64()();
  Int64Column get idAnimal => int64().references(Animal, #idAnimal)();
  Int64Column get idAlert => int64().references(UserAlert, #idAlert)();

  @override
  Set<Column> get primaryKey => {idNotification};
}
