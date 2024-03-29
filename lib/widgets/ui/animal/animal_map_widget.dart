import 'package:dart_amqp/dart_amqp.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
// ignore: unused_import
import 'package:drift/drift.dart' as drift;
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/providers/api/parsers/animals_parsers.dart';
import 'package:guardian/models/providers/api/rabbit_mq_provider.dart';
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
  final Function(AnimalLocationsCompanion) onNewData;
  const AnimalMapWidget(
      {super.key, required this.animal, required this.isInterval, required this.onNewData});

  @override
  State<AnimalMapWidget> createState() => _AnimalMapWidgetState();
}

class _AnimalMapWidgetState extends State<AnimalMapWidget> {
  final _firstItemDataKey = GlobalKey();

  late Future _future;

  DateTime? _endDate;

  List<AnimalLocationsCompanion> _animalData = [];

  bool _showHeatMap = false;
  double _currentZoom = 17;
  DateTime _startDate = DateTime.now();
  RabbitMQProvider rabbitMQProvider = RabbitMQProvider();

  late Consumer consumer;

  bool _firstRun = true;

  @override
  void dispose() {
    AnimalRequests.stopRealtimeStreaming(
      idAnimal: widget.animal.animal.idAnimal.value,
      context: context,
      onDataGotten: () {
        rabbitMQProvider.stop();
      },
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
    );

    super.dispose();
  }

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

    if (widget.isInterval) {
      // get data in interval
      _getAnimalData();
      await AnimalRequests.getAnimalDataIntervalFromApi(
        idAnimal: widget.animal.animal.idAnimal.value,
        startDate: _startDate,
        endDate: _endDate ?? DateTime.now(),
        context: context,
        onDataGotten: () {
          _getAnimalData();
        },
        onFailed: (statusCode) {
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
              }
            }
          });
        },
      );
    } else {
      // get last location
      if (widget.animal.data.isNotEmpty) {
        setState(() {
          _startDate = widget.animal.data
                  .firstWhereOrNull((element) => element.lat.value != null)
                  ?.date
                  .value ??
              DateTime.now();
        });
      } else {
        _getLastLocation().then(
          (_) => setState(() {
            _startDate =
                _animalData.firstWhereOrNull((element) => element.lat.value != null)?.date.value ??
                    DateTime.now();
          }),
        );
        await AnimalRequests.getAnimalsFromApiWithLastLocation(
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
              _getLastLocation();
            });
      }
    }

    if (_endDate == null) {
      // make realtime request
      // ignore: use_build_context_synchronously
      await AnimalRequests.startRealtimeStreaming(
        idAnimal: widget.animal.animal.idAnimal.value,
        context: context,
        onDataGotten: () {
          rabbitMQProvider.listen(
            topicId: widget.animal.animal.idAnimal.value,
            onDataReceived: (message) {
              if (message['lat'] != null && message['lon'] != null) {
                animalDataFromJson(message, widget.animal.animal.idAnimal.value).then(
                  (newData) => (widget.isInterval ? _getAnimalData() : _getLastLocation())
                      .then((value) => widget.onNewData(newData)),
                );
              }
            },
          );
        },
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
      );
    }
  }

  /// Method that loads that local animal data into the [_animalData] list
  Future<void> _getAnimalData() async {
    getAnimalData(
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

  /// Method that allows to get the animal with the last location from api and store it in [_animalData] variable
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
                    child: AnimalTimeRangeWidget(
                      startDate: _startDate,
                      endDate: _endDate,
                      onDateChanged: (newStartDate, newEndDate) {
                        Navigator.of(context).pop();
                        setState(() {
                          _startDate = newStartDate;
                          _endDate = newEndDate;
                          _future = _setup();
                        });
                      },
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
                        parent: _firstItemDataKey,
                        startingZoom: _currentZoom,
                      ),
                      // NewMapTest(
                      //   showCurrentPosition: true,
                      //   deviceData: _animalData,
                      //   idAnimal: widget.animal.animal.idAnimal.value,
                      //   deviceColor: widget.animal.animal.animalColor.value,
                      //   isInterval: widget.isInterval,
                      //   endDate: _endDate ?? DateTime.now(),
                      //   startDate: _startDate,
                      //   onZoomChange: (newZoom) {
                      //     // No need to setstate because we dont need to update the screen
                      //     // just need to store the value in case the map restarts to keep zoom
                      //     _currentZoom = newZoom;
                      //   },
                      //   startingZoom: _currentZoom,
                      // )
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
