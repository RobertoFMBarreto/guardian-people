import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/helpers/fence.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/helpers/map_helper.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
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
  final TextEditingController _nameController = TextEditingController();

  late Future _future;
  late PolyEditor _polyEditor;
  late Polygon _editingPolygon;

  Position? _currentPosition;

  List<Animal> _animals = [];
  List<LatLng> _fencePoints = [];
  List<Polygon> _polygons = <Polygon>[];

  bool isLoading = true;
  bool _firstRun = true;
  bool _isCircle = false;
  String _fenceName = '';
  bool _satellite = false;
  bool _isStayInside = true;
  Color _fenceColor = Colors.red;

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
    isSnackbarActive = false;
    await _getCurrentPosition();
    await _loadAnimals().then((value) async {
      if (widget.fence != null) {
        await _loadFencePoints();

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
    });
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
            _fencePoints.addAll(allPoints.map((e) => LatLng(e.lat, e.lon)));
          });
        }
      },
    );
  }

  /// Method that loads the animals into the [_animals] list
  Future<void> _loadAnimals() async {
    await _loadLocalAnimals().then(
      (value) async => await AnimalRequests.getAnimalsFromApiWithLastLocation(
        context: context,
        onFailed: (statusCode) {
          if (!hasConnection && !isSnackbarActive) {
            showNoConnectionSnackBar();
          } else {
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
          }
        },
        onDataGotten: () async {
          await _loadLocalAnimals();
        },
      ),
    );
  }

  Future<void> _loadLocalAnimals() async {
    await getUserAnimalsWithLastLocation().then(
      (allDevices) {
        setState(() {
          _animals = [];
          _animals.addAll(allDevices);
        });
      },
    );
  }

  /// Method that stores/updates the fence data and points
  Future<void> _confirmGeofence() async {
    String idFence = widget.fence != null ? widget.fence!.idFence : const Uuid().v4();
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
                isCenter: const drift.Value(false),
                lat: drift.Value(e.latitude),
                lon: drift.Value(e.longitude),
              ),
            )
            .toList(),
      );
    }
    // if is edit mode
    if (widget.fence != null) {
      final updatedFence = widget.fence!
          .copyWith(
            name: _fenceName,
            color: HexColor.toHex(color: _fenceColor),
          )
          .toCompanion(true);
      // first udpate the fence
      await updateFence(
        updatedFence,
      ).then(
        (_) => FencingRequests.updateFence(
          fence: updatedFence,
          fencePoints: fencePoints,
          context: context,
          onFailed: (statusCode) {
            if (!hasConnection && !isSnackbarActive) {
              showNoConnectionSnackBar();
            } else {
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
            }
          },
        ),
      );
    } else {
      final newFence = FenceCompanion(
        idFence: drift.Value(idFence),
        name: drift.Value(_fenceName),
        color: drift.Value(HexColor.toHex(color: _fenceColor)),
        idUser: drift.Value((await getUid(context))!),
        isStayInside: drift.Value(_isStayInside),
      );

      await createFence(
        newFence,
      ).then(
        (_) => FencingRequests.createFence(
          fence: newFence,
          fencePoints: fencePoints,
          context: context,
          onFailed: (statusCode) {
            if (!hasConnection && !isSnackbarActive) {
              showNoConnectionSnackBar();
            } else {
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
            }
          },
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
                            bounds: widget.fence != null || _animals.isEmpty
                                ? LatLngBounds.fromPoints(_fencePoints)
                                : _animals.isNotEmpty
                                    ? LatLngBounds.fromPoints(_animals
                                        .map(
                                          (e) => LatLng(
                                            e.data.first.lat.value!,
                                            e.data.first.lon.value!,
                                          ),
                                        )
                                        .toList())
                                    : null,
                            onTap: (_, ll) {
                              _polyEditor.add(_editingPolygon.points, ll);
                            },
                            boundsOptions: FitBoundsOptions(
                                padding: kIsWeb || isBigScreen
                                    ? const EdgeInsets.all(100)
                                    : const EdgeInsets.all(20)),
                            center: widget.fence == null
                                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                                : getFenceCenter(_fencePoints),
                            zoom: 17,
                            minZoom: 3,
                            maxZoom: 18,
                          ),
                          children: [
                            getTileLayer(context, satellite: _satellite),
                            CurrentLocationLayer(
                              followAnimationCurve: Curves.linear,
                              rotateAnimationCurve: Curves.linear,
                              moveAnimationCurve: Curves.linear,
                            ),
                            if (_polyEditor.points.length >= 2 && _isCircle)
                              getCircleFences(_polygons),
                            getPolygonFences(_polygons),
                            DragMarkers(
                              markers: _polyEditor.edit(),
                            ),
                            MarkerLayer(
                              markers: [
                                ..._animals
                                    .map(
                                      (device) => Marker(
                                        point: LatLng(device.data.first.lat.value!,
                                            device.data.first.lon.value!),
                                        height: 50,
                                        builder: (context) {
                                          return Center(
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: getMarker(device.animal.animalColor.value),
                                                ),
                                                const Expanded(
                                                  child: SizedBox(),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    .toList(),
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
                                        setState(() {
                                          _fenceColor = color;
                                        });
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
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            color: theme.colorScheme.background.withOpacity(0.5),
                            height: 50,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: PopupMenuButton(
                            onSelected: (value) {
                              switch (value) {
                                case '/satellite':
                                  setState(() {
                                    _satellite = !_satellite;
                                  });
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: '/satellite',
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${localizations.satellite.capitalizeFirst!}:",
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                        Switch(
                                          activeTrackColor: theme.colorScheme.secondary,
                                          inactiveTrackColor:
                                              Theme.of(context).brightness == Brightness.light
                                                  ? gdToggleGreyArea
                                                  : gdDarkToggleGreyArea,
                                          value: _satellite,
                                          onChanged: (value) {
                                            setState(() {
                                              _satellite = value;
                                            });
                                            this.setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                            icon: Icon(
                              Icons.tune,
                              color: theme.colorScheme.onBackground,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //if (!kIsWeb)
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
                                  mainAxisAlignment: kIsWeb
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (!kIsWeb) {
                                          Navigator.of(context).pop();
                                        } else {
                                          widget.onFenceCreated!();
                                        }
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
                                    if (kIsWeb)
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _future = _confirmGeofence();
                                        });
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
