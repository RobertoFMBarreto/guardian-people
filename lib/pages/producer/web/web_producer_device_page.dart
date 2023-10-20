import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/pages/producer/web/widget/device_settings.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/animal/animal_item.dart';
import 'package:guardian/widgets/ui/animal/animal_time_widget.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';
import 'package:guardian/widgets/ui/maps/single_device_location_map.dart';

/// Class that represents the web producer device page
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

  /// Method that does the initial setup for the page
  Future<void> _setup() async {
    setState(() {
      _selectedAnimal = widget.selectedAnimal;
    });
    await _loadDevices();
  }

  /// Method that loads the local devices into the [_animals] list
  ///
  /// After that loads the devices from the api
  Future<void> _loadDevices() async {
    getUserAnimalsWithData().then((allDevices) {
      setState(() {
        _animals.addAll(allDevices);
      });

      _getDevicesFromApi();
    });
  }

  /// Method that loads all devices from the API and then loads from database into the [_animals] list
  ///
  /// In case the session token expires then it calls the api to refresh the token and doest the initial request again
  ///
  /// If the server takes too long to answer then the user receives and alert
  Future<void> _getDevicesFromApi() async {
    AnimalProvider.getAnimals().then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        final data = jsonDecode(response.body);
        List<String> states = ['Ruminar', 'Comer', 'Andar', 'Correr', 'Parada'];
        for (var dt in data) {
          await createAnimal(AnimalCompanion(
            isActive: drift.Value(dt['animal_is_active'] == true),
            animalName: drift.Value(dt['animal_name']),
            idUser: drift.Value(dt['id_user']),
            animalColor: drift.Value(dt['animal_color']),
            animalIdentification: drift.Value(dt['animal_identification']),
            idAnimal: drift.Value(dt['id_animal']),
          ));
          if (dt['last_device_data'] != null) {
            await createAnimalData(
              AnimalLocationsCompanion(
                accuracy: dt['last_device_data']['accuracy'] != null
                    ? drift.Value(double.tryParse(dt['last_device_data']['accuracy']))
                    : const drift.Value.absent(),
                battery: dt['last_device_data']['battery'] != null
                    ? drift.Value(int.tryParse(dt['last_device_data']['battery']))
                    : const drift.Value.absent(),
                dataUsage: drift.Value(Random().nextInt(10)),
                date: drift.Value(DateTime.parse(dt['last_device_data']['date'])),
                animalDataId: drift.Value(dt['last_device_data']['id_data']),
                idAnimal: drift.Value(dt['id_animal']),
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
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken);
            _getDevicesFromApi();
          } else if (response.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
            });
          } else {
            clearUserSession().then((_) => deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        hasShownNoServerConnection().then((hasShown) async {
          if (!hasShown) {
            setShownNoServerConnection(true).then(
              (_) =>
                  showDialog(context: context, builder: (context) => const ServerErrorDialogue()),
            );
          }
        });
      }
    });
  }

  /// Method that filters the animals and loads them into the [_animals] list
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

  /// Method that loads device data from the api and then loads from database into the [_animals] list
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
            setShownNoServerConnection(false);
            final data = jsonDecode(response.body);
            List<String> states = ['Ruminar', 'Comer', 'Andar', 'Correr', 'Parada'];
            for (var dt in data) {
              await createAnimalData(
                AnimalLocationsCompanion(
                  accuracy: dt['accuracy'] != null
                      ? drift.Value(double.tryParse(dt['accuracy']))
                      : const drift.Value.absent(),
                  battery: dt['battery'] != null
                      ? drift.Value(int.tryParse(dt['battery']))
                      : const drift.Value.absent(),
                  dataUsage: drift.Value(Random().nextInt(10)),
                  date: drift.Value(DateTime.parse(dt['date'])),
                  animalDataId: drift.Value(dt['id_data']),
                  idAnimal: drift.Value(dt['id_animal']),
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
                if (_selectedAnimal!.data.isEmpty && mounted) {
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
              if (resp.statusCode == 200) {
                setShownNoServerConnection(false);
                final newToken = jsonDecode(resp.body)['token'];
                await setSessionToken(newToken);
                _getDevicesFromApi();
              } else if (response.statusCode == 507) {
                hasShownNoServerConnection().then((hasShown) async {
                  if (!hasShown) {
                    setShownNoServerConnection(true).then(
                      (_) => showDialog(
                          context: context, builder: (context) => const ServerErrorDialogue()),
                    );
                  }
                });
              } else {
                clearUserSession().then((_) => deleteEverything().then(
                      (_) => Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (Route<dynamic> route) => false),
                    ));
              }
            });
          } else if (response.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
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
                                            icon: const Icon(Icons.settings),
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
                                                  return AnimalItem(
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
                              child: AnimalTimeRangeWidget(
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
                                      icon: const Icon(Icons.close),
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
                          ? SingleAnimalLocationMap(
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
                          : AnimalsLocationsMap(
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
