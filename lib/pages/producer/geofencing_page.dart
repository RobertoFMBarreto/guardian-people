import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/db/data_models/Fences/fence.dart';
import 'package:guardian/models/db/operations/fence_operations.dart';
import 'package:guardian/models/db/operations/fence_points_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/models/helpers/map_helper.dart';
import 'package:guardian/models/hex_color.dart';
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
  final Fence? fence;
  const GeofencingPage({super.key, this.fence});

  @override
  State<GeofencingPage> createState() => _GeofencingPageState();
}

class _GeofencingPageState extends State<GeofencingPage> {
  final _polygons = <Polygon>[];
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
          : gdMapGeofenceFillColor,
      borderColor: widget.fence != null ? HexColor(widget.fence!.color) : gdMapGeofenceBorderColor,
      borderStrokeWidth: 2,
      isFilled: true,
      points: [],
    );
    if (widget.fence != null) {
      _editingPolygon.points.addAll(fencePoints);
    }
  }

  void _initPolyEditor() {
    _polyEditor = PolyEditor(
      addClosePathMarker: true,
      points: _editingPolygon.points,
      pointIcon: const Icon(Icons.circle, size: 23),
      intermediateIcon: _isCircle ? null : const Icon(Icons.square_rounded, size: 23),
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
      (allPoints) => fencePoints.addAll(allPoints),
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
                        flex: 2,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            FlutterMap(
                              options: MapOptions(
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
                                TileLayer(
                                  //urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  tileProvider: FMTC.instance('guardian').getTileProvider(),
                                ),
                                if (_polyEditor.points.length >= 2 && _isCircle)
                                  CircleLayer(
                                    circles: [
                                      CircleMarker(
                                        useRadiusInMeter: true,
                                        color: widget.fence != null
                                            ? HexColor(widget.fence!.color).withOpacity(0.5)
                                            : gdMapGeofenceFillColor,
                                        borderColor: widget.fence != null
                                            ? HexColor(widget.fence!.color)
                                            : gdMapGeofenceBorderColor,
                                        borderStrokeWidth: 2,
                                        point: LatLng(
                                          _polyEditor.points.first.latitude,
                                          _polyEditor.points.first.longitude,
                                        ),
                                        radius: calculateDistance(
                                          _polyEditor.points.first.latitude,
                                          _polyEditor.points.first.longitude,
                                          _polyEditor.points.last.latitude,
                                          _polyEditor.points.last.longitude,
                                        ),
                                      )
                                    ],
                                  ),
                                getPolygonFences(_polygons),
                                DragMarkers(
                                  markers: _polyEditor.edit(),
                                ),
                                MarkerLayer(
                                  markers: [
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
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        localizations.fence_color.capitalize(),
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
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
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: theme.elevatedButtonTheme.style!.copyWith(
                                        backgroundColor:
                                            const MaterialStatePropertyAll(gdCancelBtnColor),
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
                                      onPressed: () async {
                                        String fenceId;
                                        // if is edit mode
                                        if (widget.fence != null) {
                                          fenceId = widget.fence!.fenceId;
                                          // first udpate the fence
                                          await updateFence(
                                            widget.fence!.copy(
                                              name: _fenceName,
                                              color: HexColor.toHex(color: _fenceColor),
                                            ),
                                          );
                                        } else {
                                          fenceId = _fenceName;
                                          await createFence(
                                            Fence(
                                              fenceId: _fenceName,
                                              name: _fenceName,
                                              color: HexColor.toHex(color: _fenceColor),
                                            ),
                                          );
                                        }

                                        // second update fence points
                                        await createFencePointFromList(
                                            _editingPolygon.points, fenceId);
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).pop(_editingPolygon.points);
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
                              ),
                            ],
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
