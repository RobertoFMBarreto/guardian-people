import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/device_data_operations.dart';
import 'package:guardian/models/db/drift/operations/device_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/pages/producer/web/widget/device_settings.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/device/device_item.dart';
import 'package:guardian/widgets/ui/device/device_time_widget.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';
import 'package:guardian/widgets/ui/maps/single_device_location_map.dart';

class WebProducerDevicePage extends StatefulWidget {
  final Animal? selectedAnimal;
  const WebProducerDevicePage({super.key, this.selectedAnimal});

  @override
  State<WebProducerDevicePage> createState() => _WebProducerDevicePageState();
}

class _WebProducerDevicePageState extends State<WebProducerDevicePage> {
  final List<FenceData> _fences = [];

  late Future _future;

  Animal? _selectedAnimal;

  List<Animal> _animals = [];

  bool _isInterval = false;
  bool _showSettings = false;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  double _currentZoom = 17;
  String _searchString = '';
  final RangeValues _batteryRangeValues = const RangeValues(0, 100);
  final RangeValues _dtUsageRangeValues = const RangeValues(0, 10);
  final RangeValues _elevationRangeValues = const RangeValues(0, 1000);
  final RangeValues _tmpRangeValues = const RangeValues(0, 25);

  @override
  void initState() {
    _future = _setup();

    super.initState();
  }

  Future<void> _setup() async {
    setState(() {
      _selectedAnimal = widget.selectedAnimal;
    });
    await _loadDevices();
  }

  Future<void> _loadDevices() async {
    getUserAnimalsWithData().then((allDevices) {
      setState(() {
        _animals.addAll(allDevices);
      });

      _getDevicesFromApi();
    });
  }

  Future<void> _getDevicesFromApi() async {
    AnimalProvider.getAnimals().then((response) async {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> states = ['Ruminar', 'Comer', 'Andar', 'Correr', 'Parada'];
        for (var dt in data) {
          await createDevice(DeviceCompanion(
            deviceName: drift.Value(dt['device_name']),
            idDevice: drift.Value(BigInt.from(int.parse(dt['id_device']))),
            isActive: drift.Value(dt['is_active'] == true),
          ));
          await createAnimal(AnimalCompanion(
            idDevice: drift.Value(BigInt.from(int.parse(dt['id_device']))),
            isActive: drift.Value(dt['animal_is_active'] == true),
            animalName: drift.Value(dt['animal_name']),
            idUser: drift.Value(BigInt.from(int.parse(dt['id_user']))),
            animalColor: drift.Value(dt['animal_color']),
            animalIdentification: drift.Value(dt['animal_identification']),
            idAnimal: drift.Value(BigInt.from(int.parse(dt['id_animal']))),
          ));
          if (dt['last_device_data'] != null) {
            await createDeviceData(
              DeviceLocationsCompanion(
                accuracy: dt['last_device_data']['accuracy'] != null
                    ? drift.Value(double.tryParse(dt['last_device_data']['accuracy']))
                    : const drift.Value.absent(),
                battery: dt['last_device_data']['battery'] != null
                    ? drift.Value(int.tryParse(dt['last_device_data']['battery']))
                    : const drift.Value.absent(),
                dataUsage: drift.Value(Random().nextInt(10)),
                date: drift.Value(DateTime.parse(dt['last_device_data']['date'])),
                deviceDataId:
                    drift.Value(BigInt.from(int.parse(dt['last_device_data']['id_data']))),
                idDevice: drift.Value(BigInt.from(int.parse(dt['id_device']))),
                elevation: dt['last_device_data']['altitude'] != null
                    ? drift.Value(double.tryParse(dt['last_device_data']['altitude']))
                    : const drift.Value.absent(),
                lat: dt['last_device_data']['lat'] != null
                    ? drift.Value(double.tryParse(dt['last_device_data']['lat']))
                    : const drift.Value.absent(),
                lon: dt['last_device_data']['lon'] != null
                    ? drift.Value(double.tryParse(dt['last_device_data']['lon']))
                    : const drift.Value.absent(),
                state: drift.Value(states[Random().nextInt(states.length)]),
                temperature: dt['last_device_data']['skinTemperature'] != null
                    ? drift.Value(double.tryParse(dt['last_device_data']['skinTemperature']))
                    : const drift.Value.absent(),
              ),
            );
          }
        }
        getUserAnimalsWithData().then((allDevices) {
          if (mounted) {
            setState(() {
              _animals = [];
              _animals.addAll(allDevices);
            });
          }
        });
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          final newToken = jsonDecode(resp.body)['token'];
          await setSessionToken(newToken);
          _getDevicesFromApi();
        });
      }
    });
  }

  Future<void> filterAnimals() async {
    await getUserAnimalsFiltered(
      batteryRangeValues: _batteryRangeValues,
      elevationRangeValues: _elevationRangeValues,
      dtUsageRangeValues: _dtUsageRangeValues,
      searchString: _searchString,
      tmpRangeValues: _tmpRangeValues,
    ).then(
      (filteredAnimals) => setState(() {
        _animals = [];
        _animals.addAll(filteredAnimals);
      }),
    );
  }

  Future<void> _getDeviceData() async {
    await getAnimalData(
      startDate: _startDate,
      endDate: _endDate,
      idAnimal: _selectedAnimal!.animal.idAnimal.value,
      isInterval: _isInterval,
    ).then(
      (data) async {
        setState(() {
          _selectedAnimal = Animal(
            animal: _selectedAnimal!.animal,
            data: data,
          );
        });
        AnimalProvider.getAnimalData(_selectedAnimal!.animal.idAnimal.value, _startDate, _endDate)
            .then((response) async {
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            List<String> states = ['Ruminar', 'Comer', 'Andar', 'Correr', 'Parada'];
            for (var dt in data) {
              await createDeviceData(
                DeviceLocationsCompanion(
                  accuracy: dt['accuracy'] != null
                      ? drift.Value(double.tryParse(dt['accuracy']))
                      : const drift.Value.absent(),
                  battery: dt['battery'] != null
                      ? drift.Value(int.tryParse(dt['battery']))
                      : const drift.Value.absent(),
                  dataUsage: drift.Value(Random().nextInt(10)),
                  date: drift.Value(DateTime.parse(dt['date'])),
                  deviceDataId: drift.Value(BigInt.from(int.parse(dt['id_data']))),
                  idDevice: drift.Value(BigInt.from(int.parse(dt['id_device']))),
                  elevation: dt['altitude'] != null
                      ? drift.Value(double.tryParse(dt['altitude']))
                      : const drift.Value.absent(),
                  lat: dt['lat'] != null
                      ? drift.Value(double.tryParse(dt['lat']))
                      : const drift.Value.absent(),
                  lon: dt['lon'] != null
                      ? drift.Value(double.tryParse(dt['lon']))
                      : const drift.Value.absent(),
                  state: drift.Value(states[Random().nextInt(states.length)]),
                  temperature: dt['skinTemperature'] != null
                      ? drift.Value(double.tryParse(dt['skinTemperature']))
                      : const drift.Value.absent(),
                ),
              );
            }

            await getAnimalData(
              startDate: _startDate,
              endDate: _endDate,
              idAnimal: _selectedAnimal!.animal.idAnimal.value,
              isInterval: _isInterval,
            ).then(
              (data) async {
                setState(() {
                  _selectedAnimal = Animal(
                    animal: _selectedAnimal!.animal,
                    data: data,
                  );
                });
                if (_selectedAnimal!.data.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.there_is_no_animal_data.capitalize(),
                    ),
                  ));
                }
              },
            );
          } else if (response.statusCode == 401) {
            AuthProvider.refreshToken().then((resp) async {
              final newToken = jsonDecode(resp.body)['token'];
              await setSessionToken(newToken);
              _getDevicesFromApi();
            });
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomCircularProgressIndicator();
          } else {
            return Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: _selectedAnimal != null
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Text(
                                            localizations.devices.capitalize(),
                                            style: theme.textTheme.headlineMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedAnimal != null)
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _showSettings = !_showSettings;
                                              });
                                            },
                                            icon: Icon(Icons.settings),
                                            label: Text(
                                              localizations.device_settings.capitalize(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                ],
                              ),
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SearchWithFilterInput(
                                              onFilter: () {},
                                              onSearchChanged: (value) {
                                                _searchString = value;
                                                filterAnimals();
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: _animals.length,
                                                itemBuilder: (context, index) {
                                                  return DeviceItem(
                                                    animal: _animals[index],
                                                    isSelected: _selectedAnimal != null &&
                                                        _animals[index].animal.idAnimal.value ==
                                                            _selectedAnimal!.animal.idAnimal.value,
                                                    onTap: () {
                                                      if (_selectedAnimal != null &&
                                                          _selectedAnimal!.animal.idAnimal.value ==
                                                              _animals[index]
                                                                  .animal
                                                                  .idAnimal
                                                                  .value) {
                                                        setState(() {
                                                          _selectedAnimal = null;
                                                          _showSettings = false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          _selectedAnimal = _animals[index];
                                                        });
                                                        if (_startDate
                                                                .difference(_endDate)
                                                                .inSeconds
                                                                .abs() >
                                                            60) {
                                                          _getDeviceData();
                                                        }
                                                      }

                                                      if (_selectedAnimal != null &&
                                                          _selectedAnimal!.data.isEmpty) {
                                                        ScaffoldMessenger.of(context)
                                                            .showSnackBar(SnackBar(
                                                          content: Text(
                                                            localizations.there_is_no_animal_data
                                                                .capitalize(),
                                                          ),
                                                        ));
                                                      }
                                                    },
                                                  );
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        if (_selectedAnimal != null)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: DeviceTimeRangeWidget(
                                  startDate: _startDate,
                                  endDate: _endDate,
                                  onStartDateChanged: (newStartDate) {
                                    if (_selectedAnimal != null) {
                                      setState(() {
                                        _startDate = newStartDate;
                                        _isInterval = true;
                                        _getDeviceData();
                                      });
                                    }
                                  },
                                  onEndDateChanged: (newEndDate) {
                                    if (_selectedAnimal != null) {
                                      setState(() {
                                        _endDate = newEndDate;
                                        _isInterval = true;
                                        _getDeviceData();
                                      });
                                    }
                                  }),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_selectedAnimal != null && _showSettings)
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 20, right: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      localizations.device_settings.capitalize(),
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _showSettings = false;
                                        });
                                      },
                                      icon: Icon(Icons.close),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: DeviceSettings(
                            animal: _selectedAnimal!,
                          ),
                        ),
                      ],
                    ),
                  )),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _selectedAnimal != null
                          ? SingleDeviceLocationMap(
                              showCurrentPosition: true,
                              deviceData: _selectedAnimal!.data
                                  .where((element) => element.lat.value != null)
                                  .toList(),
                              onZoomChange: (newZoom) {
                                // No need to setstate because we dont need to update the screen
                                // just need to store the value in case the map restarts to keep zoom
                                _currentZoom = newZoom;
                              },
                              startingZoom: _currentZoom,
                              startDate: _startDate,
                              endDate: _endDate,
                              isInterval: _isInterval,
                              idAnimal: _selectedAnimal!.animal.idAnimal.value,
                              deviceColor: _selectedAnimal!.animal.animalColor.value,
                            )
                          : DevicesLocationsMap(
                              showCurrentPosition: true,
                              animals: _animals,
                              fences: _fences,
                            ),
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }
}
