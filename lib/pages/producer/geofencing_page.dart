import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/db/fence_operations.dart';
import 'package:guardian/db/fence_points_operations.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/color_circle.dart';
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
  Position? _currentPosition;
  late PolyEditor polyEditor;
  bool isCircle = false;
  bool isLoading = true;

  final polygons = <Polygon>[];
  late Polygon editingPolygon;
  late Polygon backupPolygon;

  String fenceName = '';
  Color fenceColor = Colors.red;
  TextEditingController nameController = TextEditingController();

  List<LatLng> fencePoints = [];

  late String uid;

  @override
  void initState() {
    getUid(context).then((userId) {
      if (userId != null) {
        uid = userId;

        _getCurrentPosition().then((_) {
          if (widget.fence != null) {
            _loadFencePoints().then((_) {
              if (mounted) {
                // if there are only 2 points then its a circle
                isCircle = fencePoints.length == 2;
                fenceName = widget.fence!.name;
                fenceColor = HexColor(widget.fence!.color);
                nameController.text = fenceName;
                _initPolygon();
                _initPolyEditor();
                setState(() {
                  isLoading = false;
                });
                print(fencePoints);
              }
            });
          } else {
            if (mounted) {
              _initPolygon();
              _initPolyEditor();
              setState(() {
                isLoading = false;
              });
            }
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _initPolygon() {
    editingPolygon = Polygon(
      color: widget.fence != null
          ? HexColor(widget.fence!.color).withOpacity(0.5)
          : gdMapGeofenceFillColor,
      borderColor: widget.fence != null ? HexColor(widget.fence!.color) : gdMapGeofenceBorderColor,
      borderStrokeWidth: 2,
      isFilled: true,
      points: [],
    );
    if (widget.fence != null) {
      editingPolygon.points.addAll(fencePoints);
    }
  }

  void _initPolyEditor() {
    polyEditor = PolyEditor(
      addClosePathMarker: true,
      points: editingPolygon.points,
      pointIcon: const Icon(Icons.circle, size: 23),
      intermediateIcon: isCircle ? null : const Icon(Icons.square_rounded, size: 23),
      intermediateIconSize: const Size(50, 50),
      pointIconSize: const Size(50, 50),
      callbackRefresh: () {
        if (editingPolygon.points.length > 2 && isCircle) {
          polyEditor.remove(editingPolygon.points.length - 2);
        }

        setState(() {});
      },
    );

    polygons.add(editingPolygon);
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await handleLocationPermission(context);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.reduced)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void _resetPolygon() {
    editingPolygon.points.clear();
    if (widget.fence != null) {
      if (fencePoints.length == 2 && isCircle) {
        editingPolygon.points.addAll(fencePoints);
      } else if (fencePoints.length > 2 && !isCircle) {
        editingPolygon.points.addAll(fencePoints);
      } else {
        editingPolygon.points.clear();
      }
    }
  }

  Future<void> _loadFencePoints() async {
    await getFencePoints(widget.fence!.fenceId).then((allPoints) => fencePoints.addAll(allPoints));
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
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            onTap: (_, ll) {
                              polyEditor.add(editingPolygon.points, ll);
                            },
                            center: widget.fence == null
                                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                                : getFenceCenter(fencePoints),
                            zoom: 17,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            ),
                            if (polyEditor.points.length >= 2 && isCircle)
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
                                      polyEditor.points.first.latitude,
                                      polyEditor.points.first.longitude,
                                    ),
                                    radius: calculateDistance(
                                      polyEditor.points.first.latitude,
                                      polyEditor.points.first.longitude,
                                      polyEditor.points.last.latitude,
                                      polyEditor.points.last.longitude,
                                    ),
                                  )
                                ],
                              ),
                            PolygonLayer(polygons: polygons),
                            DragMarkers(
                              markers: polyEditor.edit(),
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
                              backgroundColor:
                                  isCircle ? Colors.white : const Color.fromRGBO(182, 255, 199, 1),
                              onPressed: () {
                                setState(() {
                                  isCircle = false;
                                  _resetPolygon();
                                });
                              },
                              child: const Icon(Icons.square_outlined),
                            ),
                            FloatingActionButton.small(
                              heroTag: 'circle',
                              backgroundColor:
                                  isCircle ? const Color.fromRGBO(182, 255, 199, 1) : Colors.white,
                              onPressed: () {
                                setState(() {
                                  isCircle = true;
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
                              fenceName = newValue;
                            },
                            controller: nameController,
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
                                          pickerColor: fenceColor,
                                          onSave: (color) {
                                            //!TODO: Logic to update device color
                                            setState(() {
                                              fenceColor = color;
                                            });

                                            //!TODO update fence
                                          },
                                          hexColor: HexColor.toHex(color: fenceColor),
                                        ),
                                      );
                                    },
                                    child: ColorCircle(
                                      color: fenceColor,
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
                                          name: fenceName,
                                          color: HexColor.toHex(color: fenceColor),
                                        ),
                                      );
                                    } else {
                                      fenceId = fenceName;
                                      await createFence(
                                        Fence(
                                          fenceId: fenceName,
                                          name: fenceName,
                                          color: HexColor.toHex(color: fenceColor),
                                        ),
                                      );
                                    }

                                    // second update fence points
                                    await createFencePointFromList(editingPolygon.points, fenceId);
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pop(editingPolygon.points);
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
              ),
      ),
    );
  }
}
