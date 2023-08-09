import 'package:latlong2/latlong.dart';

import 'device.dart';

class Fence {
  final String name;
  String color;
  final List<Device> devices;
  final List<LatLng> points;
  Fence({
    required this.name,
    required this.color,
    required this.devices,
    required this.points,
  });
}
