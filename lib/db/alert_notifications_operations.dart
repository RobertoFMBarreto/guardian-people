import 'package:guardian/db/device_operations.dart';
import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/db/user_alert_operations.dart';
import 'package:guardian/models/data_models/Alerts/alert_notifications.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/user_alert_notification.dart';
import 'package:sqflite/sqflite.dart';

Future<AlertNotification> createAlertNotification(AlertNotification notification) async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableAlertNotification,
    where: '''${AlertNotificationFields.deviceId} = ? AND 
              ${AlertNotificationFields.alertId} = ? ''',
    whereArgs: [
      notification.deviceId,
      notification.alertId,
    ],
  );
  if (data.isEmpty) {
    await db.insert(
      tableAlertNotification,
      notification.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  return notification;
}

Future<List<UserAlertNotification>> getUserNotifications() async {
  final db = await GuardianDatabase().database;
  final data = await db.query(
    tableAlertNotification,
  );

  List<UserAlertNotification> notifications = [];

  if (data.isNotEmpty) {
    for (var dt in data) {
      final alertNotification = AlertNotification.fromJson(dt);
      UserAlert alert = (await getAlert(alertNotification.alertId))!;
      Device device = (await getDevice(alertNotification.deviceId))!;
      notifications.add(UserAlertNotification(device: device, alert: alert));
    }
  }

  return notifications;
}
