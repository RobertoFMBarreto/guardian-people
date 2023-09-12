import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/device_data_operations.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
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

  List<DeviceLocationsCompanion> _deviceData = [];

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  bool _showFence = true;
  bool _showRoute = false;
  double _currentZoom = 17;
  bool _showHeatMap = false;
  List<String> dropdownItems = [
    'normal',
    'heatmap',
  ];
  late String _dropDownValue;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  Future<void> _setup() async {
    setState(() {
      _dropDownValue = dropdownItems.first;

      _deviceData = widget.device.data;
    });
    await _getDeviceData();
  }

  Future<void> _getDeviceData() async {
    await getDeviceData(
      startDate: _startDate,
      endDate: _endDate,
      deviceId: widget.device.device.deviceId.value,
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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    _showHeatMap = !widget.isInterval ? false : _showHeatMap;
    AppLocalizations localizations = AppLocalizations.of(context)!;
    print(_deviceData);
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
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: DeviceTimeRangeWidget(
                        startDate: _startDate,
                        endDate: _endDate,
                        onStartDateChanged: (newStartDate) {
                          setState(() {
                            _startDate = newStartDate;
                            _getDeviceData();
                          });
                        },
                        onEndDateChanged: (newEndDate) {
                          setState(() {
                            _endDate = newEndDate;
                            _getDeviceData();
                          });
                        }),
                  ),
                Expanded(
                  key: _firstItemDataKey,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SingleDeviceLocationMap(
                            key: Key(
                                '${_showFence}_${_showHeatMap}_${widget.device.device.color.value}${widget.isInterval}'),
                            showCurrentPosition: true,
                            deviceData: _deviceData,
                            imei: widget.device.device.imei.value,
                            deviceColor: widget.device.device.color.value,
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
                                        child: Text(
                                          localizations.normal_map.capitalize(),
                                          style: theme.textTheme.bodyLarge!.copyWith(
                                              color: gdOnMapColor, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          localizations.heatmap.capitalize(),
                                          style: theme.textTheme.bodyLarge!.copyWith(
                                              color: gdOnMapColor, fontWeight: FontWeight.w500),
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
                                    print(value);
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
                                          inactiveTrackColor:
                                              Theme.of(context).brightness == Brightness.light
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
                              if (widget.isInterval)
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
                                          inactiveTrackColor:
                                              Theme.of(context).brightness == Brightness.light
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
                            color: gdOnMapColor,
                            icon: const Icon(Icons.tune),
                            iconSize: 30,
                          ),
                        ),
                      ],
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
