import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/db/fence_points_operations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:latlong2/latlong.dart';

class DevicesLocationsMap extends StatefulWidget {
  final bool showCurrentPosition;
  final List<Device> devices;
  final List<Fence>? fences;
  final bool centerOnPoly;
  final bool centerOnDevice;
  const DevicesLocationsMap({
    super.key,
    required this.showCurrentPosition,
    required this.devices,
    this.fences,
    this.centerOnPoly = false,
    this.centerOnDevice = false,
  });

  @override
  State<DevicesLocationsMap> createState() => _DevicesLocationsMapState();
}

class _DevicesLocationsMapState extends State<DevicesLocationsMap> {
  final polygons = <Polygon>[];
  final circles = <Polygon>[];
  bool isLoading = true;
  Position? _currentPosition;
  List<LatLng> fencePoints = [];

  @override
  void initState() {
    _getCurrentPosition().then((_) {
      if (widget.fences != null) {
        if (widget.fences!.length > 1 && widget.centerOnPoly) {
          throw ErrorDescription("Can only center on poly with one poly");
        }
      }
      _loadFences().then(
        (_) => setState(() => isLoading = false),
      );
    });

    super.initState();
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await handleLocationPermission(context);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.reduced)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {});
  }

  Future<void> _loadFences() async {
    List<Polygon> allPolygons = [];
    List<Polygon> allCircles = [];

    if (widget.fences != null) {
      for (Fence fence in widget.fences!) {
        await getFencePoints(fence.fenceId).then(
          (points) => points.length == 2
              ? allCircles.add(
                  Polygon(
                    points: points,
                    color: HexColor(fence.color).withOpacity(0.5),
                    borderColor: HexColor(fence.color),
                    borderStrokeWidth: 2,
                    isFilled: true,
                  ),
                )
              : allPolygons.add(
                  Polygon(
                    points: points,
                    color: HexColor(fence.color).withOpacity(0.5),
                    borderColor: HexColor(fence.color),
                    borderStrokeWidth: 2,
                    isFilled: true,
                  ),
                ),
        );
      }
    }
    if (mounted) {
      setState(() {
        polygons.addAll(allPolygons);
        circles.addAll(allCircles);
      });
    }
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
            options: MapOptions(
              center: !widget.centerOnPoly && _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                  : null,
              bounds: widget.centerOnPoly ? LatLngBounds.fromPoints(polygons.first.points) : null,
              zoom: 17,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.linovt.guardian',
                tileProvider: FMTC.instance('guardian').getTileProvider(),
              ),
              if (circles.isNotEmpty)
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
                ),
              if (polygons.isNotEmpty)
                PolygonLayer(
                  polygons: polygons,
                ),
              MarkerLayer(
                markers: [
                  if (widget.showCurrentPosition && _currentPosition != null)
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      builder: (context) {
                        return const Icon(
                          Icons.circle,
                          color: gdMapLocationPointColor,
                          size: 30,
                        );
                      },
                    ),
                  ...widget.devices
                      .map(
                        (device) => Marker(
                          point: LatLng(device.data!.first.lat, device.data!.first.lon),
                          builder: (context) {
                            return Icon(
                              Icons.location_on,
                              color: HexColor(device.color),
                              size: 30,
                            );
                          },
                        ),
                      )
                      .toList()
                ],
              ),
            ],
          );
  }
}
