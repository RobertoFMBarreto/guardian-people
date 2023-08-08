import 'package:latlong2/latlong.dart';

import 'device.dart';

class Fence {
  final String name;
  final String fillColor;
  final String borderColor;
  final List<Device> devices;
  final List<LatLng> points;
  const Fence({
    required this.name,
    required this.fillColor,
    required this.borderColor,
    required this.devices,
    required this.points,
  });
}
