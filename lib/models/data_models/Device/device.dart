import 'package:guardian/models/data_models/Device/device_data.dart';

const String tableDevices = 'devices';

class DeviceFields {
  static const String id = '_id';
  static const String uid = 'uid';
  static const String deviceId = 'device_id';
  static const String imei = 'imei';
  static const String color = 'color';
  static const String name = 'name';
  static const String isActive = 'is_active';
}

class Device {
  final int? id;
  final String uid;
  final String deviceId;
  final String imei;
  String color;
  String name;
  bool isActive;
  List<DeviceData>? data = [];

  Device({
    this.id,
    required this.uid,
    required this.deviceId,
    required this.imei,
    required this.color,
    required this.isActive,
    required this.name,
    this.data,
  });

  List<DeviceData> getDataBetweenDates(
      List<DeviceData> data, DateTime startDate, DateTime endDate) {
    List<DeviceData> gottenData = [];

    gottenData.addAll(
      data.where(
        (dataItem) => dataItem.dateTime.isAfter(startDate) && dataItem.dateTime.isBefore(endDate),
      ),
    );

    return gottenData;
  }

  Device copy({
    int? id,
    String? uid,
    String? deviceId,
    String? imei,
    String? color,
    String? name,
    bool? isActive,
    List<DeviceData>? data,
  }) =>
      Device(
        uid: uid ?? this.uid,
        deviceId: deviceId ?? this.deviceId,
        imei: imei ?? this.imei,
        color: color ?? this.color,
        isActive: isActive ?? this.isActive,
        name: name ?? this.name,
        data: data ?? this.data,
      );

  Map<String, Object?> toJson() => {
        DeviceFields.id: id,
        DeviceFields.deviceId: deviceId,
        DeviceFields.imei: imei,
        DeviceFields.color: color,
        DeviceFields.name: name,
        DeviceFields.isActive: isActive,
      };

  static Device fromJson(Map<String, Object?> json) => Device(
        id: json[DeviceFields.id] as int,
        uid: json[DeviceFields.uid] as String,
        deviceId: json[DeviceFields.deviceId] as String,
        imei: json[DeviceFields.imei] as String,
        color: json[DeviceFields.color] as String,
        isActive: json[DeviceFields.isActive] == 1,
        name: json[DeviceFields.name] as String,
        data: json['data'] as List<DeviceData>?,
      );
}