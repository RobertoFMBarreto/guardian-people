const String tableAlertDevices = 'alert_devices';

class AlertDeviceFields {
  static const String alertDevicesId = 'alert_devices_id';
  static const String deviceId = 'device_id';
  static const String alertId = 'alert_id';
}

class AlertDevice {
  final String deviceId;
  final String alertId;
  const AlertDevice({
    required this.deviceId,
    required this.alertId,
  });

  AlertDevice copy({
    String? deviceId,
    String? alertId,
  }) =>
      AlertDevice(
        deviceId: deviceId ?? this.deviceId,
        alertId: alertId ?? this.alertId,
      );

  Map<String, Object?> toJson() => {
        AlertDeviceFields.deviceId: deviceId,
        AlertDeviceFields.alertId: alertId,
      };

  static AlertDevice fromJson(Map<String, Object?> json) => AlertDevice(
        deviceId: json[AlertDeviceFields.deviceId] as String,
        alertId: json[AlertDeviceFields.alertId] as String,
      );
}
