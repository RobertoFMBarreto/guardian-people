const String tableFenceDevices = 'fence_devices';

class FenceDevicesFields {
  static const String fenceDevicesId = 'fence_devices_id';
  static const String fenceId = 'fence_id';
  static const String deviceId = 'device_id';
}

class FenceDevices {
  final String fenceId;
  final String deviceId;
  FenceDevices({
    required this.fenceId,
    required this.deviceId,
  });

  FenceDevices copy({
    String? fenceId,
    String? deviceId,
  }) =>
      FenceDevices(
        fenceId: fenceId ?? this.fenceId,
        deviceId: deviceId ?? this.deviceId,
      );

  Map<String, Object?> toJson() => {
        FenceDevicesFields.fenceId: fenceId,
        FenceDevicesFields.deviceId: deviceId,
      };

  static FenceDevices fromJson(Map<String, Object?> json) => FenceDevices(
        fenceId: json[FenceDevicesFields.fenceId] as String,
        deviceId: json[FenceDevicesFields.deviceId] as String,
      );
}
