import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/parsers/animals_parsers.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/animal/animal_time_widget.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';
import 'package:guardian/widgets/ui/maps/single_device_location_map.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents the animal map widget
class AnimalMapWidget extends StatefulWidget {
  final Animal animal;
  final bool isInterval;
  const AnimalMapWidget({super.key, required this.animal, required this.isInterval});

  @override
  State<AnimalMapWidget> createState() => _AnimalMapWidgetState();
}

class _AnimalMapWidgetState extends State<AnimalMapWidget> {
  final _firstItemDataKey = GlobalKey();
  late Future _future;

  List<AnimalLocationsCompanion> _animalData = [];

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  bool _showHeatMap = false;

  double _currentZoom = 17;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  /// Method that does the initial setup of the widget
  ///
  /// 1. set the animal data
  /// 2. if interval
  ///       if endDate == atual
  ///         setup realtime location
  ///         and get history
  ///       else
  ///         get history
  ///    else
  ///       get the last animal location
  Future<void> _setup() async {
    setState(() {
      _animalData = widget.animal.data;
    });
    // await _getAnimalData();
    // await _getAnimalDataFromApi();
    final now = DateTime.now();
    if (widget.isInterval) {
      // get data in interval
      _getAnimalData();
      AnimalRequests.getAnimalDataIntervalFromApi(
        idAnimal: widget.animal.animal.idAnimal.value,
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
                      AppLocalizations.of(context)!.server_error.capitalize!,
                    ),
                  ),
                );
              }
            }
          });
        },
      );
      if (_endDate == null) {
        // make realtime request
      }
    } else {
      // get last location
      _getLastLocation();
      AnimalRequests.getAnimalsFromApiWithLastLocation(
          context: context,
          onDataGotten: () {
            _getLastLocation();
          });
    }
  }

  /// Method that loads that local animal data into the [_animalData] list
  Future<void> _getAnimalData() async {
    await getAnimalData(
      startDate: _startDate,
      endDate: _endDate,
      idAnimal: widget.animal.animal.idAnimal.value,
      isInterval: widget.isInterval,
    ).then(
      (data) async {
        _animalData = [];
        if (mounted) {
          setState(() {
            _animalData.addAll(data);
          });
        }
      },
    );
  }

  Future<void> _getLastLocation() async {
    await getUserAnimalWithLastLocation(widget.animal.animal.idAnimal.value).then((animal) {
      setState(() {
        _animalData = [];
        _animalData.addAll(animal.first.data);
      });
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
                      child: AnimalTimeRangeWidget(
                          startDate: _startDate,
                          endDate: _endDate,
                          onStartDateChanged: (newStartDate) {
                            setState(() {
                              _startDate = newStartDate;
                              _future = _setup();
                            });
                          },
                          onEndDateChanged: (newEndDate) {
                            setState(() {
                              _endDate = newEndDate;
                              _future = _setup();
                            });
                          }),
                    ),
                  ),
                Expanded(
                  key: _firstItemDataKey,
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SingleAnimalLocationMap(
                        key: Key(_animalData.toString()),
                        showCurrentPosition: true,
                        deviceData: _animalData,
                        idAnimal: widget.animal.animal.idAnimal.value,
                        deviceColor: widget.animal.animal.animalColor.value,
                        isInterval: widget.isInterval,
                        endDate: _endDate ?? DateTime.now(),
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
