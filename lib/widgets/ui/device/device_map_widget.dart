import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/translator/animals_translator.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/models/providers/tmp/devices_data.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/device/device_time_widget.dart';
import 'package:guardian/widgets/ui/maps/single_device_location_map.dart';

class DeviceMapWidget extends StatefulWidget {
  final Animal animal;
  final bool isInterval;
  const DeviceMapWidget({super.key, required this.animal, required this.isInterval});

  @override
  State<DeviceMapWidget> createState() => _DeviceMapWidgetState();
}

class _DeviceMapWidgetState extends State<DeviceMapWidget> {
  final _firstItemDataKey = GlobalKey();
  late Future _future;

  List<AnimalLocationsCompanion> _deviceData = [];

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
      _deviceData = widget.animal.data;
    });
    await _getDeviceData();
    await _getDeviceDataFromApi();
  }

  Future<void> _getDeviceData() async {
    await getAnimalData(
      startDate: _startDate,
      endDate: _endDate,
      idAnimal: widget.animal.animal.idAnimal.value,
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

  Future<void> _getDeviceDataFromApi() async {
    AnimalProvider.getAnimalData(widget.animal.animal.idAnimal.value, _startDate, _endDate)
        .then((response) async {
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        for (var dt in body['data']) {
          await animalDataFromJson(dt, widget.animal.animal.idAnimal.value.toString());
        }
        _getDeviceData();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          final newToken = jsonDecode(resp.body)['token'];
          await setSessionToken(newToken);
          _getDeviceDataFromApi();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _showHeatMap = !widget.isInterval ? false : _showHeatMap;
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: DeviceTimeRangeWidget(
                          startDate: _startDate,
                          endDate: _endDate,
                          onStartDateChanged: (newStartDate) {
                            setState(() {
                              _startDate = newStartDate;
                              _getDeviceDataFromApi();
                            });
                          },
                          onEndDateChanged: (newEndDate) {
                            setState(() {
                              _endDate = newEndDate;
                              _getDeviceDataFromApi();
                            });
                          }),
                    ),
                  ),
                Expanded(
                  key: _firstItemDataKey,
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SingleDeviceLocationMap(
                        key: Key(_deviceData.toString()),
                        showCurrentPosition: true,
                        deviceData: _deviceData,
                        idAnimal: widget.animal.animal.idAnimal.value,
                        deviceColor: widget.animal.animal.animalColor.value,
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
