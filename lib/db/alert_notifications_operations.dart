import 'package:guardian/db/device_operations.dart';
import 'package:guardian/db/guardian_database.dart';
import 'package:guardian/db/user_alert_operations.dart';
import 'package:guardian/models/data_models/Alerts/alert_notifications.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/user_alert_notification.dart';

Future<List<UserAlertNotification>> getUserNotifications(String uid) async {
  final db = await GuardianDatabase.instance.database;
  final data = await db.query(
    tableAlertNotification,
    where: '${AlertNotificationFields.uid} = ?',
    whereArgs: [uid],
  );

  List<UserAlertNotification> notifications = [];

  if (data.isNotEmpty) {
    notifications.addAll(data.map((e) async {
      final alertNotification = AlertNotification.fromJson(data.first);
      UserAlert alert = (await getAlert(alertNotification.alertId))!;
      Device device = (await getDevice(alertNotification.deviceId))!;
      return UserAlertNotification(device: device, alert: alert);
    }) as Iterable<UserAlertNotification>);
  }

  return notifications;
}
