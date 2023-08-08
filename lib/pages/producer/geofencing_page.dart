import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';

class GeofencingPage extends StatefulWidget {
  final Fence? fence;
  const GeofencingPage({super.key, this.fence});

  @override
  State<GeofencingPage> createState() => _GeofencingPageState();
}

class _GeofencingPageState extends State<GeofencingPage> {
  Position? _currentPosition;
  late PolyEditor polyEditor;
  bool isCircle = false;

  final polygons = <Polygon>[];
  late Polygon editingPolygon;
  late Polygon backupPolygon;

  @override
  void initState() {
    super.initState();
    if (widget.fence != null) {
      // if there are only 2 points then its a circle
      isCircle = widget.fence!.points.length == 2;
    }
    _initPolygon();
    _getCurrentPosition();
    _initPolyEditor();
  }

  void _initPolygon() {
    editingPolygon = Polygon(
      color: widget.fence != null
          ? HexColor(widget.fence!.fillColor).withOpacity(0.5)
          : gdMapGeofenceFillColor,
      borderColor:
          widget.fence != null ? HexColor(widget.fence!.borderColor) : gdMapGeofenceBorderColor,
      borderStrokeWidth: 2,
      isFilled: true,
      points: [],
    );
    editingPolygon.points.addAll(widget.fence!.points);
  }

  void _initPolyEditor() {
    polyEditor = PolyEditor(
      addClosePathMarker: true,
      points: editingPolygon.points,
      pointIcon: const Icon(Icons.circle, size: 23),
      intermediateIcon: isCircle ? null : const Icon(Icons.square_rounded, size: 23),
      intermediateIconSize: const Size(50, 50),
      pointIconSize: const Size(50, 50),
      callbackRefresh: () {
        if (editingPolygon.points.length > 2 && isCircle) {
          polyEditor.remove(editingPolygon.points.length - 2);
        }
        setState(() {});
      },
    );

    polygons.add(editingPolygon);
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

  void resetPolygon() {
    editingPolygon.points.clear();
    if (widget.fence != null) {
      if (widget.fence!.points.length == 2 && isCircle) {
        editingPolygon.points.addAll(widget.fence!.points);
      } else if (widget.fence!.points.length > 2 && !isCircle) {
        editingPolygon.points.addAll(widget.fence!.points);
      } else {
        editingPolygon.points.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar cerca',
          style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
        ),
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
                  polyEditor.add(editingPolygon.points, ll);
                },
                center: widget.fence != null
                    ? LatLng(
                        widget.fence!.points.first.latitude, widget.fence!.points.first.longitude)
                    : LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: widget.fence != null ? 17 : 10,
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
                        color: widget.fence != null
                            ? HexColor(widget.fence!.fillColor).withOpacity(0.5)
                            : gdMapGeofenceFillColor,
                        borderColor: widget.fence != null
                            ? HexColor(widget.fence!.borderColor)
                            : gdMapGeofenceBorderColor,
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
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        children: [
          FloatingActionButton.small(
            heroTag: 'polygon',
            backgroundColor: isCircle ? Colors.white : const Color.fromRGBO(182, 255, 199, 1),
            onPressed: () {
              setState(() {
                isCircle = false;
                resetPolygon();
              });
            },
            child: const Icon(Icons.square_outlined),
          ),
          FloatingActionButton.small(
            heroTag: 'circle',
            backgroundColor: isCircle ? const Color.fromRGBO(182, 255, 199, 1) : Colors.white,
            onPressed: () {
              setState(() {
                isCircle = true;
                resetPolygon();
              });
            },
            child: const Icon(Icons.circle_outlined),
          ),
          FloatingActionButton.small(
            heroTag: 'reset',
            child: const Icon(Icons.replay),
            onPressed: () {
              setState(() {
                resetPolygon();
              });
            },
          ),
          FloatingActionButton.small(
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
