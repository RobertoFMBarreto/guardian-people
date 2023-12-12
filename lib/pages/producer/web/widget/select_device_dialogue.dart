import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/widgets/inputs/search_field_input.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/animal/animal_item_selectable.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents the select device dialogue
class SelectDeviceDialogue extends StatefulWidget {
  final String? idFence;
  final String? idAlert;
  final List<String>? notToShowAnimals;

  const SelectDeviceDialogue({
    super.key,
    this.idFence,
    this.idAlert,
    this.notToShowAnimals,
  });

  @override
  State<SelectDeviceDialogue> createState() => _SelectDeviceDialogueState();
}

class _SelectDeviceDialogueState extends State<SelectDeviceDialogue> {
  late double _maxElevation;
  late double _maxTemperature;
  late Future<void> _future;

  String _searchString = '';
  RangeValues _batteryRangeValues = const RangeValues(0, 100);
  RangeValues _dtUsageRangeValues = const RangeValues(0, 10);
  RangeValues _elevationRangeValues = const RangeValues(0, 1000);
  RangeValues _tmpRangeValues = const RangeValues(0, 25);

  List<Animal> _selectedAnimals = [];
  List<Animal> _animals = [];
  bool _firstRun = true;

  @override
  void initState() {
    _future = _setup();

    super.initState();
  }

  /// Method that does the initial setup for the page
  ///
  /// 1. setup all filters
  /// 2. filter the animals to load all local animals
  /// 3. get the animals from the api
  Future<void> _setup() async {
    isSnackbarActive = false;
    await _setupFilterRanges();
    await _filterAnimals();
    await _getAnimalsFromApi();
  }

  /// Method that does the setup of filters based on de database values
  Future<void> _setupFilterRanges() async {
    _batteryRangeValues = const RangeValues(0, 100);
    _dtUsageRangeValues = const RangeValues(0, 10);

    _maxElevation = await getMaxElevation();
    _maxTemperature = await getMaxTemperature();
    if (mounted) {
      setState(() {
        _elevationRangeValues = RangeValues(0, _maxElevation);
        _tmpRangeValues = RangeValues(0, _maxTemperature);
      });
    }
  }

  /// Method that loads all devices from the API into the [_animals] list
  ///
  /// In case the session token expires then it calls the api to refresh the token and doest the initial request again
  ///
  /// If the server takes too long to answer then the user receives and alert
  Future<void> _getAnimalsFromApi() async {
    AnimalRequests.getAnimalsFromApiWithLastLocation(
        context: context,
        onFailed: (statusCode) {
          if (!hasConnection && !isSnackbarActive) {
            showNoConnectionSnackBar();
          } else {
            if (statusCode == 507 || statusCode == 404) {
              if (_firstRun == true) {
                showNoConnectionSnackBar();
              }
              _firstRun = false;
            } else if (!isSnackbarActive) {
              AppLocalizations localizations = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(localizations.server_error)));
            }
          }
        },
        onDataGotten: () {
          _filterAnimals();
        });
  }

  /// Method that filters all animals loading them into the [_animals] list
  ///
  /// If in select mode it only loads the animals that aren't selected for the fence or the alert
  ///
  /// If not in select mode it loads all the animals
  ///
  /// Resets the [_animals] list to prevent duplicates
  Future<void> _filterAnimals() async {
    if (widget.idFence != null) {
      await getUserFenceUnselectedAnimalsFiltered(
        batteryRangeValues: _batteryRangeValues,
        elevationRangeValues: _elevationRangeValues,
        searchString: _searchString,
        tmpRangeValues: _tmpRangeValues,
        idFence: widget.idFence!,
      ).then((searchDevices) {
        if (mounted) {
          setState(() {
            _animals = [];
            _animals.addAll(searchDevices);
          });
        }
      });
    } else if (widget.idAlert != null) {
      await getUserAlertUnselectedAnimalsFiltered(
        batteryRangeValues: _batteryRangeValues,
        elevationRangeValues: _elevationRangeValues,
        dtUsageRangeValues: _dtUsageRangeValues,
        searchString: _searchString,
        tmpRangeValues: _tmpRangeValues,
        idAlert: widget.idAlert!,
      ).then((searchDevices) {
        if (mounted) {
          setState(() {
            _animals = [];
            _animals.addAll(searchDevices);
          });
        }
      });
    } else {
      getUserAnimalsFiltered(
        batteryRangeValues: _batteryRangeValues,
        elevationRangeValues: _elevationRangeValues,
        dtUsageRangeValues: _dtUsageRangeValues,
        searchString: _searchString,
        tmpRangeValues: _tmpRangeValues,
      ).then(
        (filteredDevices) => setState(() {
          _animals = [];
          if (widget.notToShowAnimals != null) {
            _animals.addAll(
              filteredDevices.where(
                (device) => !widget.notToShowAnimals!.contains(
                  device.animal.idAnimal.value,
                ),
              ),
            );
          } else {
            _animals.addAll(filteredDevices);
          }
        }),
      );
    }
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
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: SearchFieldInput(
                    label: localizations.search.capitalize!,
                    onChanged: (value) {
                      _searchString = value;
                      _filterAnimals();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (_selectedAnimals.length == _animals.length) {
                            setState(() {
                              _selectedAnimals = [];
                            });
                          } else {
                            setState(() {
                              _selectedAnimals = _animals;
                            });
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedAnimals.length == _animals.length ? Icons.remove : Icons.add,
                              color: theme.colorScheme.secondary,
                            ),
                            Text(
                              localizations.select_all.capitalizeFirst!,
                              style: theme.textTheme.bodyLarge!.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _animals.isEmpty
                      ? Center(
                          child: Text(localizations.no_devices.capitalizeFirst!),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: ListView.builder(
                            itemCount: _animals.length,
                            itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: AnimalItemSelectable(
                                  deviceImei: _animals[index].animal.animalName.value,
                                  deviceBattery: _animals[index].data.isNotEmpty
                                      ? _animals[index].data.first.battery.value
                                      : null,
                                  isSelected: _selectedAnimals
                                      .where((element) =>
                                          element.animal.idAnimal ==
                                          _animals[index].animal.idAnimal)
                                      .isNotEmpty,
                                  onSelected: () {
                                    int i = _selectedAnimals.indexWhere((element) =>
                                        element.animal.idAnimal == _animals[index].animal.idAnimal);

                                    if (mounted) {
                                      setState(() {
                                        if (i >= 0) {
                                          _selectedAnimals.removeAt(i);
                                        } else {
                                          _selectedAnimals.add(_animals[index]);
                                        }
                                      });
                                    }
                                  },
                                )),
                          ),
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(localizations.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(_selectedAnimals);
                      },
                      child: Text(localizations.confirm),
                    ),
                  ],
                )
              ],
            );
          }
        });
  }
}
