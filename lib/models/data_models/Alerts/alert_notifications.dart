const String tableAlertNotification = 'alert_notifications';

class AlertNotificationFields {
  static const String uid = 'uid';
  static const String deviceId = 'device_id';
  static const String notificationId = 'notification_id';
  static const String alertId = 'alert_id';
  static const String isDeleted = 'is_deleted';
}

class AlertNotification {
  final String uid;
  final String deviceId;
  final String alertId;
  final bool isDeleted;
  const AlertNotification({
    required this.uid,
    required this.deviceId,
    required this.alertId,
    required this.isDeleted,
  });

  AlertNotification copy({
    String? uid,
    String? deviceId,
    String? alertId,
    bool? isDeleted,
  }) =>
      AlertNotification(
        uid: uid ?? this.uid,
        deviceId: deviceId ?? this.deviceId,
        alertId: alertId ?? this.alertId,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  Map<String, Object?> toJson() => {
        AlertNotificationFields.uid: uid,
        AlertNotificationFields.deviceId: deviceId,
        AlertNotificationFields.alertId: alertId,
        AlertNotificationFields.isDeleted: isDeleted ? 1 : 0,
      };

  static AlertNotification fromJson(Map<String, Object?> json) => AlertNotification(
        uid: json[AlertNotificationFields.uid] as String,
        deviceId: json[AlertNotificationFields.deviceId] as String,
        alertId: json[AlertNotificationFields.alertId] as String,
        isDeleted: json[AlertNotificationFields.isDeleted] == 1,
      );
}