import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/instance_manager.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/helpers/map_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:latlong2/latlong.dart';

class DevicesLocationsMap extends StatefulWidget {
  final bool showCurrentPosition;
  final List<Device> devices;
  final List<FenceData>? fences;
  final String? reloadMap;
  final bool centerOnPoly;
  final bool centerOnDevice;
  const DevicesLocationsMap({
    super.key,
    required this.showCurrentPosition,
    required this.devices,
    this.fences,
    this.centerOnPoly = false,
    this.centerOnDevice = false,
    this.reloadMap,
  });

  @override
  State<DevicesLocationsMap> createState() => _DevicesLocationsMapState();
}

class _DevicesLocationsMapState extends State<DevicesLocationsMap> {
  final _polygons = <Polygon>[];
  final _circles = <Polygon>[];
  final db = Get.find<GuardianDb>();

  late Future _future;

  Position? _currentPosition;

  List<LatLng> devicesDataPoints = [];

  @override
  void initState() {
    _future = _setup();
    super.initState();
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
    if (widget.fences != null) {
      if (widget.fences!.length > 1 && widget.centerOnPoly) {
        throw ErrorDescription("Can only center on poly with one poly");
      }
    }
    await _loadFences();
    for (var device in widget.devices) {
      if (device.data.isNotEmpty) {
        devicesDataPoints.add(
          LatLng(
            device.data.first.lat.value,
            device.data.first.lon.value,
          ),
        );
      }
    }
  }

  Future<void> _loadFences() async {
    List<Polygon> allPolygons = [];
    List<Polygon> allCircles = [];

    if (widget.fences != null) {
      for (FenceData fence in widget.fences!) {
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
        _polygons.addAll(allPolygons);
        _circles.addAll(allCircles);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomCircularProgressIndicator();
        } else {
          return FlutterMap(
            key: Key(widget.reloadMap ?? ''),
            options: MapOptions(
              center: !widget.centerOnPoly && _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                  : null,
              bounds: widget.centerOnPoly && devicesDataPoints.isNotEmpty
                  ? LatLngBounds.fromPoints(_polygons.first.points)
                  : devicesDataPoints.isNotEmpty
                      ? LatLngBounds.fromPoints(devicesDataPoints)
                      : null,
              boundsOptions: const FitBoundsOptions(padding: EdgeInsets.all(20)),
              zoom: 17,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              getTileLayer(context),
              if (_circles.isNotEmpty) getCircleFences(_circles),
              if (_polygons.isNotEmpty) getPolygonFences(_polygons),
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
                      .where((element) => element.data.isNotEmpty)
                      .map(
                        (device) => Marker(
                          point: LatLng(
                            device.data.first.lat.value,
                            device.data.first.lon.value,
                          ),
                          builder: (context) {
                            return Icon(
                              Icons.location_on,
                              color: HexColor(device.device.color.value),
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
      },
    );
  }
}
