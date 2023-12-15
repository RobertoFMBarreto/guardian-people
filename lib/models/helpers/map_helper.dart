import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:latlong2/latlong.dart';
import 'package:guardian/models/helpers/tiles/tile_stub.dart'
    if (dart.library.io) 'package:guardian/models/helpers/tiles/tile_mobile.dart'
    if (dart.library.js) 'package:guardian/models/helpers/tiles/tile_web.dart' as tile_provider;

/// Method that allows to get the map tile [TileLayer]
TileLayer getTileLayer(BuildContext context, {Key? key, bool satellite = false}) {
  return TileLayer(
    key: key,
    urlTemplate:
        'https://api.mapbox.com/styles/v1/mapbox/${satellite ? 'satellite-streets-v12' : 'outdoors-v12'}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoicm9iZXJ0b2JhcnJldG8iLCJhIjoiY2s4NXRlN2loMDA1MzNncWlybDV5eGNjcSJ9.Dkp_KYWwEcThrpvZ3dEMjg',
    userAgentPackageName: 'com.linovt.Guardian',
    tileProvider: tile_provider.getTileProvider('guardian'),
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

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

SvgPicture getMarker(String hexColor) {
  final darkerColor = HexColor.toHex(color: darken(HexColor(hexColor), .2));
  String marker = """
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <!-- Uploaded to: SVG Repo, www.svgrepo.com, Generator: SVG Repo Mixer Tools -->
    <svg width="200px" height="840px" viewBox="0 0 24 25" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <g transform="translate(0 -1028)">
      <path d="m12 0c-4.4183 2.3685e-15 -8 3.5817-8 8 0 1.421 0.3816 2.75 1.0312 3.906 0.1079 0.192 0.221 0.381 0.3438 0.563l6.625 11.531 6.625-11.531c0.102-0.151 0.19-0.311 0.281-0.469l0.063-0.094c0.649-1.156 1.031-2.485 1.031-3.906 0-4.4183-3.582-8-8-8zm0 4c2.209 0 4 1.7909 4 4 0 2.209-1.791 4-4 4-2.2091 0-4-1.791-4-4 0-2.2091 1.7909-4 4-4z" transform="translate(0 1028.4)" fill="$hexColor" style="stroke: $darkerColor;"/>
      <path d="m12 3c-2.7614 0-5 2.2386-5 5 0 2.761 2.2386 5 5 5 2.761 0 5-2.239 5-5 0-2.7614-2.239-5-5-5zm0 2c1.657 0 3 1.3431 3 3s-1.343 3-3 3-3-1.3431-3-3 1.343-3 3-3z" transform="translate(0 1028.4)" fill="$darkerColor"/>
    </g>
    </svg>
    <?xml version="1.0" encoding="utf-8"?>
  """;
  return SvgPicture.string(
    marker,
    semanticsLabel: 'A red up arrow',
  );
}
