import 'package:guardian/models/device.dart';

class Alert {
  final String color;
  final bool hasNotification;
  final String parameter;
  final String comparisson;
  final String value;
  final Device device;

  const Alert({
    required this.device,
    required this.color,
    required this.hasNotification,
    required this.parameter,
    required this.comparisson,
    required this.value,
  });
}
