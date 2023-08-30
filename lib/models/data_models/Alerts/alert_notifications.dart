const String tableAlertNotification = 'alert_notifications';

class AlertNotificationFields {
  static const String deviceId = 'device_id';
  static const String notificationId = 'notification_id';
  static const String alertId = 'alert_id';
  static const String isDeleted = 'is_deleted';
}

class AlertNotification {
  final String deviceId;
  final String alertId;
  final bool isDeleted;
  const AlertNotification({
    required this.deviceId,
    required this.alertId,
    this.isDeleted = false,
  });

  AlertNotification copy({
    String? uid,
    String? deviceId,
    String? alertId,
    bool? isDeleted,
  }) =>
      AlertNotification(
        deviceId: deviceId ?? this.deviceId,
        alertId: alertId ?? this.alertId,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  Map<String, Object?> toJson() => {
        AlertNotificationFields.deviceId: deviceId,
        AlertNotificationFields.alertId: alertId,
        AlertNotificationFields.isDeleted: isDeleted ? 1 : 0,
      };

  static AlertNotification fromJson(Map<String, Object?> json) => AlertNotification(
        deviceId: json[AlertNotificationFields.deviceId] as String,
        alertId: json[AlertNotificationFields.alertId] as String,
        isDeleted: json[AlertNotificationFields.isDeleted] == 1,
      );
}
