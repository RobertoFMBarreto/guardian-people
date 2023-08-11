import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:latlong2/latlong.dart';

class SingleDeviceLocationMap extends StatefulWidget {
  final Position currentPosition;
  final Device device;
  final bool showFence;
  final Function(double) onZoomChange;
  final double startingZoom;
  const SingleDeviceLocationMap({
    super.key,
    required this.currentPosition,
    required this.device,
    this.showFence = true,
    required this.onZoomChange,
    required this.startingZoom,
  });

  @override
  State<SingleDeviceLocationMap> createState() => _SingleDeviceLocationMapState();
}

class _SingleDeviceLocationMapState extends State<SingleDeviceLocationMap> {
  final polygons = <Polygon>[];
  final circles = <Polygon>[];
  bool isLoading = true;
  bool showFence = true;
  final MapController _mapController = MapController();
  @override
  void initState() {
    _loadDeviceFences();
    showFence = widget.showFence;
    super.initState();
  }

  void _loadDeviceFences() {
    loadDeviceFences(widget.device.imei).then((fences) {
      print("Found Fences: ${fences}");
      setState(() {
        for (Fence fence in fences) {
          polygons.add(
            Polygon(
              points: fence.points,
              color: HexColor(fence.color).withOpacity(0.5),
              borderColor: HexColor(fence.color),
              borderStrokeWidth: 2,
              isFilled: true,
            ),
          );
        }
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.secondary,
            ),
          )
        : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(
                widget.device.data.first.lat,
                widget.device.data.first.lon,
              ),
              onMapReady: () {
                _mapController.mapEventStream.listen((evt) {
                  print('Current zoom: ${_mapController.zoom}');
                  widget.onZoomChange(_mapController.zoom);
                });
                // And any other `MapController` dependent non-movement methods
              },
              zoom: widget.startingZoom,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.linovt.guardian',
              ),
              if (showFence)
                CircleLayer(
                  circles: [
                    ...circles
                        .map(
                          (circle) => CircleMarker(
                            useRadiusInMeter: true,
                            color: circle.color,
                            borderColor: circle.borderColor,
                            borderStrokeWidth: 2,
                            point: LatLng(
                              polygons.first.points.first.latitude,
                              polygons.first.points.first.longitude,
                            ),
                            radius: calculateDistance(
                              polygons.first.points.first.latitude,
                              polygons.first.points.first.longitude,
                              polygons.first.points.last.latitude,
                              polygons.first.points.last.longitude,
                            ),
                          ),
                        )
                        .toList()
                  ],
                ),
              if (showFence)
                PolygonLayer(
                  polygons: polygons,
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point:
                        LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude),
                    builder: (context) {
                      return const Icon(
                        Icons.circle,
                        color: gdMapLocationPointColor,
                        size: 30,
                      );
                    },
                  ),
                  Marker(
                    point: LatLng(widget.device.data.first.lat, widget.device.data.first.lon),
                    builder: (context) {
                      return Icon(
                        Icons.location_on,
                        color: HexColor(widget.device.color),
                        size: 30,
                      );
                    },
                  ),
                ],
              ),
            ],
          );
  }
}
