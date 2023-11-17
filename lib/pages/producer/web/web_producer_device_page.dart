import 'package:dart_amqp/dart_amqp.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:guardian/models/providers/api/parsers/animals_parsers.dart';
import 'package:guardian/models/providers/api/rabbit_mq_provider.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/pages/producer/web/widget/device_settings.dart';
import 'package:guardian/settings/colors.dart';
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
  DateTime? _endDate;
  double _currentZoom = 17;
  String _searchString = '';
  RabbitMQProvider rabbitMQProvider = RabbitMQProvider();
  late Consumer consumer;
  RangeValues _batteryRangeValues = const RangeValues(0, 100);
  RangeValues _dtUsageRangeValues = const RangeValues(0, 10);
  RangeValues _elevationRangeValues = const RangeValues(0, 1000);
  RangeValues _tmpRangeValues = const RangeValues(0, 25);

  @override
  void dispose() {
    AnimalRequests.stopRealtimeStreaming(
      idAnimal: _selectedAnimal!.animal.idAnimal.value,
      context: context,
      onDataGotten: () {
        rabbitMQProvider.stop();
      },
      onFailed: () {
        AppLocalizations localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(localizations.server_error)));
      },
    );

    super.dispose();
  }

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
    await _loadAnimalData();
    await _loadAnimals();
    await _setupFilterRanges();
  }

  /// Method that does the setup of filters based on de database values
  Future<void> _setupFilterRanges() async {
    _batteryRangeValues = const RangeValues(0, 100);
    _dtUsageRangeValues = const RangeValues(0, 10);

    final maxElevation = await getMaxElevation();
    final maxTemperature = await getMaxTemperature();
    if (mounted) {
      setState(() {
        _elevationRangeValues = RangeValues(0, maxElevation);
        _tmpRangeValues = RangeValues(0, maxTemperature);
      });
    }
  }

  /// Method that loads the animals into the [_animals] list
  ///
  /// 1. load local animals
  /// 2. add to list
  /// 3. load api animals
  Future<void> _loadAnimals() async {
    await getUserAnimalsWithLastLocation().then((allAnimals) {
      _animals = [];
      setState(() {
        _animals.addAll(allAnimals);
      });
      AnimalRequests.getAnimalsFromApiWithLastLocation(
          context: context,
          onFailed: () {
            AppLocalizations localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(localizations.server_error)));
          },
          onDataGotten: () {
            getUserAnimalsWithLastLocation().then((allDevices) {
              if (mounted) {
                setState(() {
                  _animals = [];
                  _animals.addAll(allDevices);
                });
              }
            });
          });
    });
  }

  /// Method that loads that local animal data into the [_animalData] list
  Future<void> _getAnimalData() async {
    getAnimalData(
      startDate: _startDate,
      endDate: _endDate,
      idAnimal: _selectedAnimal!.animal.idAnimal.value,
      isInterval: _isInterval,
    ).then(
      (data) async {
        List<AnimalLocationsCompanion> animalData = [];
        if (mounted) {
          setState(() {
            animalData.addAll(data);
            _selectedAnimal = Animal(
              animal: _selectedAnimal!.animal,
              data: animalData,
            );
          });
        }
      },
    );
  }

  Future<void> _loadAnimalData() async {
    if (_isInterval) {
      // get data in interval
      _getAnimalData();
      AnimalRequests.getAnimalDataIntervalFromApi(
        idAnimal: _selectedAnimal!.animal.idAnimal.value,
        startDate: _startDate,
        endDate: _endDate ?? DateTime.now(),
        context: context,
        onDataGotten: () {
          _getAnimalData();
        },
        onFailed: () {
          hasShownNoServerConnection().then((hasShown) async {
            if (mounted) {
              setState(() {
                _startDate = DateTime.now();
                _endDate = DateTime.now();
              });
            }
            if (!hasShown) {
              setShownNoServerConnection(true).then(
                (_) =>
                    showDialog(context: context, builder: (context) => const ServerErrorDialogue()),
              );
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.server_error.capitalizeFirst!,
                    ),
                  ),
                );
              }
            }
          });
        },
      );
    } else {
      // get last location
      if (_selectedAnimal!.data.isEmpty) {
        _getLastLocation().then((_) {
          if (mounted) {
            setState(() {
              _startDate = _selectedAnimal!.data
                      .firstWhereOrNull((element) => element.lat.value != null)
                      ?.date
                      .value ??
                  DateTime.now();
            });
          }
        });

        AnimalRequests.getAnimalsFromApiWithLastLocation(
            context: context,
            onFailed: () {
              AppLocalizations localizations = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(localizations.server_error)));
            },
            onDataGotten: () {
              _getLastLocation();
            });
      }
    }
    if (_endDate == null) {
      // make realtime request
      if (kDebugMode) {
        print('Start Realtime for ${_selectedAnimal!.animal.idAnimal.value}');
      }
      AnimalRequests.startRealtimeStreaming(
        idAnimal: _selectedAnimal!.animal.idAnimal.value,
        context: context,
        onDataGotten: () {
          rabbitMQProvider.listen(
            topicId: _selectedAnimal!.animal.idAnimal.value,
            onDataReceived: (message) async {
              if (message['lat'] != null && message['lon'] != null) {
                animalDataFromJson(message, _selectedAnimal!.animal.idAnimal.value).then(
                  (_) => _getAnimalData(),
                );
              }
            },
          );
        },
        onFailed: () {
          AppLocalizations localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(localizations.server_error)));
        },
      );
    }
  }

  /// Method that filters the animals and loads them into the [_animals] list
  Future<void> filterAnimals() async {
    await getUserAnimalsFiltered(
      batteryRangeValues: _batteryRangeValues,
      elevationRangeValues: _elevationRangeValues,
      dtUsageRangeValues: _dtUsageRangeValues,
      searchString: _searchString,
      tmpRangeValues: _tmpRangeValues,
    ).then((filteredAnimals) {
      if (mounted) {
        setState(() {
          _animals = [];
          _animals.addAll(filteredAnimals);
        });
      }
    });
  }

  /// Method that allows to get the animal with the last location from api and store it in [_animalData] variable
  Future<void> _getLastLocation() async {
    await getUserAnimalWithLastLocation(_selectedAnimal!.animal.idAnimal.value).then((animal) {
      if (mounted) {
        setState(() {
          _selectedAnimal = Animal(
            animal: animal.first.animal,
            data: animal.first.data,
          );
        });
      }
    });
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
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                              localizations.devices.capitalizeFirst!,
                                              style: theme.textTheme.headlineMedium,
                                            ),
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
                                              localizations.device_settings.capitalizeFirst!,
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
                                                    deviceStatus: _animals[index].deviceStatus!,
                                                    isSelected: _selectedAnimal != null &&
                                                        _animals[index].animal.idAnimal.value ==
                                                            _selectedAnimal!.animal.idAnimal.value,
                                                    onTap: () async {
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
                                                        if (_endDate == null ||
                                                            _startDate
                                                                    .difference(_endDate!)
                                                                    .inSeconds
                                                                    .abs() >
                                                                60) {
                                                          await _loadAnimalData();
                                                        }
                                                      }

                                                      if (_selectedAnimal != null &&
                                                          _selectedAnimal!.data.isEmpty) {
                                                        // ignore: use_build_context_synchronously
                                                        ScaffoldMessenger.of(context)
                                                            .showSnackBar(SnackBar(
                                                          content: Text(
                                                            localizations.there_is_no_animal_data
                                                                .capitalizeFirst!,
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
                        if (_selectedAnimal != null) ...[
                          if (_endDate != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    if (mounted) {
                                      setState(() {
                                        _endDate = null;
                                        _isInterval = false;
                                        _loadAnimalData();
                                      });
                                    }
                                  },
                                  child: Text(
                                    localizations.realtime.capitalize!,
                                    style: theme.textTheme.bodyLarge!
                                        .copyWith(color: gdSecondaryColor),
                                  ),
                                )
                              ],
                            ),
                          Expanded(
                            child: AnimalTimeRangeWidget(
                                startDate: _startDate,
                                endDate: _endDate,
                                onStartDateChanged: (newStartDate) {
                                  if (_selectedAnimal != null) {
                                    setState(() {
                                      _startDate = newStartDate;
                                      _isInterval = true;
                                      _loadAnimalData();
                                    });
                                  }
                                },
                                onEndDateChanged: (newEndDate) {
                                  if (_selectedAnimal != null) {
                                    setState(() {
                                      _endDate = newEndDate;
                                      _isInterval = true;
                                      _loadAnimalData();
                                    });
                                  }
                                }),
                          ),
                        ]
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
                                      localizations.device_settings.capitalizeFirst!,
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
                            key: Key(_selectedAnimal!.animal.idAnimal.value),
                            animal: _selectedAnimal!,
                            onColorChanged: (color) {
                              setState(() {
                                _selectedAnimal = Animal(
                                  animal: _selectedAnimal!.animal.copyWith(
                                    animalColor: drift.Value(color),
                                  ),
                                  data: _selectedAnimal!.data,
                                );
                              });
                              _loadAnimals();
                            },
                            onNameChanged: (name) {
                              setState(() {
                                _selectedAnimal = Animal(
                                  animal: _selectedAnimal!.animal.copyWith(
                                    animalName: drift.Value(name),
                                  ),
                                  data: _selectedAnimal!.data,
                                );
                              });
                              _loadAnimals();
                            },
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
                              endDate: _endDate ?? DateTime.now(),
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
