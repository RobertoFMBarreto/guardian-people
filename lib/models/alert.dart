import 'package:guardian/models/device.dart';

enum AlertComparissons {
  equal,
  more,
  less,
  moreOrEqual,
  lessOrEqual,
}

enum AlertParameter {
  temperature,
  dataUsage,
  battery,
}

extension ParseCmpToString on AlertComparissons {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

extension ParseParToString on AlertParameter {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class Alert {
  final bool hasNotification;
  final AlertParameter parameter;
  final AlertComparissons comparisson;
  final double value;
  final Device device;

  const Alert({
    required this.device,
    required this.hasNotification,
    required this.parameter,
    required this.comparisson,
    required this.value,
  });
}
