import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:latlong2/latlong.dart';

class DevicesLocationsMap extends StatefulWidget {
  final Position currentPosition;
  final List<Device> devices;
  final List<Fence>? fences;
  final bool centerOnPoly;
  final bool centerOnDevice;
  const DevicesLocationsMap({
    super.key,
    required this.currentPosition,
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
  @override
  void initState() {
    if (widget.fences != null) {
      if (widget.fences!.length > 1 && widget.centerOnPoly) {
        throw ErrorDescription("Can only center on poly with one poly");
      }
    }
    _loadFences();

    super.initState();
  }

  void _loadFences() {
    print("Received Fences: ${widget.fences}");
    setState(() {
      if (widget.fences != null) {
        for (Fence fence in widget.fences!) {
          polygons.add(
            Polygon(
              points: fence.points,
              color: HexColor(fence.color).withOpacity(0.5),
              borderColor: HexColor(fence.color),
              borderStrokeWidth: 2,
              isFilled: true,
            ),
          );
          // circles.add(
          //   Polygon(
          //     points: fence.points,
          //     color: HexColor(fence.color).withOpacity(0.5),
          //     borderColor: HexColor(fence.color),
          //     borderStrokeWidth: 2,
          //     isFilled: true,
          //   ),
          // );
        }
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    print("Fences: ${widget.fences}");
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.secondary,
            ),
          )
        : FlutterMap(
            options: MapOptions(
              center: !widget.centerOnPoly
                  ? LatLng(
                      widget.currentPosition.latitude,
                      widget.currentPosition.longitude,
                    )
                  : LatLng(
                      polygons.first.points.first.latitude,
                      polygons.first.points.first.longitude,
                    ),
              zoom: 17,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.linovt.guardian',
              ),
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
                  ...widget.devices
                      .map(
                        (device) => Marker(
                          point: LatLng(device.data.first.lat, device.data.first.lon),
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
