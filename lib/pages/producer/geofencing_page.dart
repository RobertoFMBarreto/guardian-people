import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';

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
    color: gdMapGeofenceFillColor,
    borderColor: gdMapGeofenceBorderColor,
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
      intermediateIcon: isCircle ? null : const Icon(Icons.square_rounded, size: 23),
      intermediateIconSize: const Size(50, 50),
      pointIconSize: const Size(50, 50),
      callbackRefresh: () {
        if (testPolygon.points.length > 2 && isCircle) {
          polyEditor.remove(testPolygon.points.length - 2);
        }
        print(polyEditor.points);
        setState(() {});
      },
    );

    polygons.add(testPolygon);
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await handleLocationPermission(context);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar cerca',
          style: theme.textTheme.headlineSmall!.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        foregroundColor: theme.colorScheme.onSecondary,
        backgroundColor: theme.colorScheme.secondary,
        centerTitle: true,
      ),
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
                        color: gdMapGeofenceFillColor,
                        borderColor: gdMapGeofenceBorderColor,
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
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      builder: (context) {
                        return const Icon(
                          Icons.circle,
                          color: gdMapLocationPointColor,
                          size: 30,
                        );
                      },
                    )
                  ],
                )
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'polygon',
            backgroundColor: isCircle ? Colors.white : const Color.fromRGBO(182, 255, 199, 1),
            onPressed: () {
              setState(() {
                testPolygon.points.clear();
                isCircle = false;
              });
            },
            child: const Icon(Icons.square_outlined),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: FloatingActionButton(
              heroTag: 'circle',
              backgroundColor: isCircle ? const Color.fromRGBO(182, 255, 199, 1) : Colors.white,
              onPressed: () {
                setState(() {
                  testPolygon.points.clear();
                  isCircle = true;
                });
              },
              child: const Icon(Icons.circle_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: FloatingActionButton(
              heroTag: 'reset',
              child: const Icon(Icons.delete_forever),
              onPressed: () {
                setState(() {
                  testPolygon.points.clear();
                });
              },
            ),
          ),
          FloatingActionButton(
            heroTag: 'done',
            child: const Icon(Icons.done),
            onPressed: () {
              //!TODO: Code for storing the geofence
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
