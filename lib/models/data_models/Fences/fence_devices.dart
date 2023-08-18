const String tableFenceDevices = 'fence_devices';

class FenceDevicesFields {
  static const String id = '_id';
  static const String fenceId = 'fence_id';
  static const String deviceId = 'device_id';
}

class FenceDevices {
  final int? id;
  final String fenceId;
  final String deviceId;
  FenceDevices({
    required this.id,
    required this.fenceId,
    required this.deviceId,
  });

  FenceDevices copy({
    int? id,
    String? fenceId,
    String? deviceId,
  }) =>
      FenceDevices(
        id: id ?? this.id,
        fenceId: fenceId ?? this.fenceId,
        deviceId: deviceId ?? this.deviceId,
      );

  Map<String, Object?> toJson() => {
        FenceDevicesFields.id: id,
        FenceDevicesFields.fenceId: fenceId,
        FenceDevicesFields.deviceId: deviceId,
      };

  static FenceDevices fromJson(Map<String, Object?> json) => FenceDevices(
        id: json[FenceDevicesFields.id] as int,
        fenceId: json[FenceDevicesFields.fenceId] as String,
        deviceId: json[FenceDevicesFields.deviceId] as String,
      );
}
