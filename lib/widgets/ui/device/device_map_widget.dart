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

  bool _showHeatMap = false;

  double _currentZoom = 17;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  Future<void> _setup() async {
    setState(() {
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
    _showHeatMap = !widget.isInterval ? false : _showHeatMap;
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SingleDeviceLocationMap(
                        showCurrentPosition: true,
                        deviceData: _deviceData,
                        imei: widget.device.device.imei.value,
                        deviceColor: widget.device.device.color.value,
                        isInterval: widget.isInterval,
                        endDate: _endDate,
                        startDate: _startDate,
                        onZoomChange: (newZoom) {
                          // No need to setstate because we dont need to update the screen
                          // just need to store the value in case the map restarts to keep zoom
                          _currentZoom = newZoom;
                        },
                        startingZoom: _currentZoom,
                      ),
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
