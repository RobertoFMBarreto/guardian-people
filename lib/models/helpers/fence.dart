import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Method that allows to get the center of a polygon [LatLng] based on its coordinates [points]
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
