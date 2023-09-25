import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/alert_notification.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

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

Future<void> removeNotification(BigInt notificationId) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertNotification)
        ..where(
          (tbl) => tbl.idNotification.equals(notificationId),
        ))
      .go();
}

Future<void> removeAllAlertNotifications(BigInt idAlert) async {
  final db = Get.find<GuardianDb>();
  (db.delete(db.alertNotification)
        ..where(
          (tbl) => tbl.idAlert.equals(idAlert),
        ))
      .go();
}

Future<List<AlertNotification>> getUserNotifications() async {
  final db = Get.find<GuardianDb>();
  final data = await db.customSelect(
    '''
      SELECT
        *
      FROM ${db.alertNotification.actualTableName}
      LEFT JOIN ${db.userAlert.actualTableName} ON ${db.userAlert.actualTableName}.${db.userAlert.idAlert.name} = ${db.alertNotification.actualTableName}.${db.alertNotification.idAlert.name}
      LEFT JOIN ${db.animal.actualTableName} ON ${db.animal.actualTableName}.${db.animal.idAnimal.name} = ${db.alertNotification.actualTableName}.${db.alertNotification.idAnimal.name}
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
          hasNotification: drift.Value(deviceData.data[db.userAlert.hasNotification.name]),
          parameter: drift.Value(deviceData.data[db.userAlert.parameter.name]),
          value: drift.Value(
            deviceData.data[db.userAlert.value.name],
          ),
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
