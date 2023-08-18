const String tableAlertDevices = 'alert_devices';

class AlertDevicesFields {
  static const String id = '_id';
  static const String deviceId = 'deviceId';
  static const String alertId = 'alertId';
}

class AlertDevices {
  final int? id;
  final String deviceId;
  final String alertId;
  const AlertDevices({
    this.id,
    required this.deviceId,
    required this.alertId,
  });

  AlertDevices copy({
    int? id,
    String? deviceId,
    String? alertId,
  }) =>
      AlertDevices(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        alertId: alertId ?? this.alertId,
      );

  Map<String, Object?> toJson() => {
        AlertDevicesFields.id: id,
        AlertDevicesFields.deviceId: deviceId,
        AlertDevicesFields.alertId: alertId,
      };

  static AlertDevices fromJson(Map<String, Object?> json) => AlertDevices(
        id: json[AlertDevicesFields.id] as int,
        deviceId: json[AlertDevicesFields.deviceId] as String,
        alertId: json[AlertDevicesFields.alertId] as String,
      );
}
