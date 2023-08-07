import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';

import 'dart:math' show cos, sqrt, asin;

class GeofencingPage extends StatefulWidget {
  const GeofencingPage({super.key});

  @override
  State<GeofencingPage> createState() => _GeofencingPageState();
}

class _GeofencingPageState extends State<GeofencingPage> {
  Position? _currentPosition;
  late PolyEditor polyEditor;
  bool isCircle = false;

  final polygons = <Polygon>[];
  final testPolygon = Polygon(
    color: Colors.orange.withOpacity(0.5),
    borderColor: Colors.deepOrange,
    borderStrokeWidth: 2,
    isFilled: true,
    points: [],
  );

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();

    polyEditor = PolyEditor(
      addClosePathMarker: true,
      points: testPolygon.points,
      pointIcon: const Icon(Icons.circle, size: 23),
      intermediateIcon: const Icon(Icons.square_rounded, size: 23),
      callbackRefresh: () {
        if (testPolygon.points.length > 2 && isCircle) {
          polyEditor.remove(testPolygon.points.length - 2);
        }
        setState(() {});
      },
    );

    polygons.add(testPolygon);
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
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
      body: _currentPosition == null
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            )
          : FlutterMap(
              options: MapOptions(
                onTap: (_, ll) {
                  polyEditor.add(testPolygon.points, ll);
                },
                center: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 10,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                if (polyEditor.points.length >= 2 && isCircle)
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.restart_alt),
            onPressed: () {
              setState(() {
                testPolygon.points.clear();
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: FloatingActionButton(
              child: const Icon(Icons.square_outlined),
              onPressed: () {
                setState(() {
                  testPolygon.points.clear();
                  isCircle = false;
                });
              },
            ),
          ),
          FloatingActionButton(
            child: const Icon(Icons.circle_outlined),
            onPressed: () {
              setState(() {
                testPolygon.points.clear();
                isCircle = true;
              });
            },
          ),
        ],
      ),
    );
  }
}
