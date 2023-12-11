import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:get/get.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/api/requests/alerts_requests.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/models/providers/api/requests/fencing_requests.dart';
import 'package:guardian/pages/producer/web/widget/add_alert.dart';
import 'package:guardian/widgets/ui/alert/alert_item.dart';
import 'package:guardian/widgets/ui/alert/alert_management_item.dart';
import 'package:guardian/widgets/ui/common/geofencing.dart';
import 'package:guardian/widgets/inputs/search_filter_input.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/fence/fence_item.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';

/// Class that represents the web producer fences page
class WebProducerAlertsPage extends StatefulWidget {
  const WebProducerAlertsPage({super.key});

  @override
  State<WebProducerAlertsPage> createState() => _WebProducerAlertsPageState();
}

class _WebProducerAlertsPageState extends State<WebProducerAlertsPage> {
  late Future _future;

  final GlobalKey _mapParentKey = GlobalKey();
  UserAlertCompanion? _selectedAlert;
  List<Animal> _animals = [];
  List<UserAlertCompanion> _alerts = [];
  List<FenceData> _fences = [];
  bool isInteractingAlert = false;
  bool _firstRun = false;

  @override
  void initState() {
    _future = _setup();

    super.initState();
  }

  /// Method that does the initial setup of the page
  Future<void> _setup() async {
    await _loadFences();
    await _loadAlerts();
    await _loadAnimals();
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
          onFailed: (statusCode) {
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

  /// Method that allows to get all local user alerts
  Future<void> _getLocalUserAlerts() async {
    await getUserAlerts().then(
      (allAlerts) {
        if (mounted) {
          setState(() {
            _alerts = [];
            _alerts.addAll(allAlerts);
          });
        }
      },
    );
  }

  /// Method that loads the fences into the [_fences] list
  Future<void> _loadAlerts() async {
    await _getLocalUserAlerts().then(
      (value) => AlertRequests.getUserAlertsFromApi(
        context: context,
        onDataGotten: (data) {
          _getLocalUserAlerts();
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
      ),
    );
  }

  /// Method that allows to delete an alert first locally and then from api
  ///
  /// In case of fail the alert is added again
  ///
  /// In case everything goes wright the animals of alert are removed
  Future<void> _deleteAlert(int index) async {
    final alert = _alerts[index];

    setState(() {
      _alerts.removeAt(index);
    });
    await AlertRequests.deleteUserAlertFromApi(
      context: context,
      alertId: alert.idAlert.value,
      onDataGotten: (data) {
        deleteAlert(alert.idAlert.value);
        removeAllAlertAnimals(alert.idAlert.value);
      },
      onFailed: (statusCode) {
        setState(() {
          _alerts.add(alert);
        });
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

  /// Method that loads the fences into the [_fences] list
  Future<void> _loadFences() async {
    await _loadLocalFences().then(
      (_) => FencingRequests.getUserFences(
        context: context,
        onGottenData: (data) async {
          await _loadLocalFences();
        },
        onFailed: (statusCode) {
          AppLocalizations localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(localizations.server_error)));
        },
      ),
    );
  }

  /// Method that loads the fences into the [_fences] list
  Future<void> _loadLocalFences() async {
    await getUserFences().then((allFences) => setState(() {
          _fences = [];
          _fences.addAll(allFences);
        }));
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: isInteractingAlert
                                            ? MainAxisAlignment.center
                                            : MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            localizations.alerts.capitalizeFirst!,
                                            style: theme.textTheme.headlineMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isInteractingAlert)
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  isInteractingAlert = !isInteractingAlert;
                                                });
                                              },
                                              icon: Icon(Icons.add),
                                              label: Text(
                                                '${localizations.add.capitalizeFirst!} ${localizations.alert.capitalizeFirst!}',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: _alerts.length,
                                                itemBuilder: (context, index) {
                                                  return AlertManagementItem(
                                                    key: Key(
                                                        _alerts[index].idAlert.value.toString()),
                                                    onTap: () {
                                                      if (hasConnection) {
                                                        Future.delayed(
                                                                const Duration(milliseconds: 300))
                                                            .then((value) => setState(() {
                                                                  isInteractingAlert = true;
                                                                  _selectedAlert = _alerts[index];
                                                                }));
                                                      }
                                                    },
                                                    alert: _alerts[index],
                                                    onDelete: (_) {
                                                      _deleteAlert(index);
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
                      ],
                    ),
                  ),
                ),
                if (isInteractingAlert)
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
                                  flex: 4,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      localizations.device_settings.capitalizeFirst!,
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isInteractingAlert = false;
                                            _selectedAlert = null;
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
                            child: AddAlert(
                              alert: _selectedAlert,
                              isEdit: _selectedAlert != null,
                              onCreate: () {
                                _loadAlerts();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  key: _mapParentKey,
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AnimalsLocationsMap(
                        key: Key(_fences.toString()),
                        showCurrentPosition: true,
                        animals: _animals,
                        fences: _fences,
                        centerOnPoly: _fences.isNotEmpty,
                        parent: _mapParentKey,
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
