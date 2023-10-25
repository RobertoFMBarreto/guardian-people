import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/alert_notification.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

/// Method for creating an alert notification [notification] returning is as an [AlertNotificationCompanion]
Future<AlertNotificationCompanion> createAlertNotification(
    AlertNotificationCompanion notification) async {
  final db = Get.find<GuardianDb>();
  db.into(db.alertNotification).insertOnConflictUpdate(notification);

  return notification;
}

/// Method for removing all notifications
Future<void> removeAllNotifications() async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertNotification)).go();
}

/// Method for removing a single notification [notificationId]
Future<void> removeNotification(String notificationId) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertNotification)
        ..where(
          (tbl) => tbl.idNotification.equals(notificationId),
        ))
      .go();
}

/// Method for removing all notifications from an alert [idAlert]
Future<void> removeAllAlertNotifications(String idAlert) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertNotification)
        ..where(
          (tbl) => tbl.idAlert.equals(idAlert),
        ))
      .go();
}

/// Method to get all notifications as a [List<AlertNotification>]
Future<List<AlertNotification>> getAllNotifications() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT
        *
      FROM ${db.alertNotification.actualTableName}
      JOIN ${db.userAlert.actualTableName} ON ${db.userAlert.actualTableName}.${db.userAlert.idAlert.name} = ${db.alertNotification.actualTableName}.${db.alertNotification.idAlert.name}
      JOIN ${db.animal.actualTableName} ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = ${db.alertNotification.actualTableName}.${db.alertNotification.idAnimal.name}
      JOIN ${db.sensors.actualTableName} ON ${db.sensors.actualTableName}.${db.sensors.idSensor.name} = ${db.userAlert.actualTableName}.${db.userAlert.parameter.name}
    ''',
  ).get();
  List<AlertNotification> notifications = [];
  notifications.addAll(
    data.map(
      (deviceData) => AlertNotification(
        alertNotificationId: deviceData.data[db.alertNotification.idNotification.name],
        alert: UserAlertCompanion(
          idAlert: drift.Value(deviceData.data[db.userAlert.idAlert.name]),
          comparisson: drift.Value(deviceData.data[db.userAlert.comparisson.name]),
          hasNotification: drift.Value(deviceData.data[db.userAlert.hasNotification.name] == 1),
          parameter: drift.Value(deviceData.data[db.sensors.fullSensorName.name]),
          conditionCompTo: drift.Value(deviceData.data[db.userAlert.conditionCompTo.name]),
          durationSeconds: drift.Value(deviceData.data[db.userAlert.durationSeconds.name]),
          isStateParam: drift.Value(deviceData.data[db.userAlert.isStateParam.name] == 1),
          isTimed: drift.Value(deviceData.data[db.userAlert.isTimed.name] == 1),
        ),
        device: Animal(
          animal: AnimalCompanion(
            animalColor: drift.Value(deviceData.data[db.animal.animalColor.name]),
            idAnimal: drift.Value(deviceData.data[db.animal.idAnimal.name]),
            isActive: drift.Value(deviceData.data[db.animal.isActive.name] == 1),
            animalName: drift.Value(deviceData.data[db.animal.animalName.name]),
            idUser: drift.Value(deviceData.data[db.animal.idUser.name]),
            animalIdentification: drift.Value(deviceData.data[db.animal.animalIdentification.name]),
          ),
          data: [],
        ),
      ),
    ),
  );
  return notifications;
}
