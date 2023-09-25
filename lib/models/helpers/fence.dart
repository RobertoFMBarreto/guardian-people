import 'dart:math';

import 'package:latlong2/latlong.dart';

const String tableFence = 'fences';

class FenceFields {
  static const String idFence = 'fence_id';
  static const String name = 'name';
  static const String color = 'color';
}

class Fence {
  final String idFence;
  final String name;
  String color;
  Fence({
    required this.idFence,
    required this.name,
    required this.color,
  });

  Fence copy({
    String? idFence,
    String? idUser,
    String? name,
    String? color,
  }) =>
      Fence(
        idFence: idFence ?? this.idFence,
        name: name ?? this.name,
        color: color ?? this.color,
      );

  Map<String, Object?> toJson() => {
        FenceFields.idFence: idFence,
        FenceFields.color: color,
        FenceFields.name: name,
      };

  static Fence fromJson(Map<String, Object?> json) => Fence(
        idFence: json[FenceFields.idFence] as String,
        color: json[FenceFields.color] as String,
        name: json[FenceFields.name] as String,
      );
}

LatLng getFenceCenter(List<LatLng> points) {
  if (points.length == 1) {
    return points.first;
  } else {
    double x = 0, y = 0, z = 0;
    for (LatLng coord in points) {
      double latitude = coord.latitude * pi / 180;
      double longitude = coord.longitude * pi / 180;

      x += cos(latitude) * cos(longitude);
      y += cos(latitude) * sin(longitude);
      z += sin(latitude);
    }
    int total = points.length;

    x = x / total;
    y = y / total;
    z = z / total;

    double centerLon = atan2(y, x);
    double centralSquareRoot = sqrt(x * x + y * y);
    double centerLat = atan2(z, centralSquareRoot);
    return LatLng(centerLat * 180 / pi, centerLon * 180 / pi);
  }
}
