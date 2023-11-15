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
import 'package:get/get.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/models/providers/api/requests/fencing_requests.dart';
import 'package:guardian/models/providers/api/requests/notifications_requests.dart';
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
  int _reloadMap = 9999;
  List<Animal> _animals = [];
  List<FenceData> _fences = [];
  List<AlertNotification> _alertNotifications = [];

  @override
  void initState() {
    _future = _setup();

    super.initState();
  }

  /// Method that doest the initial setup
  ///
  /// 1. load user data
  /// 2. load user animals
  /// 3. load fences
  /// 4. load alert notifications
  Future<void> _setup() async {
    await _loadAnimals();
    await _loadFences();
    await _loadAlertNotifications();
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

  /// Method that loads all fences into the [_fences] list
  ///
  /// In the process updates the [_reloadMap] variable so that the map reloads
  ///
  /// Resets the list to avoid duplicates
  Future<void> _loadFences() async {
    await _loadLocalFences().then((_) {
      FencingRequests.getUserFences(
        context: context,
        onGottenData: (_) async {
          await _loadLocalFences();
        },
        onFailed: () {},
      );
    });
  }

  /// Method that allows to get local fences
  Future<void> _loadLocalFences() async {
    await getUserFences().then((allFences) {
      _fences = [];
      setState(() {
        _fences.addAll(allFences);
        _reloadMap = Random().nextInt(999999);
      });
    });
  }

  /// Method that loads all alert notifications into the [_alertNotifications] list
  ///
  /// Resets the list to avoid duplicates
  Future<void> _loadAlertNotifications() async {
    _loadLocalAlertNotifications().then((_) => _getNotificationsFromApi());
  }

  /// Method that loads all alert notifications into the [_alertNotifications] list
  ///
  /// Resets the list to avoid duplicates
  Future<void> _loadLocalAlertNotifications() async {
    await getAllNotifications().then((allAlerts) {
      _alertNotifications = [];
      setState(() => _alertNotifications.addAll(allAlerts));
    });
  }

  /// Method that loads all notifications from api
  Future<void> _getNotificationsFromApi() async {
    NotificationsRequests.getUserNotificationsFromApi(
      context: context,
      onDataGotten: (data) {
        _loadLocalAlertNotifications();
      },
      onFailed: () {},
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
                                localizations.devices.capitalizeFirst!,
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
                                  localizations.warnings.capitalizeFirst!,
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _alertNotifications.isEmpty
                                        ? Center(
                                            child: Text(localizations.no_alerts.capitalizeFirst!),
                                          )
                                        : ListView.builder(
                                            itemCount: _alertNotifications.length,
                                            itemBuilder: (context, index) => AlertItem(
                                              alertNotification: _alertNotifications[index],
                                              onRemove: () async {
                                                await removeNotification(
                                                  _alertNotifications[index].alertNotificationId,
                                                ).then(
                                                  (_) async => await _loadAlertNotifications(),
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
