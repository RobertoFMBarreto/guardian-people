const String tableAlertDevices = 'alert_devices';

class AlertDevicesFields {
  static const String alertDevicesId = 'alert_devices_id';
  static const String deviceId = 'device_id';
  static const String alertId = 'alert_id';
}

class AlertDevices {
  final String deviceId;
  final String alertId;
  const AlertDevices({
    required this.deviceId,
    required this.alertId,
  });

  AlertDevices copy({
    String? deviceId,
    String? alertId,
  }) =>
      AlertDevices(
        deviceId: deviceId ?? this.deviceId,
        alertId: alertId ?? this.alertId,
      );

  Map<String, Object?> toJson() => {
        AlertDevicesFields.deviceId: deviceId,
        AlertDevicesFields.alertId: alertId,
      };

  static AlertDevices fromJson(Map<String, Object?> json) => AlertDevices(
        deviceId: json[AlertDevicesFields.deviceId] as String,
        alertId: json[AlertDevicesFields.alertId] as String,
      );
}
