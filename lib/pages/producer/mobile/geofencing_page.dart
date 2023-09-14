import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/device_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/fence.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/models/helpers/map_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:guardian/widgets/ui/common/color_circle.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/inputs/color_picker_input.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GeofencingPage extends StatefulWidget {
  final FenceData? fence;
  const GeofencingPage({super.key, this.fence});

  @override
  State<GeofencingPage> createState() => _GeofencingPageState();
}

class _GeofencingPageState extends State<GeofencingPage> {
  List<Polygon> _polygons = <Polygon>[];
  final TextEditingController _nameController = TextEditingController();

  late PolyEditor _polyEditor;
  late Polygon _editingPolygon;
  late Future _future;

  Position? _currentPosition;

  bool _isCircle = false;
  bool isLoading = true;
  String _fenceName = '';
  Color _fenceColor = Colors.red;

  List<LatLng> fencePoints = [];
  final List<Device> _devices = [];

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

  Future<void> _setup() async {
    await _getCurrentPosition();
    if (widget.fence != null) {
      await _loadFencePoints();
      await _loadDevices();
      if (mounted) {
        setState(() {
          // if there are only 2 points then its a circle
          _isCircle = fencePoints.length == 2;
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
      _editingPolygon.points.addAll(fencePoints);
    }
  }

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

  void _resetPolygon() {
    _editingPolygon.points.clear();
    if (widget.fence != null) {
      if (fencePoints.length == 2 && _isCircle) {
        _editingPolygon.points.addAll(fencePoints);
      } else if (fencePoints.length > 2 && !_isCircle) {
        _editingPolygon.points.addAll(fencePoints);
      } else {
        _editingPolygon.points.clear();
      }
    }
  }

  Future<void> _loadFencePoints() async {
    await getFencePoints(widget.fence!.fenceId).then(
      (allPoints) {
        if (mounted) {
          setState(() {
            fencePoints = [];
            fencePoints.addAll(allPoints);
          });
        }
      },
    );
  }

  Future<void> _loadDevices() async {
    await getUserDevicesWithData().then(
      (allDevices) => _devices.addAll(allDevices),
    );
  }

  Future<void> _confirmGeofence() async {
    String fenceId;
    // if is edit mode
    if (widget.fence != null) {
      fenceId = widget.fence!.fenceId;
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
      fenceId = _fenceName;
      await createFence(
        FenceCompanion(
          fenceId: drift.Value(_fenceName),
          name: drift.Value(_fenceName),
          color: drift.Value(HexColor.toHex(color: _fenceColor)),
        ),
      );
    }

    // second update fence points
    createFencePointFromList(_editingPolygon.points, fenceId).then(
      (value) => Navigator.of(context).pop(_editingPolygon.points),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              '${widget.fence != null ? localizations.edit.capitalize() : localizations.add.capitalize()} ${localizations.fence.capitalize()}',
              style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
            // actions: [
            //   TextButton(
            //       onPressed: () {},
            //       child: Text(
            //         localizations.confirm.capitalize(),
            //         style: theme.textTheme.bodyMedium!.copyWith(
            //           color: gdSecondaryColor,
            //         ),
            //       ))
            // ],
          ),
          body: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomCircularProgressIndicator();
                } else {
                  return Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            FlutterMap(
                              key: Key(_fenceColor.toString()),
                              options: MapOptions(
                                bounds: widget.fence != null
                                    ? LatLngBounds.fromPoints(fencePoints)
                                    : null,
                                onTap: (_, ll) {
                                  _polyEditor.add(_editingPolygon.points, ll);
                                },
                                center: widget.fence == null
                                    ? LatLng(
                                        _currentPosition!.latitude, _currentPosition!.longitude)
                                    : getFenceCenter(fencePoints),
                                zoom: 17,
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
                                    ..._devices
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
                                                color: HexColor(device.device.color.value),
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
                                    FloatingActionButton.small(
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
                                    FloatingActionButton.small(
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
                                    FloatingActionButton.small(
                                      heroTag: 'reset',
                                      child: const Icon(Icons.replay),
                                      onPressed: () {
                                        setState(() {
                                          _resetPolygon();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
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
                                          localizations.fence_name.capitalize(),
                                        ),
                                      ),
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
                                          localizations.cancel.capitalize(),
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
                                          localizations.confirm.capitalize(),
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
                      )
                    ],
                  );
                }
              })),
    );
  }
}
