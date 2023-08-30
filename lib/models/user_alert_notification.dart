import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/data_models/Device/device.dart';

class UserAlertNotification {
  final Device device;
  final UserAlert alert;
  final String notificationId;
  const UserAlertNotification({
    required this.device,
    required this.alert,
    required this.notificationId,
  });
}
