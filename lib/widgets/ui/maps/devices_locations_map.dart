import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guardian/models/utils/map_utils.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/map_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';

// import 'package:latlong2/latlong.dart';

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
  final _circles = <Circle>[];
  final List<LatLng> _animalsDataPoints = [];
  final List<LatLng> _allFencesPoints = [];

  late Future _future;
  late GoogleMapController _mapController;

  Position? _currentPosition;

  String _mapStyle = '';

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
    rootBundle.loadString('assets/maps/map_style.json').then((string) {
      _mapStyle = string;
    });

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

  _onMapCreated(GoogleMapController controller) async {
    if (mounted) {
      setState(() {
        _mapController = controller;
        controller.setMapStyle(_mapStyle);
        controller.animateCamera(
            CameraUpdate.newLatLngBounds(MapUtils.boundsFromLatLngList(_animalsDataPoints), 50));
      });
    }
  }

  // Method that loads all fences into the [allCircles], [allPolygons] and [_allFencesPoints] lists
  Future<void> _loadFences() async {
    List<Polygon> allPolygons = [];
    List<Circle> allCircles = [];
    if (widget.fences != null) {
      for (FenceData fence in widget.fences!) {
        await getFencePoints(fence.idFence).then((points) {
          _allFencesPoints.addAll(points.map((e) => LatLng(e.lat, e.lon)).toList());
          if (points.length == 2) {
            FencePoint center = points.firstWhere((element) => element.isCenter == true);
            FencePoint limit = points.firstWhere((element) => element.isCenter == false);
            return allCircles.add(
              Circle(
                circleId: CircleId(fence.idFence),
                center: LatLng(
                  center.lat,
                  center.lon,
                ),
                radius: calculateDistance(center.lat, center.lon, limit.lat, limit.lon),
                fillColor: HexColor(fence.color).withOpacity(0.5),
                strokeColor: HexColor(fence.color),
                strokeWidth: 2,
              ),
            );
          } else {
            return allPolygons.add(
              Polygon(
                polygonId: PolygonId(fence.idFence),
                points: points.map((e) => LatLng(e.lat, e.lon)).toList(),
                fillColor: HexColor(fence.color).withOpacity(0.5),
                strokeColor: HexColor(fence.color),
                strokeWidth: 2,
              ),
            );
          }
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
          return GoogleMap(
            minMaxZoomPreference: const MinMaxZoomPreference(6, 17),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              zoom: 17,
            ),
            polygons: {..._polygons},
            // circles: {..._circles},
            markers: widget.animals
                .where((element) =>
                    element.data.isNotEmpty &&
                    element.data.first.lat.value != null &&
                    element.data.first.lon.value != null)
                .map(
                  (animal) => Marker(
                    markerId: MarkerId(animal.data.first.animalDataId.value.toString()),
                    position: LatLng(animal.data.first.lat.value!, animal.data.first.lon.value!),
                    draggable: false,
                    infoWindow: InfoWindow(
                      title: animal.animal.animalName.value,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      HSVColor.fromColor(
                        HexColor(animal.animal.animalColor.value),
                      ).hue,
                    ),
                  ),
                )
                .toSet(),
          );
        }
      },
    );
  }
}
