import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';

/// Class that representa an alert notification with all relevant data [alertNotificationId], [alert], [device]
///
/// The [alert] holds all of the related alert information as [UserAlertCompanion]
///
/// The [device] holds all of the related device information with last location as [Animal]
class AlertNotification {
  final String alertNotificationId;
  final UserAlertCompanion alert;
  final Animal device;

  const AlertNotification(
      {required this.alertNotificationId, required this.alert, required this.device});
}
