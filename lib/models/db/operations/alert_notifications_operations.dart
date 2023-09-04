import 'package:guardian/models/db/data_models/Alerts/alert_notifications.dart';
import 'package:guardian/models/db/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/operations/guardian_database.dart';
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

Future<void> removeAllNotifications() async {
  final db = await GuardianDatabase().database;
  await db.delete(
    tableAlertNotification,
  );
}

Future<void> removeNotification(String notificationId) async {
  final db = await GuardianDatabase().database;
  await db.delete(
    tableAlertNotification,
    where: '${AlertNotificationFields.notificationId} = ?',
    whereArgs: [notificationId],
  );
}

Future<void> removeAllAlertNotifications(String alertId) async {
  final db = await GuardianDatabase().database;
  await db.delete(
    tableAlertNotification,
    where: '${AlertNotificationFields.alertId} = ?',
    whereArgs: [alertId],
  );
}

Future<List<UserAlertNotification>> getUserNotifications() async {
  final db = await GuardianDatabase().database;
  final data = await db.rawQuery(
    '''
      SELECT * FROM $tableAlertNotification
      LEFT JOIN $tableUserAlerts ON $tableUserAlerts.${UserAlertFields.alertId} = $tableAlertNotification.${AlertNotificationFields.alertId}
      LEFT JOIN $tableDevices ON $tableDevices.${DeviceFields.deviceId} = $tableAlertNotification.${AlertNotificationFields.deviceId}
    ''',
  );

  List<UserAlertNotification> notifications = [];

  if (data.isNotEmpty) {
    for (var dt in data) {
      final alertNotification = AlertNotification.fromJson(dt);
      UserAlert alert = UserAlert.fromJson(dt);
      Device device = Device.fromJson(dt);
      notifications.add(
        UserAlertNotification(
          device: device,
          alert: alert,
          notificationId: alertNotification.notificationId!,
        ),
      );
    }
  }

  return notifications;
}
