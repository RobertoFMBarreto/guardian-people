import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:latlong2/latlong.dart';

class DevicesLocationsMap extends StatefulWidget {
  final Position currentPosition;
  final List<Device> devices;
  final List<LatLng>? fencePoints;
  const DevicesLocationsMap({
    super.key,
    required this.currentPosition,
    required this.devices,
    this.fencePoints,
  });

  @override
  State<DevicesLocationsMap> createState() => _DevicesLocationsMapState();
}

class _DevicesLocationsMapState extends State<DevicesLocationsMap> {
  final polygons = <Polygon>[];
  @override
  void initState() {
    if (widget.fencePoints != null) {
      polygons.add(
        Polygon(
          color: gdMapGeofenceFillColor,
          borderColor: gdMapGeofenceBorderColor,
          borderStrokeWidth: 2,
          isFilled: true,
          points: widget.fencePoints!,
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude),
        zoom: 17,
        minZoom: 3,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.linovt.guardian',
        ),
        polygons.first.points.length == 2
            ? CircleLayer(
                circles: [
                  CircleMarker(
                    useRadiusInMeter: true,
                    color: gdMapGeofenceFillColor,
                    borderColor: gdMapGeofenceBorderColor,
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
                  )
                ],
              )
            : PolygonLayer(
                polygons: polygons,
              ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude),
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
