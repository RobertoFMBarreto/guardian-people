const String tableAlertNotification = 'alert_notifications';

class AlertNotificationFields {
  static const String id = '_id';
  static const String uid = 'uid';
  static const String deviceId = 'device_id';
  static const String alertId = 'alert_id';
  static const String isDeleted = 'is_deleted';
}

class AlertNotification {
  final int? id;
  final String uid;
  final String deviceId;
  final String alertId;
  final bool isDeleted;
  const AlertNotification({
    this.id,
    required this.uid,
    required this.deviceId,
    required this.alertId,
    required this.isDeleted,
  });

  AlertNotification copy({
    int? id,
    String? uid,
    String? deviceId,
    String? alertId,
    bool? isDeleted,
  }) =>
      AlertNotification(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        deviceId: deviceId ?? this.deviceId,
        alertId: alertId ?? this.alertId,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  Map<String, Object?> toJson() => {
        AlertNotificationFields.id: id,
        AlertNotificationFields.uid: uid,
        AlertNotificationFields.deviceId: deviceId,
        AlertNotificationFields.alertId: alertId,
        AlertNotificationFields.isDeleted: isDeleted,
      };

  static AlertNotification fromJson(Map<String, Object?> json) => AlertNotification(
        id: json[AlertNotificationFields.id] as int,
        uid: json[AlertNotificationFields.uid] as String,
        deviceId: json[AlertNotificationFields.deviceId] as String,
        alertId: json[AlertNotificationFields.alertId] as String,
        isDeleted: json[AlertNotificationFields.isDeleted] as bool,
      );
}
