import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:latlong2/latlong.dart';

/// Method that allows to get the map tile [TileLayer]
TileLayer getTileLayer(BuildContext context, {Key? key, bool satellite = false}) {
  return TileLayer(
    key: key,
    urlTemplate:
        'https://api.mapbox.com/styles/v1/mapbox/${satellite ? 'satellite-streets-v12' : 'outdoors-v12'}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoicm9iZXJ0b2JhcnJldG8iLCJhIjoiY2s4NXRlN2loMDA1MzNncWlybDV5eGNjcSJ9.Dkp_KYWwEcThrpvZ3dEMjg',
    // additionalOptions: const {
    //   'accessToken':
    //       'pk.eyJ1Ijoicm9iZXJ0b2JhcnJldG8iLCJhIjoiY2s4NXRlN2loMDA1MzNncWlybDV5eGNjcSJ9.Dkp_KYWwEcThrpvZ3dEMjg',
    //   'id': 'mapbox://styles/robertobarreto/clph2ale500kc01po4fqn0gtu'
    // },

    userAgentPackageName: 'com.linovt.Guardian',
    tileProvider: FMTC.instance('guardian').getTileProvider(),
    tileDisplay: const TileDisplay.fadeIn(),
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

double calcScaleTo100Pixels(GlobalKey parent, MapController mapController) {
  RenderBox box = parent.currentContext!.findRenderObject() as RenderBox;
  Size mapSize = box.size;
  final p1 = mapController.pointToLatLng(CustomPoint(0, mapSize.height / 2))!;

  // p2 displace 100 pixels in x axis
  final p2 = mapController.pointToLatLng(CustomPoint(100, mapSize.height / 2))!;

  // distance between p1 & p2
  final distance = FlutterMapMath().distanceBetween(
    p1.latitude,
    p1.longitude,
    p2.latitude,
    p2.longitude,
    "meters",
  );

  return distance;
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
