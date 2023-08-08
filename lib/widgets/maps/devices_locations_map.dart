import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:latlong2/latlong.dart';

class DevicesLocationsMap extends StatelessWidget {
  final Position currentPosition;
  final List<Device> devices;
  const DevicesLocationsMap({
    super.key,
    required this.currentPosition,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 10,
        minZoom: 3,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.linovt.guardian',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(currentPosition.latitude, currentPosition.longitude),
              builder: (context) {
                return const Icon(
                  Icons.circle,
                  color: gdMapLocationPointColor,
                  size: 30,
                );
              },
            ),
            ...devices
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
