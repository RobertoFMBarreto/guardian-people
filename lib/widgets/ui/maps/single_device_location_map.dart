import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/helpers/map_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:latlong2/latlong.dart';

class SingleDeviceLocationMap extends StatefulWidget {
  final bool showCurrentPosition;
  final List<DeviceLocationsCompanion> deviceData;
  final String imei;
  final String deviceColor;
  final bool showFence;
  final bool showRoute;
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
    required this.showRoute,
  });

  @override
  State<SingleDeviceLocationMap> createState() => _SingleDeviceLocationMapState();
}

class _SingleDeviceLocationMapState extends State<SingleDeviceLocationMap> {
  final _polygons = <Polygon>[];
  final _circles = <Polygon>[];
  final MapController _mapController = MapController();

  late Future _future;

  bool _showFence = true;
  Position? _currentPosition;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _setup() async {
    await getCurrentPosition(
      context,
      (position) {
        if (mounted) {
          setState(() => _currentPosition = position);
        }
      },
    );
    await _loadDeviceFences();
    _showFence = widget.showFence;
  }

  Future<void> _loadDeviceFences() async {
    List<Polygon> allFences = [];
    await getDeviceFence(widget.imei).then((fence) async {
      if (fence != null) {
        List<LatLng> fencePoints = [];
        fencePoints.addAll(await getFencePoints(fence.fenceId));
        allFences.add(
          Polygon(
            points: fencePoints,
            color: HexColor(fence.color).withOpacity(0.5),
            borderColor: HexColor(fence.color),
            borderStrokeWidth: 2,
            isFilled: true,
          ),
        );
      }
      if (mounted) {
        setState(() {
          _polygons.addAll(allFences);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DeviceLocationsCompanion> data = widget.isInterval && widget.deviceData.isNotEmpty
        ? widget.deviceData
        : widget.deviceData.isNotEmpty
            ? [widget.deviceData.first]
            : [];
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomCircularProgressIndicator();
        } else {
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: data.isNotEmpty && (_polygons.isEmpty || _circles.isEmpty)
                  ? widget.isInterval && data.isEmpty
                      ? LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        )
                      : widget.isInterval
                          ? null
                          : LatLng(data.first.lat.value, data.first.lon.value)
                  : LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
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
              boundsOptions: const FitBoundsOptions(padding: EdgeInsets.all(20)),
              bounds: (_polygons.isNotEmpty || _circles.isNotEmpty) && data.isEmpty
                  ? LatLngBounds.fromPoints(
                      _polygons.isEmpty ? _circles.first.points : _polygons.first.points)
                  : widget.isInterval && data.isNotEmpty
                      ? LatLngBounds.fromPoints(
                          data.map((e) => LatLng(e.lat.value, e.lon.value)).toList(),
                        )
                      : null,
            ),
            children: [
              getTileLayer(context),
              if (_showFence) ...[
                getCircleFences(_circles),
                getPolygonFences(_polygons),
              ],
              if (widget.isInterval && !widget.showHeatMap && widget.showRoute)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      color: gdErrorColor,
                      strokeWidth: 5,
                      points: data
                          .map(
                            (e) => LatLng(e.lat.value, e.lon.value),
                          )
                          .toList(),
                    ),
                  ],
                ),
              if (data.isNotEmpty && widget.showHeatMap)
                HeatMapLayer(
                  heatMapDataSource: InMemoryHeatMapDataSource(
                    data: data
                        .map(
                          (e) => WeightedLatLng(LatLng(e.lat.value, e.lon.value), 1),
                        )
                        .toList(),
                  ),
                )
              else ...[
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    anchor: AnchorPos.align(AnchorAlign.center),
                    fitBoundsOptions: const FitBoundsOptions(
                      padding: EdgeInsets.all(50),
                      maxZoom: 15,
                    ),
                    markers: [
                      if (_currentPosition != null)
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
                      ...data
                          .map(
                            (e) => Marker(
                              point: LatLng(e.lat.value, e.lon.value),
                              anchorPos: AnchorPos.align(AnchorAlign.top),
                              builder: (context) {
                                return Transform.rotate(
                                  angle: _mapController.rotation * -pi / 180,
                                  alignment: Alignment.bottomCenter,
                                  child: Icon(
                                    Icons.location_on,
                                    color: HexColor(widget.deviceColor),
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                          )
                          .toList()
                    ],
                    builder: (context, markers) {
                      return Transform.rotate(
                        angle: _mapController.rotation * -pi / 180,
                        child: Icon(
                          Icons.location_on,
                          color: HexColor(widget.deviceColor),
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ]
            ],
          );
        }
      },
    );
  }
}
