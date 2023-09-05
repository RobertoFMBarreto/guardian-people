import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/data_models/Device/device_data.dart';
import 'package:guardian/models/db/operations/device_data_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/inputs/range_date_time_input.dart';
import 'package:guardian/widgets/ui/device/device_time_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/maps/single_device_location_map.dart';

class DeviceMapWidget extends StatefulWidget {
  final Device device;
  final bool isInterval;
  const DeviceMapWidget({super.key, required this.device, required this.isInterval});

  @override
  State<DeviceMapWidget> createState() => _DeviceMapWidgetState();
}

class _DeviceMapWidgetState extends State<DeviceMapWidget> {
  final _firstItemDataKey = GlobalKey();
  late Future _future;

  List<DeviceData> _deviceData = [];

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  bool _showFence = true;
  bool _showRoute = false;
  double _currentZoom = 17;
  bool _showHeatMap = false;
  int _dropDownValue = 0;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  Future<void> _setup() async {
    await _getDeviceData();
  }

  Future<void> _getDeviceData() async {
    await getDeviceData(
      startDate: _startDate,
      endDate: _endDate,
      deviceId: widget.device.deviceId,
      isInterval: widget.isInterval,
    ).then(
      (data) async {
        _deviceData = [];
        if (mounted) {
          setState(() {
            _deviceData.addAll(data);
          });
        }
      },
    );
  }

  void _showDateSelector() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RangeDateTimeInput(
                startDate: _startDate,
                endDate: _endDate,
                onConfirm: (newStartDate, newEndDate) {
                  setState(() {
                    _startDate = newStartDate;
                    _endDate = newEndDate;
                  });
                  _getDeviceData();
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    _dropDownValue = !widget.isInterval ? 0 : _dropDownValue;
    _showHeatMap = !widget.isInterval ? false : _showHeatMap;
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomCircularProgressIndicator();
        } else {
          return Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.isInterval)
                  GestureDetector(
                    onTap: () {
                      _showDateSelector();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DeviceTimeRangeWidget(
                            startDate: _startDate,
                            endDate: _endDate,
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
                        inactiveTrackColor: Theme.of(context).brightness == Brightness.light
                            ? gdToggleGreyArea
                            : gdDarkToggleGreyArea,
                        value: _showRoute,
                        onChanged: (value) {
                          setState(() {
                            _showRoute = value;
                          });
                        },
                      ),
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
                          value: _dropDownValue,
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
                                _showHeatMap = value == 1;
                                _dropDownValue = value;
                                _showFence = false;
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
                            inactiveTrackColor: Theme.of(context).brightness == Brightness.light
                                ? gdToggleGreyArea
                                : gdDarkToggleGreyArea,
                            value: _showFence,
                            onChanged: (value) {
                              setState(() {
                                _showFence = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  key: _firstItemDataKey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SingleDeviceLocationMap(
                      key: Key(
                          '${_showFence}_${_showHeatMap}_${widget.device.color}${widget.isInterval}'),
                      showCurrentPosition: true,
                      deviceData: _deviceData,
                      imei: widget.device.imei,
                      deviceColor: widget.device.color,
                      showFence: _showFence,
                      isInterval: widget.isInterval,
                      endDate: _endDate,
                      startDate: _startDate,
                      showRoute: _showRoute,
                      onZoomChange: (newZoom) {
                        // No need to setstate because we dont need to update the screen
                        // just need to store the value in case the map restarts to keep zoom
                        _currentZoom = newZoom;
                      },
                      startingZoom: _currentZoom,
                      showHeatMap: _showHeatMap,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
