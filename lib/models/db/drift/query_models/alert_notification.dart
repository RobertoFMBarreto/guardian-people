import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';

class AlertNotification {
  final String alertNotificationId;
  final UserAlertCompanion alert;
  final Device device;

  const AlertNotification(
      {required this.alertNotificationId, required this.alert, required this.device});
}
