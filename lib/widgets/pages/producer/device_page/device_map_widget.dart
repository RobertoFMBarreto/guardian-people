import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/db/device_data_operations.dart';
import 'package:guardian/db/fence_operations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Device/device_data.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/inputs/range_date_time_input.dart';
import 'package:guardian/widgets/maps/single_device_location_map.dart';
import 'package:guardian/widgets/pages/producer/device_page/device_time_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeviceMapWidget extends StatefulWidget {
  final Device device;
  final bool isInterval;
  const DeviceMapWidget({super.key, required this.device, required this.isInterval});

  @override
  State<DeviceMapWidget> createState() => _DeviceMapWidgetState();
}

class _DeviceMapWidgetState extends State<DeviceMapWidget> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime startDateBackup = DateTime.now();
  DateTime endDateBackup = DateTime.now();
  bool showFence = true;
  bool showRoute = false;
  Position? _currentPosition;
  List<Fence> fences = [];
  List<DeviceData> deviceData = [];

  double currentZoom = 17;

  bool showHeatMap = false;
  int dropDownValue = 0;

  final firstItemDataKey = GlobalKey();

  late String uid;

  @override
  void initState() {
    _getCurrentPosition().then(
      (_) => _loadFences().then(
        (_) => _getDeviceData(),
      ),
    );
    super.initState();
  }

  Future<void> _loadFences() async {
    getUid(context).then((userId) {
      if (mounted) {
        if (userId != null) {
          uid = userId;
          getUserFences().then((allFences) {
            setState(() => fences.addAll(allFences));
          });
        }
      }
    });
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await handleLocationPermission(context);

    if (!hasPermission) return;

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.reduced)
        .then((dynamic position) {
      if (mounted) {
        if (position is Position) {
          setState(() => _currentPosition = position);
        }
      }
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  Future<void> _getDeviceData() async {
    await getDeviceData(
      startDate: startDate,
      endDate: endDate,
      deviceId: widget.device.deviceId,
      isInterval: widget.isInterval,
    ).then(
      (data) async {
        deviceData = [];
        setState(() {
          deviceData.addAll(data);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    dropDownValue = !widget.isInterval ? 0 : dropDownValue;
    showHeatMap = !widget.isInterval ? false : showHeatMap;
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return _currentPosition == null
        ? Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.secondary,
            ),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.isInterval)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RangeDateTimeInput(
                                      startDate: startDate,
                                      endDate: endDate,
                                      onConfirm: (newStartDate, newEndDate) {
                                        setState(() {
                                          startDate = newStartDate;
                                          endDate = newEndDate;
                                        });
                                        _getDeviceData();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DeviceTimeWidget(
                                startDate: startDate,
                                endDate: endDate,
                              ),
                              Icon(
                                Icons.calendar_month,
                                size: 50,
                                color: theme.colorScheme.secondary,
                              )
                            ],
                          ),
                        ),
                      ),
                    if (widget.isInterval)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "${localizations.show.capitalize()} ${localizations.route}",
                            style: theme.textTheme.bodyLarge,
                          ),
                          Switch(
                              activeTrackColor: theme.colorScheme.secondary,
                              value: showRoute,
                              onChanged: (value) {
                                setState(() {
                                  showRoute = value;
                                });
                              }),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.isInterval)
                            DropdownButton(
                              isDense: true,
                              borderRadius: BorderRadius.circular(20),
                              underline: const SizedBox(),
                              value: dropDownValue,
                              items: [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text(
                                    localizations.normal_map.capitalize(),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(
                                    localizations.heatmap.capitalize(),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  if (value != null) {
                                    showHeatMap = value == 1;
                                    dropDownValue = value;
                                    showFence = false;
                                  }
                                });
                              },
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "${localizations.show.capitalize()} ${localizations.fence.capitalize()}:",
                                style: theme.textTheme.bodyLarge,
                              ),
                              Switch(
                                  activeTrackColor: theme.colorScheme.secondary,
                                  value: showFence,
                                  onChanged: (value) {
                                    setState(() {
                                      showFence = value;
                                    });
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      key: firstItemDataKey,
                      height: deviceHeight * 0.45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SingleDeviceLocationMap(
                          key: Key('${showFence}_${showHeatMap}_${widget.device.color}'),
                          showCurrentPosition: true,
                          deviceData: deviceData,
                          imei: widget.device.imei,
                          deviceColor: widget.device.color,
                          showFence: showFence,
                          isInterval: widget.isInterval,
                          endDate: endDate,
                          startDate: startDate,
                          showRoute: showRoute,
                          onZoomChange: (newZoom) {
                            // No need to setstate because we dont need to update the screen
                            // just need to store the value in case the map restarts to keep zoom
                            currentZoom = newZoom;
                          },
                          startingZoom: currentZoom,
                          showHeatMap: showHeatMap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // if (deviceData.isNotEmpty)
              //   DeviceDataInfoList(
              //     mapKey: firstItemDataKey,
              //     deviceData: widget.isInterval ? deviceData : [deviceData.first],
              //   )
            ],
          );
  }
}
