import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Alerts/alert_notifications.dart';
import 'package:guardian/models/db/drift/tables/Alerts/alert_animals.dart';
import 'package:guardian/models/db/drift/tables/Alerts/user_alert.dart';
// import 'package:guardian/models/db/drift/tables/Device/activity_data.dart';
import 'package:guardian/models/db/drift/tables/Device/animal_activity.dart';
import 'package:guardian/models/db/drift/tables/Device/animal_data.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence_animals.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence_points.dart';
import 'package:guardian/models/db/drift/tables/animal.dart';
import 'package:guardian/models/db/drift/tables/sensors.dart';
import 'package:guardian/models/db/drift/tables/user.dart';
import 'connection/connection.dart';

part 'database.g.dart';

/// This class represents the guardian database
@DriftDatabase(tables: [
  User,
  Fence,
  FencePoints,
  FenceAnimals,
  Animal,
  AnimalLocations,
  UserAlert,
  Sensors,
  AlertNotification,
  AlertAnimals,
  ActivityData,
])
class GuardianDb extends _$GuardianDb {
  GuardianDb() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // added table animal activity
          await m.createTable(activityData);
        }
      },
    );
  }
}
