import 'package:guardian/models/device_data.dart';

class Device {
  final int imei;
  final String color;
  final bool isBlocked;
  final List<DeviceData> data;

  const Device({
    required this.imei,
    required this.color,
    required this.isBlocked,
    required this.data,
  });
}
