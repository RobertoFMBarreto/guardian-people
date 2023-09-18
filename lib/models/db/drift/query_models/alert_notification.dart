import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

class AlertNotification {
  final BigInt alertNotificationId;
  final UserAlertCompanion alert;
  final Animal device;

  const AlertNotification(
      {required this.alertNotificationId, required this.alert, required this.device});
}
