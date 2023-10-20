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
  TextColumn get idNotification => text()();
  TextColumn get idAnimal => text().references(Animal, #idAnimal)();
  TextColumn get idAlert => text().references(UserAlert, #idAlert)();

  @override
  Set<Column> get primaryKey => {idNotification};
}
