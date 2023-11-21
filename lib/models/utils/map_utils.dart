import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLng computeCentroid(Iterable<LatLng> points) {
  double latitude = 0;
  double longitude = 0;
  int n = points.length;

  for (LatLng point in points) {
    latitude += point.latitude;
    longitude += point.longitude;
  }

  return LatLng(latitude / n, longitude / n);
}

class MapUtils {
  static LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }
}
