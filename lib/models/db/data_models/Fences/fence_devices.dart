const String tableFenceDevices = 'fence_devices';

class FenceDeviceFields {
  static const String fenceDevicesId = 'fence_devices_id';
  static const String fenceId = 'fence_id';
  static const String deviceId = 'device_id';
}

class FenceDevice {
  final String fenceId;
  final String deviceId;
  FenceDevice({
    required this.fenceId,
    required this.deviceId,
  });

  FenceDevice copy({
    String? fenceId,
    String? deviceId,
  }) =>
      FenceDevice(
        fenceId: fenceId ?? this.fenceId,
        deviceId: deviceId ?? this.deviceId,
      );

  Map<String, Object?> toJson() => {
        FenceDeviceFields.fenceId: fenceId,
        FenceDeviceFields.deviceId: deviceId,
      };

  static FenceDevice fromJson(Map<String, Object?> json) => FenceDevice(
        fenceId: json[FenceDeviceFields.fenceId] as String,
        deviceId: json[FenceDeviceFields.deviceId] as String,
      );
}
