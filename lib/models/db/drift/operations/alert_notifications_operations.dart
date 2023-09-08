import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/alert_notification.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';

Future<AlertNotificationCompanion> createAlertNotification(
    AlertNotificationCompanion notification) async {
  final db = Get.find<GuardianDb>();
  db.into(db.alertNotification).insertOnConflictUpdate(notification);

  return notification;
}

Future<void> removeAllNotifications() async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertNotification)).go();
}

Future<void> removeNotification(String notificationId) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertNotification)
        ..where(
          (tbl) => tbl.notificationId.equals(notificationId),
        ))
      .go();
}

Future<void> removeAllAlertNotifications(String alertId) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertNotification)
        ..where(
          (tbl) => tbl.alertId.equals(alertId),
        ))
      .go();
}

Future<List<AlertNotification>> getUserNotifications() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT * FROM ${db.alertNotification.actualTableName}
      LEFT JOIN ${db.userAlert.actualTableName} ON ${db.userAlert.actualTableName}.${db.userAlert.alertId.name} = ${db.alertNotification.actualTableName}.${db.alertNotification.alertId.name}
      LEFT JOIN ${db.device.actualTableName} ON ${db.device.actualTableName}.${db.device.deviceId.name} = ${db.alertNotification.actualTableName}.${db.alertNotification.deviceId.name}
    ''',
  ).get();

  List<AlertNotification> notifications = [];
  notifications.addAll(
    data.map(
      (deviceData) => AlertNotification(
        alertNotificationId: deviceData.data[db.alertNotification.notificationId.name],
        alert: UserAlertCompanion(
          alertId: drift.Value(deviceData.data[db.userAlert.alertId.name]),
          comparisson: drift.Value(deviceData.data[db.userAlert.comparisson.name]),
          hasNotification: drift.Value(deviceData.data[db.userAlert.hasNotification.name]),
          parameter: drift.Value(deviceData.data[db.userAlert.parameter.name]),
          value: drift.Value(
            deviceData.data[db.userAlert.value.name],
          ),
        ),
        device: Device(
          device: DeviceCompanion(
            color: drift.Value(deviceData.data[db.device.color.name]),
            deviceId: drift.Value(deviceData.data[db.device.deviceId.name]),
            imei: drift.Value(deviceData.data[db.device.imei.name]),
            isActive: drift.Value(deviceData.data[db.device.isActive.name] == 1),
            name: drift.Value(deviceData.data[db.device.name.name]),
            uid: drift.Value(deviceData.data[db.device.uid.name]),
          ),
          data: [],
        ),
      ),
    ),
  );

  return notifications;
}
