import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';

import 'dart:math' show cos, sqrt, asin;

class CircleEditMap extends StatefulWidget {
  const CircleEditMap({super.key});

  @override
  State<CircleEditMap> createState() => _CircleEditMapState();
}

class _CircleEditMapState extends State<CircleEditMap> {
  late PolyEditor polyEditor;

  final polygons = <Polygon>[];
  final testPolygon = Polygon(
    color: Colors.deepOrange,
    isFilled: true,
    points: [],
  );

  @override
  void initState() {
    super.initState();

    polyEditor = PolyEditor(
      addClosePathMarker: true,
      points: testPolygon.points,
      pointIcon: const Icon(Icons.circle, size: 23),
      callbackRefresh: () {
        if (testPolygon.points.length > 2) {
          polyEditor.remove(testPolygon.points.length - 2);
        }
        setState(() {});
      },
    );

    polygons.add(testPolygon);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return (12742 * asin(sqrt(a))) * 1000;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          onTap: (_, ll) {
            polyEditor.add(testPolygon.points, ll);
          },
          // For backwards compatibility with pre v5 don't use const
          // ignore: prefer_const_constructors
          center: LatLng(45.5231, -122.6765),
          zoom: 10,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          if (polyEditor.points.length >= 2)
            CircleLayer(
              circles: [
                CircleMarker(
                  useRadiusInMeter: true,
                  color: Colors.orange.withOpacity(0.5),
                  borderColor: Colors.deepOrange,
                  borderStrokeWidth: 2,
                  point: LatLng(
                    polyEditor.points.first.latitude,
                    polyEditor.points.first.longitude,
                  ),
                  radius: calculateDistance(
                    polyEditor.points.first.latitude,
                    polyEditor.points.first.longitude,
                    polyEditor.points.last.latitude,
                    polyEditor.points.last.longitude,
                  ),
                )
              ],
            ),
          PolygonLayer(polygons: polygons),
          DragMarkers(
            markers: polyEditor.edit(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.replay),
        onPressed: () {
          setState(() {
            testPolygon.points.clear();
          });
        },
      ),
    );
  }
}
