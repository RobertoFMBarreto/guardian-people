import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/device_data.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:latlong2/latlong.dart';

class SingleDeviceLocationMap extends StatefulWidget {
  final bool showCurrentPosition;
  final List<DeviceData> deviceData;
  final String imei;
  final String deviceColor;
  final bool showFence;
  final Function(double) onZoomChange;
  final double startingZoom;
  final DateTime startDate;
  final DateTime endDate;
  final bool isInterval;
  final bool showHeatMap;
  const SingleDeviceLocationMap({
    super.key,
    required this.showCurrentPosition,
    required this.deviceData,
    this.showFence = true,
    required this.onZoomChange,
    required this.startingZoom,
    required this.startDate,
    required this.endDate,
    required this.isInterval,
    this.showHeatMap = false,
    required this.imei,
    required this.deviceColor,
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
    loadDeviceFences(widget.imei).then((fences) {
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
              center: widget.deviceData.isNotEmpty
                  ? LatLng(
                      widget.deviceData.first.lat,
                      widget.deviceData.first.lon,
                    )
                  : null,
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
                      points: widget.deviceData
                          .map(
                            (e) => LatLng(e.lat, e.lon),
                          )
                          .toList(),
                    ),
                  ],
                ),
              if (widget.deviceData.isNotEmpty && widget.showHeatMap)
                HeatMapLayer(
                  heatMapDataSource: InMemoryHeatMapDataSource(
                    data: widget.deviceData
                        .map(
                          (e) => WeightedLatLng(LatLng(e.lat, e.lon), 1),
                        )
                        .toList(),
                  ),
                )
              else
                MarkerLayer(
                  markers: [
                    if (widget.deviceData.isNotEmpty)
                      Marker(
                        point: LatLng(widget.deviceData.first.lat, widget.deviceData.first.lon),
                        builder: (context) {
                          return Icon(
                            Icons.location_on,
                            color: HexColor(widget.deviceColor),
                            size: 30,
                          );
                        },
                      ),
                    if (widget.isInterval && widget.deviceData.isNotEmpty)
                      ...widget.deviceData
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
                  ],
                ),
            ],
          );
  }
}
