import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_animal_operations.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/helpers/map_marker.dart';
import 'package:guardian/models/providers/api/requests/fencing_requests.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:guardian/models/utils/map_utils.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/maps/single_device_location_map.dart';

class NewMapTest extends StatefulWidget {
  final bool showCurrentPosition;
  final List<AnimalLocationsCompanion> deviceData;
  final String idAnimal;
  final String deviceColor;
  final Function(double) onZoomChange;
  final double startingZoom;
  final DateTime startDate;
  final DateTime endDate;
  final bool isInterval;
  const NewMapTest(
      {super.key,
      required this.deviceData,
      required this.showCurrentPosition,
      required this.idAnimal,
      required this.deviceColor,
      required this.onZoomChange,
      required this.startingZoom,
      required this.startDate,
      required this.endDate,
      required this.isInterval});

  @override
  State<NewMapTest> createState() => _NewMapTestState();
}

class _NewMapTestState extends State<NewMapTest> {
  final _polygons = <Polygon>[];
  final _circles = <Polygon>[];
  final CameraPosition _parisCameraPosition =
      CameraPosition(target: LatLng(48.856613, 2.352222), zoom: 12.0);

  late ClusterManager _clusterManager;
  late Future _future;

  Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> markers = Set();
  List<PlaceModel> items = [];
  String _mapStyle = '';
  bool _showFence = true;
  bool _showRoute = false;
  bool _showHeatMap = false;
  bool _firstRun = true;

  Position? _currentPosition;
  AnimalLocationsCompanion? lastLocation;

  @override
  void initState() {
    _future = _setup();

    super.initState();
  }

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

    lastLocation = widget.deviceData
        .firstWhere((element) => element.lat.value != null && element.lon.value != null);

    setState(() {
      items = [];
      items.addAll(
        widget.isInterval && widget.deviceData.isNotEmpty
            ? widget.deviceData
                .where((element) => element.lat.value != null && element.lon.value != null)
                .map(
                  (e) => PlaceModel(
                    latLng: LatLng(e.lat.value!, e.lon.value!),
                    id: e.animalDataId.value,
                  ),
                )
                .toList()
            : widget.deviceData.isNotEmpty && lastLocation != null
                ? [
                    PlaceModel(
                      latLng: LatLng(lastLocation!.lat.value!, lastLocation!.lon.value!),
                      id: lastLocation!.animalDataId.value,
                    )
                  ]
                : [],
      );
    });
    _clusterManager = _initClusterManager();

    await _loadAnimalFences().then(
      (_) => FencingRequests.getUserFences(
        context: context,
        onGottenData: (_) async {
          await _loadAnimalFences();
        },
        onFailed: (statusCode) {
          if (statusCode == 507 || statusCode == 404) {
            if (_firstRun == true) {
              showNoConnectionSnackBar();
            }
            _firstRun = false;
          } else if (!isSnackbarActive) {
            AppLocalizations localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(localizations.server_error)));
          }
        },
      ),
    );
  }

  _onMapCreated(GoogleMapController controller) async {
    if (mounted) {
      setState(() {
        _mapController.complete(controller);
        _clusterManager.setMapId(controller.mapId);
        controller.setMapStyle(_mapStyle);
        controller.animateCamera(
          CameraUpdate.newLatLngBounds(
            MapUtils.boundsFromLatLngList(
              items.map((e) => LatLng(e.latLng.latitude, e.latLng.longitude)).toList(),
            ),
            50,
          ),
        );
      });
    }
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<PlaceModel>(
      items,
      _updateMarkers,
      markerBuilder: _markerBuilder,
      stopClusteringZoom: 17,
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      this.markers = markers;
    });
  }

  Future<Marker> Function(Cluster<PlaceModel>) get _markerBuilder => (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          draggable: false,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            HSVColor.fromColor(
              HexColor(widget.deviceColor),
            ).hue,
          ),
        );
      };

  /// Method that loads the animal fences into [_polygons] list
  Future<void> _loadAnimalFences() async {
    List<Polygon> allFences = [];
    await getAnimalFence(widget.idAnimal).then((fence) async {
      if (fence != null) {
        // List<LatLng> fencePoints = [];
        // fencePoints.addAll(await getFencePoints(fence.idFence));
        // allFences.add(
        //   Polygon(
        //     points: fencePoints,
        //     color: HexColor(fence.color).withOpacity(0.5),
        //     borderColor: HexColor(fence.color),
        //     borderStrokeWidth: 2,
        //     isFilled: true,
        //   ),
        // );
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
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomCircularProgressIndicator();
        } else {
          return GoogleMap(
            minMaxZoomPreference: const MinMaxZoomPreference(6, 18),
            mapType: MapType.satellite,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: _onMapCreated,
            onCameraMove: (CameraPosition cameraPosition) {
              print(cameraPosition.zoom);
              _clusterManager.onCameraMove(cameraPosition);
            },
            onCameraIdle: _clusterManager.updateMap,
            initialCameraPosition: CameraPosition(
              target: items.isEmpty
                  ? LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                  : LatLng(
                      items.first.latLng.latitude,
                      items.first.latLng.latitude,
                    ),
              zoom: 18,
            ),
            //polygons: {..._polygons},
            // circles: {..._circles},
            markers: markers,
          );
        }
      },
    );
  }
}
