import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/helpers/device_status.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/map_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:latlong2/latlong.dart';

/// Class that represents the animals locations maps for showing all user devices locations
class AnimalsLocationsMap extends StatefulWidget {
  final bool showCurrentPosition;
  final List<Animal> animals;
  final List<FenceData>? fences;
  final String? reloadMap;
  final bool centerOnPoly;
  final bool centerOnDevice;
  final GlobalKey parent;
  const AnimalsLocationsMap({
    super.key,
    required this.showCurrentPosition,
    required this.animals,
    this.fences,
    this.centerOnPoly = false,
    this.centerOnDevice = false,
    this.reloadMap,
    required this.parent,
  });

  @override
  State<AnimalsLocationsMap> createState() => _AnimalsLocationsMapState();
}

class _AnimalsLocationsMapState extends State<AnimalsLocationsMap> {
  final _polygons = <Polygon>[];
  final _circles = <Polygon>[];

  late Future _future;

  Position? _currentPosition;

  final List<LatLng> _animalsDataPoints = [];
  final List<LatLng> _allFencesPoints = [];
  final MapController _mapController = MapController();

  final GlobalKey _mapParentKey = GlobalKey();

  double _distance = 0;
  double _lastZoom = 0;

  List<Marker> markers = [];

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  /// Method that does the initial setup of the widget
  ///
  /// 1. get current position
  /// 2. load fences
  /// 3. load animals
  Future<void> _setup() async {
    await getCurrentPosition(
      context,
      (position) {
        if (mounted) {
          setState(() => _currentPosition = position);
        }
      },
    );

    await _loadFences();
    for (var animal in widget.animals) {
      if (animal.data.isNotEmpty &&
          animal.data.first.lat.value != null &&
          animal.data.first.lon.value != null) {
        _animalsDataPoints.add(
          LatLng(
            animal.data.first.lat.value!,
            animal.data.first.lon.value!,
          ),
        );
      }
    }
  }

  /// Method that loads all fences into the [allCircles], [allPolygons] and [_allFencesPoints] lists
  Future<void> _loadFences() async {
    List<Polygon> allPolygons = [];
    List<Polygon> allCircles = [];
    if (widget.fences != null) {
      for (FenceData fence in widget.fences!) {
        await getFencePoints(fence.idFence).then((points) {
          final pointsLocation = points.map((e) => LatLng(e.lat, e.lon)).toList();
          _allFencesPoints.addAll(pointsLocation);
          return points.length == 2
              ? allCircles.add(
                  Polygon(
                    points: pointsLocation,
                    color: HexColor(fence.color).withOpacity(0.5),
                    borderColor: HexColor(fence.color),
                    borderStrokeWidth: 2,
                    isFilled: true,
                  ),
                )
              : allPolygons.add(
                  Polygon(
                    points: pointsLocation,
                    color: HexColor(fence.color).withOpacity(0.5),
                    borderColor: HexColor(fence.color),
                    borderStrokeWidth: 2,
                    isFilled: true,
                  ),
                );
        });
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
    ThemeData theme = Theme.of(context);
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomCircularProgressIndicator();
        } else {
          return Stack(
            children: [
              FlutterMap(
                key: _mapParentKey,
                mapController: _mapController,
                options: MapOptions(
                  center: !widget.centerOnPoly && _currentPosition != null
                      ? LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        )
                      : null,
                  bounds: widget.centerOnPoly
                      ? LatLngBounds.fromPoints(_allFencesPoints)
                      : _animalsDataPoints.isNotEmpty
                          ? LatLngBounds.fromPoints(_animalsDataPoints)
                          : null,
                  boundsOptions: const FitBoundsOptions(padding: EdgeInsets.all(20)),
                  zoom: 17,
                  minZoom: 6,
                  maxZoom: 18,
                  onMapReady: () {
                    if (_distance == 0 && _lastZoom == 0) {
                      setState(() {
                        _distance = calcScaleTo100Pixels(widget.parent, _mapController);
                      });
                      _lastZoom = _mapController.zoom;
                    }
                    _mapController.mapEventStream.listen((evt) {
                      if (_mapController.zoom != _lastZoom) {
                        setState(() {
                          _distance = calcScaleTo100Pixels(widget.parent, _mapController);
                        });
                        _lastZoom = _mapController.zoom;
                      }
                    });
                  },
                ),
                children: [
                  getTileLayer(context),
                  if (_circles.isNotEmpty) getCircleFences(_circles),
                  if (_polygons.isNotEmpty) getPolygonFences(_polygons),
                  PopupMarkerLayerWidget(
                    options: PopupMarkerLayerOptions(
                      initiallySelectedMarkers: const [],
                      markerCenterAnimation: const MarkerCenterAnimation(),
                      popupBuilder: (ctx, marker) {
                        final animal = widget.animals
                            .where(
                              (element) =>
                                  element.data.isNotEmpty &&
                                  element.data.first.lat.value != null &&
                                  element.data.first.lon.value != null &&
                                  element.data.first.lat.value == marker.point.latitude &&
                                  element.data.first.lon.value == marker.point.longitude,
                            )
                            .first;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomPageRouter(
                                page: '/producer/device',
                                settings: RouteSettings(
                                  arguments: {
                                    'animal': animal,
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 0.5),
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    animal.animal.animalName.value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: Colors.black),
                                  ),
                                  CircleAvatar(
                                    radius: 3,
                                    backgroundColor: animal.deviceStatus! == DeviceStatus.online
                                        ? Colors.green
                                        : animal.deviceStatus! == DeviceStatus.noGps
                                            ? Colors.orange
                                            : Colors.red,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      markerRotateAlignment: Alignment.center,
                      markers: [
                        ...widget.animals
                            .where((element) =>
                                element.data.isNotEmpty &&
                                element.data.first.lat.value != null &&
                                element.data.first.lon.value != null)
                            .map(
                              (animal) => Marker(
                                point: LatLng(
                                  animal.data.first.lat.value!,
                                  animal.data.first.lon.value!,
                                ),
                                builder: (context) {
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: Icon(
                                      Icons.location_on,
                                      size: 25,
                                      color: HexColor(animal.animal.animalColor.value),
                                    ),
                                  );

                                  // Icon(
                                  //   Icons.location_on,
                                  //   color: HexColor(animal.animal.animalColor.value),
                                  //   size: 30,
                                  // );
                                },
                              ),
                            )
                            .toList()
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_distance.ceilToDouble()}m',
                        style: theme.textTheme.bodyMedium!
                            .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 2,
                            height: 10,
                            child: Container(
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 2,
                            child: Container(
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 2,
                            height: 10,
                            child: Container(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }
}
