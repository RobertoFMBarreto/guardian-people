import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/tables/Fences/fence_points.dart';
import 'package:guardian/models/helpers/fence.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/helpers/map_helper.dart';
import 'package:guardian/models/providers/api/requests/fencing_requests.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/widgets/inputs/color_picker_input.dart';
import 'package:guardian/widgets/ui/common/color_circle.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';

/// Class that represents the geofencing widget
class Geofencing extends StatefulWidget {
  final FenceData? fence;
  final Function()? onFenceCreated;
  const Geofencing({super.key, this.fence, this.onFenceCreated});

  @override
  State<Geofencing> createState() => _GeofencingState();
}

class _GeofencingState extends State<Geofencing> {
  List<Polygon> _polygons = <Polygon>[];

  final TextEditingController _nameController = TextEditingController();

  late PolyEditor _polyEditor;
  late Polygon _editingPolygon;
  late Future _future;

  Position? _currentPosition;

  bool _isCircle = false;
  bool isLoading = true;
  bool _isStayInside = true;
  String _fenceName = '';
  Color _fenceColor = Colors.red;

  List<LatLng> _fencePoints = [];
  final List<Animal> _animals = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  /// Method that does the initial setup of the widget
  ///
  /// 1. get current position
  /// 2. load fence points
  /// 3. load animals
  /// 4. set the fence data
  /// 5. init the polygons
  Future<void> _setup() async {
    await _getCurrentPosition();
    if (widget.fence != null) {
      await _loadFencePoints();
      await _loadAnimals();
      if (mounted) {
        setState(() {
          // if there are only 2 points then its a circle
          _isCircle = _fencePoints.length == 2;
          _fenceName = widget.fence!.name;
          _fenceColor = HexColor(widget.fence!.color);
          _nameController.text = _fenceName;
        });
      }
    }
    if (mounted) {
      _initPolygon();
      _initPolyEditor();
    }
  }

  /// Method that sets the [_editingPolyon] and adds all points to it
  void _initPolygon() {
    _editingPolygon = Polygon(
      color: widget.fence != null
          ? HexColor(widget.fence!.color).withOpacity(0.5)
          : _fenceColor.withOpacity(0.5),
      borderColor: widget.fence != null ? HexColor(widget.fence!.color) : _fenceColor,
      borderStrokeWidth: 2,
      isFilled: true,
      points: [],
    );
    if (widget.fence != null) {
      _editingPolygon.points.addAll(_fencePoints);
    }
  }

  /// Method that changes the [_editingPolygon] color
  void _changePolygonColor() {
    setState(() {
      _editingPolygon = Polygon(
        color: widget.fence != null && HexColor.toHex(color: _fenceColor) == widget.fence!.color
            ? HexColor(widget.fence!.color).withOpacity(0.5)
            : _fenceColor.withOpacity(0.5),
        borderColor:
            widget.fence != null && HexColor.toHex(color: _fenceColor) == widget.fence!.color
                ? HexColor(widget.fence!.color)
                : _fenceColor,
        borderStrokeWidth: 2,
        isFilled: true,
        points: _editingPolygon.points,
      );
      _polygons = [];
      _polygons.add(_editingPolygon);
    });
  }

  /// Method that sets the polygon editor [_polyEditor] with the default configurations
  void _initPolyEditor() {
    _polyEditor = PolyEditor(
      addClosePathMarker: true,
      points: _editingPolygon.points,
      pointIcon: const Icon(
        Icons.circle,
        size: 23,
        color: Colors.black,
      ),
      intermediateIcon: _isCircle
          ? null
          : const Icon(
              Icons.square_rounded,
              size: 23,
              color: Colors.black,
            ),
      intermediateIconSize: const Size(50, 50),
      pointIconSize: const Size(50, 50),
      callbackRefresh: () {
        if (_editingPolygon.points.length > 2 && _isCircle) {
          _polyEditor.remove(_editingPolygon.points.length - 2);
        }

        setState(() {});
      },
    );

    _polygons.add(_editingPolygon);
  }

  /// Method that loads the current into [_currentPosition]
  Future<void> _getCurrentPosition() async {
    await getCurrentPosition(
      context,
      (position) {
        if (mounted) {
          setState(() => _currentPosition = position);
        }
      },
    );
  }

  /// Method that resets [_editingPolygon] points
  void _resetPolygon() {
    _editingPolygon.points.clear();
    if (widget.fence != null) {
      if (_fencePoints.length == 2 && _isCircle) {
        _editingPolygon.points.addAll(_fencePoints);
      } else if (_fencePoints.length > 2 && !_isCircle) {
        _editingPolygon.points.addAll(_fencePoints);
      } else {
        _editingPolygon.points.clear();
      }
    }
  }

  /// Method that loads the fence points into the [_fencePoints] list
  Future<void> _loadFencePoints() async {
    await getFencePoints(widget.fence!.idFence).then(
      (allPoints) {
        if (mounted) {
          setState(() {
            _fencePoints = [];
            _fencePoints.addAll(allPoints);
          });
        }
      },
    );
  }

  /// Method that loads the animals into the [_animals] list
  Future<void> _loadAnimals() async {
    await getUserAnimalsWithData().then(
      (allDevices) => _animals.addAll(allDevices),
    );
  }

  /// Method that stores/updates the fence data and points
  Future<void> _confirmGeofence() async {
    String idFence;
    // if is edit mode
    if (widget.fence != null) {
      idFence = widget.fence!.idFence;
      // first udpate the fence
      await updateFence(
        widget.fence!
            .copyWith(
              name: _fenceName,
              color: HexColor.toHex(color: _fenceColor),
            )
            .toCompanion(true),
      );
    } else {
      idFence = const Uuid().v4();
      final newFence = FenceCompanion(
        idFence: drift.Value(idFence),
        name: drift.Value(_fenceName),
        color: drift.Value(HexColor.toHex(color: _fenceColor)),
        idUser: drift.Value((await getUid(context))!),
        isStayInside: drift.Value(_isStayInside),
      );
      List<FencePointsCompanion> fencePoints = [];

      if (_editingPolygon.points.length == 2) {
        fencePoints.add(
          FencePointsCompanion(
            idFencePoint: drift.Value(const Uuid().v4()),
            idFence: drift.Value(idFence),
            isCenter: const drift.Value(true),
            lat: drift.Value(_editingPolygon.points[0].latitude),
            lon: drift.Value(_editingPolygon.points[0].longitude),
          ),
        );
        fencePoints.add(
          FencePointsCompanion(
            idFencePoint: drift.Value(const Uuid().v4()),
            idFence: drift.Value(idFence),
            isCenter: const drift.Value(false),
            lat: drift.Value(_editingPolygon.points[1].latitude),
            lon: drift.Value(_editingPolygon.points[1].longitude),
          ),
        );
      } else {
        fencePoints.addAll(
          _editingPolygon.points
              .map(
                (e) => FencePointsCompanion(
                  idFencePoint: drift.Value(const Uuid().v4()),
                  idFence: drift.Value(idFence),
                  isCenter: drift.Value(false),
                  lat: drift.Value(e.latitude),
                  lon: drift.Value(e.longitude),
                ),
              )
              .toList(),
        );
      }

      await createFence(
        newFence,
      ).then(
        (_) => FencingRequests.createFence(
          fence: newFence,
          fencePoints: fencePoints,
          context: context,
          onFailed: () {},
        ),
      );
    }
    // second update fence points
    createFencePointFromList(_editingPolygon.points, idFence).then(
      (value) => Navigator.of(context).pop(_editingPolygon.points),
    );

    if (widget.onFenceCreated != null) {
      widget.onFenceCreated!();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomCircularProgressIndicator();
          } else {
            return Column(
              children: [
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        FlutterMap(
                          key: Key(_fenceColor.toString()),
                          options: MapOptions(
                            bounds:
                                widget.fence != null ? LatLngBounds.fromPoints(_fencePoints) : null,
                            onTap: (_, ll) {
                              _polyEditor.add(_editingPolygon.points, ll);
                            },
                            center: widget.fence == null
                                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                                : getFenceCenter(_fencePoints),
                            zoom: 17,
                            minZoom: 3,
                            maxZoom: 18,
                          ),
                          children: [
                            getTileLayer(context),
                            if (_polyEditor.points.length >= 2 && _isCircle)
                              getCircleFences(_polygons),
                            getPolygonFences(_polygons),
                            DragMarkers(
                              markers: _polyEditor.edit(),
                            ),
                            MarkerLayer(
                              markers: [
                                ..._animals
                                    .where((element) =>
                                        element.data.isNotEmpty &&
                                        element.data.first.lat.value != null &&
                                        element.data.first.lon.value != null)
                                    .map(
                                      (device) => Marker(
                                        point: LatLng(device.data.first.lat.value!,
                                            device.data.first.lon.value!),
                                        builder: (context) {
                                          return Icon(
                                            Icons.location_on,
                                            color: HexColor(device.animal.animalColor.value),
                                            size: 30,
                                          );
                                        },
                                      ),
                                    )
                                    .toList(),
                                Marker(
                                  point: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  builder: (context) {
                                    return const Icon(
                                      Icons.circle,
                                      color: gdMapLocationPointColor,
                                      size: 30,
                                    );
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => CustomColorPickerInput(
                                      pickerColor: _fenceColor,
                                      onSave: (color) {
                                        // TODO: Logic to update device color
                                        setState(() {
                                          _fenceColor = color;
                                        });

                                        // TODO update fence
                                        _changePolygonColor();
                                      },
                                      hexColor: HexColor.toHex(color: _fenceColor),
                                    ),
                                  );
                                },
                                child: ColorCircle(
                                  color: _fenceColor,
                                  radius: 15,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FloatingActionButton.small(
                                    heroTag: 'polygon',
                                    backgroundColor: _isCircle
                                        ? Colors.white
                                        : const Color.fromRGBO(182, 255, 199, 1),
                                    onPressed: () {
                                      setState(() {
                                        _isCircle = false;
                                        _resetPolygon();
                                      });
                                    },
                                    child: const Icon(Icons.square_outlined),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FloatingActionButton.small(
                                    heroTag: 'circle',
                                    backgroundColor: _isCircle
                                        ? const Color.fromRGBO(182, 255, 199, 1)
                                        : Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        _isCircle = true;
                                        _resetPolygon();
                                      });
                                    },
                                    child: const Icon(Icons.circle_outlined),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FloatingActionButton.small(
                                    heroTag: 'reset',
                                    child: const Icon(Icons.replay),
                                    onPressed: () {
                                      setState(() {
                                        _resetPolygon();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (!kIsWeb)
                  Wrap(
                      //flex: 3,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0, top: 20, bottom: 20),
                          child: Center(
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: TextField(
                                      onChanged: (newValue) {
                                        _fenceName = newValue;
                                      },
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        label: Text(
                                          localizations.fence_name.capitalizeFirst!,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            '${localizations.keep_animal.capitalizeFirst!}:',
                                            style: theme.textTheme.bodyLarge!.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.brightness == Brightness.light
                                                  ? gdTextColor
                                                  : gdDarkTextColor,
                                            ),
                                          ),
                                        ),
                                        ToggleSwitch(
                                          initialLabelIndex: _isStayInside ? 0 : 1,
                                          cornerRadius: 50,
                                          radiusStyle: true,
                                          activeBgColor: [theme.colorScheme.secondary],
                                          activeFgColor: theme.colorScheme.onSecondary,
                                          inactiveBgColor:
                                              Theme.of(context).brightness == Brightness.light
                                                  ? gdToggleGreyArea
                                                  : gdDarkToggleGreyArea,
                                          inactiveFgColor:
                                              Theme.of(context).brightness == Brightness.light
                                                  ? Colors.black
                                                  : Colors.white,
                                          customTextStyles: const [
                                            TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                                            TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                                          ],
                                          totalSwitches: 2,
                                          labels: [
                                            localizations.inside.capitalizeFirst!,
                                            localizations.outside.capitalizeFirst!,
                                          ],
                                          onToggle: (index) {
                                            setState(() {
                                              _isStayInside = index == 1;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(gdDarkCancelBtnColor),
                                        ),
                                        child: Text(
                                          localizations.cancel.capitalizeFirst!,
                                          style: theme.textTheme.bodyLarge!.copyWith(
                                            color: theme.colorScheme.onSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _confirmGeofence();
                                        },
                                        child: Text(
                                          localizations.confirm.capitalizeFirst!,
                                          style: theme.textTheme.bodyLarge!.copyWith(
                                            color: theme.colorScheme.onSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ])
              ],
            );
          }
        },
      ),
    );
  }
}
