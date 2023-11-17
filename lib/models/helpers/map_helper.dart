import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' show cos, sqrt, asin;

/// Method that allows to get the map tile [TileLayer]
TileLayer getTileLayer(BuildContext context, {Key? key}) {
  return TileLayer(
    key: key,
    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    subdomains: const ['a', 'b', 'c'],
    userAgentPackageName: 'com.linovt.Guardian',
    tileProvider: FMTC.instance('guardian').getTileProvider(),
    tileDisplay: const TileDisplay.fadeIn(),
    // tileProvider: NetworkNoRetryTileProvider(
    //   headers: {
    //     "Access-Control-Allow-Origin": "*",
    //   },
    // ),
  );
}

/// Method that allows to get all circle fences drawed [CircleLayer]
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

/// Method that allows to get all polygon fences drawed [PolygonLayer]
PolygonLayer getPolygonFences(List<Polygon> polygons) {
  return PolygonLayer(
    polygons: polygons,
  );
}

/// Method that allows to get the distance in meters between two coordinates
///
/// * Coordinate 1 [lat1][lon1]
/// * Coordinate 2 [lat2][lon2]
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
