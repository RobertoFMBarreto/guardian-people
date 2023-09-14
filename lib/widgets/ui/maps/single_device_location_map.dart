import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/map_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SingleDeviceLocationMap extends StatefulWidget {
  final bool showCurrentPosition;
  final List<DeviceLocationsCompanion> deviceData;
  final String imei;
  final String deviceColor;
  final Function(double) onZoomChange;
  final double startingZoom;
  final DateTime startDate;
  final DateTime endDate;
  final bool isInterval;
  const SingleDeviceLocationMap({
    super.key,
    required this.showCurrentPosition,
    required this.deviceData,
    required this.onZoomChange,
    required this.startingZoom,
    required this.startDate,
    required this.endDate,
    required this.isInterval,
    required this.imei,
    required this.deviceColor,
  });

  @override
  State<SingleDeviceLocationMap> createState() => _SingleDeviceLocationMapState();
}

class _SingleDeviceLocationMapState extends State<SingleDeviceLocationMap> {
  final _polygons = <Polygon>[];
  final _circles = <Polygon>[];
  final MapController _mapController = MapController();

  late Future _future;
  late String _dropDownValue;

  List<String> dropdownItems = [
    'normal',
    'heatmap',
  ];

  bool _showFence = true;
  bool _showRoute = false;
  bool _showHeatMap = false;
  Position? _currentPosition;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _setup() async {
    setState(() {
      _dropDownValue = dropdownItems.first;
    });
    await getCurrentPosition(
      context,
      (position) {
        if (mounted) {
          setState(() => _currentPosition = position);
        }
      },
    );
    await _loadDeviceFences();
  }

  Future<void> _loadDeviceFences() async {
    List<Polygon> allFences = [];
    await getDeviceFence(widget.imei).then((fence) async {
      if (fence != null) {
        List<LatLng> fencePoints = [];
        fencePoints.addAll(await getFencePoints(fence.fenceId));
        allFences.add(
          Polygon(
            points: fencePoints,
            color: HexColor(fence.color).withOpacity(0.5),
            borderColor: HexColor(fence.color),
            borderStrokeWidth: 2,
            isFilled: true,
          ),
        );
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
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    List<DeviceLocationsCompanion> data = widget.isInterval && widget.deviceData.isNotEmpty
        ? widget.deviceData
            .where((element) => element.lat.value != null && element.lon.value != null)
            .toList()
        : widget.deviceData.isNotEmpty
            ? [
                widget.deviceData
                    .where((element) => element.lat.value != null && element.lon.value != null)
                    .first
              ]
            : [];
    // '${_showFence}_${_showHeatMap}_${widget.device.device.color.value}${widget.isInterval}'
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomCircularProgressIndicator();
        } else {
          return Stack(
            alignment: Alignment.topRight,
            children: [
              FlutterMap(
                key: Key('${widget.deviceData}'),
                mapController: _mapController,
                options: MapOptions(
                  center: data.isNotEmpty && (_polygons.isEmpty || _circles.isEmpty)
                      ? widget.isInterval && data.isEmpty
                          ? LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            )
                          : widget.isInterval ||
                                  data.first.lat.value == null ||
                                  data.first.lon.value == null
                              ? null
                              : LatLng(data.first.lat.value!, data.first.lon.value!)
                      : LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                  onMapReady: () {
                    _mapController.mapEventStream.listen((evt) {
                      widget.onZoomChange(_mapController.zoom);
                    });
                    // And any other `MapController` dependent non-movement methods
                  },
                  zoom: widget.startingZoom,
                  minZoom: 3,
                  maxZoom: 18,
                  boundsOptions: const FitBoundsOptions(padding: EdgeInsets.all(20)),
                  bounds: (_polygons.isNotEmpty || _circles.isNotEmpty) && data.isEmpty
                      ? LatLngBounds.fromPoints(
                          _polygons.isEmpty ? _circles.first.points : _polygons.first.points)
                      : widget.isInterval && data.isNotEmpty
                          ? LatLngBounds.fromPoints(
                              data.map((e) => LatLng(e.lat.value!, e.lon.value!)).toList(),
                            )
                          : null,
                ),
                children: [
                  getTileLayer(context),
                  if (_showFence) ...[
                    getCircleFences(_circles),
                    getPolygonFences(_polygons),
                  ],
                  if (widget.isInterval && !_showHeatMap && _showRoute)
                    PolylineLayer(
                      key: Key('$_showRoute'),
                      polylines: [
                        Polyline(
                          color: gdErrorColor,
                          strokeWidth: 5,
                          points: data
                              .map(
                                (e) => LatLng(e.lat.value!, e.lon.value!),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  if (data.isNotEmpty && _showHeatMap)
                    HeatMapLayer(
                      key: Key('$_showHeatMap'),
                      heatMapDataSource: InMemoryHeatMapDataSource(
                        data: data
                            .map(
                              (e) => WeightedLatLng(LatLng(e.lat.value!, e.lon.value!), 1),
                            )
                            .toList(),
                      ),
                    )
                  else ...[
                    !_showRoute
                        ? MarkerClusterLayerWidget(
                            options: MarkerClusterLayerOptions(
                              maxClusterRadius: 45,
                              size: const Size(40, 40),
                              anchor: AnchorPos.align(AnchorAlign.center),
                              fitBoundsOptions: const FitBoundsOptions(
                                padding: EdgeInsets.all(50),
                                maxZoom: 15,
                              ),
                              markers: [
                                if (_currentPosition != null)
                                  Marker(
                                    point: LatLng(
                                        _currentPosition!.latitude, _currentPosition!.longitude),
                                    builder: (context) {
                                      return const Icon(
                                        Icons.circle,
                                        color: gdMapLocationPointColor,
                                        size: 30,
                                      );
                                    },
                                  ),
                                ...data
                                    .map(
                                      (e) => Marker(
                                        point: LatLng(e.lat.value!, e.lon.value!),
                                        anchorPos: AnchorPos.align(AnchorAlign.top),
                                        builder: (context) {
                                          return Transform.rotate(
                                            angle: _mapController.rotation * -pi / 180,
                                            alignment: Alignment.bottomCenter,
                                            child: Icon(
                                              Icons.location_on,
                                              color: HexColor(widget.deviceColor),
                                              size: 30,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    .toList()
                              ],
                              builder: (context, markers) {
                                return Transform.rotate(
                                  angle: _mapController.rotation * -pi / 180,
                                  child: Icon(
                                    Icons.location_on,
                                    color: HexColor(widget.deviceColor),
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                          )
                        : MarkerLayer(
                            markers: [
                              if (_currentPosition != null)
                                Marker(
                                  point: LatLng(
                                      _currentPosition!.latitude, _currentPosition!.longitude),
                                  builder: (context) {
                                    return const Icon(
                                      Icons.circle,
                                      color: gdMapLocationPointColor,
                                      size: 30,
                                    );
                                  },
                                ),
                              ...[data.first, data.last]
                                  .map(
                                    (e) => Marker(
                                      point: LatLng(e.lat.value!, e.lon.value!),
                                      anchorPos: AnchorPos.align(AnchorAlign.top),
                                      builder: (context) {
                                        return Transform.rotate(
                                          angle: _mapController.rotation * -pi / 180,
                                          alignment: Alignment.bottomCenter,
                                          child: Icon(
                                            Icons.location_on,
                                            color: HexColor(widget.deviceColor),
                                            size: 30,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                  .toList()
                            ],
                          )
                  ]
                ],
              ),
              if (widget.isInterval)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        iconStyleData: const IconStyleData(
                          iconEnabledColor: gdOnMapColor,
                          iconDisabledColor: gdOnMapColor,
                        ),
                        isExpanded: true,
                        selectedItemBuilder: (context) {
                          return [
                            Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  localizations.normal_map.capitalize(),
                                  style: theme.textTheme.bodyLarge!
                                      .copyWith(color: gdOnMapColor, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                localizations.heatmap.capitalize(),
                                style: theme.textTheme.bodyLarge!
                                    .copyWith(color: gdOnMapColor, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ];
                        },
                        items: dropdownItems
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e == dropdownItems.first
                                      ? localizations.normal_map.capitalize()
                                      : localizations.heatmap.capitalize(),
                                  style: TextStyle(color: theme.colorScheme.onBackground),
                                ),
                              ),
                            )
                            .toList(),
                        value: _dropDownValue,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _showHeatMap = value == dropdownItems.last;
                              _dropDownValue = value;
                              _showFence = false;
                            });
                          }
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          height: 40,
                          width: 150,
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.topRight,
                child: PopupMenuButton(
                  onSelected: (value) {
                    switch (value) {
                      case '/show_fence':
                        setState(() {
                          _showFence = !_showFence;
                        });
                        break;
                      case '/show_route':
                        setState(() {
                          _showRoute = !_showRoute;
                        });
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: '/show_fence',
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "${localizations.show.capitalize()} ${localizations.fence.capitalize()}:",
                                style: theme.textTheme.bodyLarge,
                              ),
                              Switch(
                                activeTrackColor: theme.colorScheme.secondary,
                                inactiveTrackColor: Theme.of(context).brightness == Brightness.light
                                    ? gdToggleGreyArea
                                    : gdDarkToggleGreyArea,
                                value: _showFence,
                                onChanged: (value) {},
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    if (widget.isInterval && !_showHeatMap)
                      PopupMenuItem(
                        value: '/show_route',
                        child: StatefulBuilder(builder: (context, setState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "${localizations.show.capitalize()} ${localizations.route}",
                                style: theme.textTheme.bodyLarge,
                              ),
                              Switch(
                                activeTrackColor: theme.colorScheme.secondary,
                                inactiveTrackColor: Theme.of(context).brightness == Brightness.light
                                    ? gdToggleGreyArea
                                    : gdDarkToggleGreyArea,
                                value: _showRoute,
                                onChanged: (value) {},
                              ),
                            ],
                          );
                        }),
                      ),
                  ],
                  icon: const Icon(Icons.tune),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
