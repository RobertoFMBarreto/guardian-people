import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart' if (kIsWeb) '';
import 'package:latlong2/latlong.dart';
import 'dart:math' show cos, sqrt, asin;

TileLayer getTileLayer(BuildContext context) {
  return TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'com.linovt.guardian',
    // tileProvider: !kIsWeb ? FMTC.instance('guardian').getTileProvider() : null,
    tileDisplay: const TileDisplay.fadeIn(),
  );
}

CircleLayer getCircleFences(List<Polygon> circles) {
  return CircleLayer(
    circles: [
      ...circles
          .map(
            (circle) => CircleMarker(
              useRadiusInMeter: true,
              color: circle.color,
              borderColor: circle.borderColor,
              borderStrokeWidth: 2,
              point: LatLng(
                circle.points.first.latitude,
                circle.points.first.longitude,
              ),
              radius: calculateDistance(
                circle.points.first.latitude,
                circle.points.first.longitude,
                circle.points.last.latitude,
                circle.points.last.longitude,
              ),
            ),
          )
          .toList()
    ],
  );
}

PolygonLayer getPolygonFences(List<Polygon> polygons) {
  return PolygonLayer(
    polygons: polygons,
  );
}

/// Method that allows to get the distance in meters between two points
double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a =
      0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return (12742 * asin(sqrt(a))) * 1000;
}

const ColorFilter greyscale = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);