import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/animal.dart';

class ActivityData extends Table {
  TextColumn get idActivityData => text()();
  TextColumn get idAnimal => text().references(Animal, #idAnimal)();
  TextColumn get activity => text()();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {idActivityData};
}
