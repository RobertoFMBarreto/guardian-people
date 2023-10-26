import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/parsers/animals_parsers.dart';
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
  DateTime _endDate = DateTime.now();

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
  /// 2. get the local animal data
  /// 3. get the animal data from api
  Future<void> _setup() async {
    setState(() {
      _animalData = widget.animal.data;
    });
    await _getAnimalData();
    await _getAnimalDataFromApi();
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

  /// Method that loads all devices from the API into the [_animals] list
  ///
  /// In case the session token expires then it calls the api to refresh the token and doest the initial request again
  ///
  /// If the server takes too long to answer then the user receives and alert
  Future<void> _getAnimalDataFromApi() async {
    await AnimalProvider.getAnimalData(widget.animal.animal.idAnimal.value, _startDate, _endDate)
        .then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        final body = jsonDecode(response.body);
        for (var dt in body) {
          await animalDataFromJson(dt, widget.animal.animal.idAnimal.value.toString());
        }
        _getAnimalData();
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken);
            _getAnimalDataFromApi();
          } else if (response.statusCode == 507) {
            setState(() {
              _startDate = DateTime.now();
              _endDate = DateTime.now();
            });
            hasShownNoServerConnection().then((hasShown) async {
              setState(() {
                _startDate = DateTime.now();
                _endDate = DateTime.now();
              });
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.server_error.capitalize!,
                    ),
                  ),
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
                      child: AnimalTimeRangeWidget(
                          startDate: _startDate,
                          endDate: _endDate,
                          onStartDateChanged: (newStartDate) {
                            setState(() {
                              _startDate = newStartDate;
                              _future = _getAnimalDataFromApi();
                            });
                          },
                          onEndDateChanged: (newEndDate) {
                            setState(() {
                              _endDate = newEndDate;
                              _future = _getAnimalDataFromApi();
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
