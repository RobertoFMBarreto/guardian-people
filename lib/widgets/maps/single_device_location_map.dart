import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/device_data.dart';
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
  final DateTime startDate;
  final DateTime endDate;
  final bool isInterval;
  final bool showHeatMap;
  const SingleDeviceLocationMap({
    super.key,
    required this.currentPosition,
    required this.device,
    this.showFence = true,
    required this.onZoomChange,
    required this.startingZoom,
    required this.startDate,
    required this.endDate,
    required this.isInterval,
    this.showHeatMap = false,
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

  List<Map<double, MaterialColor>> gradients = [
    HeatMapOptions.defaultGradient,
    {0.25: Colors.blue, 0.55: Colors.red, 0.85: Colors.pink, 1.0: Colors.purple}
  ];

  @override
  void initState() {
    _loadDeviceFences();
    showFence = widget.showFence;
    super.initState();
  }

  void _loadDeviceFences() {
    loadDeviceFences(widget.device.imei).then((fences) {
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
    List<DeviceData> deviceData = widget.isInterval
        ? widget.device.getDataBetweenDates(widget.startDate, widget.endDate)
        : widget.device.data;
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
              if (widget.isInterval && !widget.showHeatMap)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      color: gdErrorColor,
                      strokeWidth: 5,
                      points: deviceData
                          .map(
                            (e) => LatLng(e.lat, e.lon),
                          )
                          .toList(),
                    ),
                  ],
                ),
              if (deviceData.isNotEmpty && widget.showHeatMap)
                HeatMapLayer(
                  heatMapDataSource: InMemoryHeatMapDataSource(
                    data: deviceData
                        .map(
                          (e) => WeightedLatLng(LatLng(e.lat, e.lon), 1),
                        )
                        .toList(),
                  ),
                )
              else
                MarkerLayer(
                  markers: [
                    if (deviceData.isNotEmpty)
                      Marker(
                        point: widget.isInterval
                            ? LatLng(deviceData.first.lat, deviceData.first.lon)
                            : LatLng(widget.device.data.first.lat, widget.device.data.first.lon),
                        builder: (context) {
                          return Icon(
                            Icons.location_on,
                            color: HexColor(widget.device.color),
                            size: 30,
                          );
                        },
                      ),
                    if (widget.isInterval && deviceData.isNotEmpty)
                      ...deviceData
                          .sublist(1)
                          .map(
                            (e) => Marker(
                              point: LatLng(e.lat, e.lon),
                              builder: (context) {
                                return const Icon(
                                  Icons.circle,
                                  color: gdErrorColor,
                                  size: 15,
                                );
                              },
                            ),
                          )
                          .toList(),
                    Marker(
                      point: widget.isInterval && deviceData.isNotEmpty
                          ? LatLng(deviceData.first.lat, deviceData.first.lon)
                          : LatLng(widget.device.data.first.lat, widget.device.data.first.lon),
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
