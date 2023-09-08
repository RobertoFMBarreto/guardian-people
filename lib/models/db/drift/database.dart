import 'package:drift/drift.dart';
import 'package:guardian/models/db/drift/tables/Alerts/alert_notifications.dart';
import 'package:guardian/models/db/drift/tables/Alerts/alert_devices.dart';
import 'package:guardian/models/db/drift/tables/Alerts/user_alert.dart';
import 'package:guardian/models/db/drift/tables/Device/device.dart';
import 'package:guardian/models/db/drift/tables/Device/device_data.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence_devices.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence_points.dart';
import 'package:guardian/models/db/drift/tables/user.dart';
import 'connection.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  User,
  Fence,
  FencePoints,
  FenceDevices,
  Device,
  DeviceLocations,
  UserAlert,
  AlertNotification,
  AlertDevices,
])
class GuardianDb extends _$GuardianDb {
  GuardianDb() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
