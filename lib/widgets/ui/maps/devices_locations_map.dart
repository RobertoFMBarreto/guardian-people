import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/settings/colors.dart';
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
  const AnimalsLocationsMap({
    super.key,
    required this.showCurrentPosition,
    required this.animals,
    this.fences,
    this.centerOnPoly = false,
    this.centerOnDevice = false,
    this.reloadMap,
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
          _allFencesPoints.addAll(points);
          return points.length == 2
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
              bounds: widget.centerOnPoly
                  ? LatLngBounds.fromPoints(_allFencesPoints)
                  : _animalsDataPoints.isNotEmpty
                      ? LatLngBounds.fromPoints(_animalsDataPoints)
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
                            return Icon(
                              Icons.location_on,
                              color: HexColor(animal.animal.animalColor.value),
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
