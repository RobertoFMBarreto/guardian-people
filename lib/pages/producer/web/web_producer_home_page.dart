import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_notifications_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_data_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/models/db/drift/query_models/alert_notification.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/ui/alert/alert_item.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/animal/animal_item.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';

/// Class that represents the web produce home page
class WebProducerHomePage extends StatefulWidget {
  final Function(Animal) onSelectAnimal;
  const WebProducerHomePage({super.key, required this.onSelectAnimal});

  @override
  State<WebProducerHomePage> createState() => _WebProducerHomePageState();
}

class _WebProducerHomePageState extends State<WebProducerHomePage> {
  late Future _future;

  List<Animal> _animals = [];
  final List<AlertNotification> _notifications = [];
  final List<FenceData> _fences = [];

  @override
  void initState() {
    _future = _setup();

    super.initState();
  }

  /// Method that does the initial setup of the page
  Future<void> _setup() async {
    await _loadDevices();
  }

  /// Method that loads the local devices into the [_animals] list an then loads from api
  Future<void> _loadDevices() async {
    getUserAnimalsWithData().then((allAnimals) {
      setState(() {
        _animals.addAll(allAnimals);
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

  /// Method that loads the alerts into the [_notifications] list
  Future<void> _loadAlerts() async {
    getAllNotifications().then((allNotifications) {
      setState(() {
        _notifications.addAll(allNotifications);
      });
    });
  }

  /// Method that loads the fences into the [_fences] list
  Future<void> _loadFences() async {
    getUserFences().then((allFences) {
      setState(() {
        _fences.addAll(allFences);
      });
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
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                localizations.devices.capitalize(),
                                style: theme.textTheme.headlineMedium,
                              ),
                            ),
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ListView.builder(
                                      itemCount: _animals.length,
                                      itemBuilder: (context, index) => AnimalItem(
                                        animal: _animals[index],
                                        onTap: () {
                                          widget.onSelectAnimal(_animals[index]);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  localizations.warnings.capitalize(),
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _notifications.isEmpty
                                        ? Center(
                                            child: Text(localizations.no_alerts.capitalize()),
                                          )
                                        : ListView.builder(
                                            itemCount: _notifications.length,
                                            itemBuilder: (context, index) => AlertItem(
                                              alertNotification: _notifications[index],
                                              onRemove: () async {
                                                await removeNotification(
                                                  _notifications[index].alertNotificationId,
                                                ).then(
                                                  (_) async => await _loadAlerts(),
                                                );
                                              },
                                            ),
                                          ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AnimalsLocationsMap(
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
