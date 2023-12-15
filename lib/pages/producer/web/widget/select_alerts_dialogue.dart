import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';
import 'package:guardian/main.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/providers/api/requests/alerts_requests.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';

import 'package:guardian/widgets/ui/alert/alert_management_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/alert/selectable_alert_management_item.dart';

class SelectAlertsDialogue extends StatefulWidget {
  final String? idAnimal;

  const SelectAlertsDialogue({
    super.key,
    this.idAnimal,
  });

  @override
  State<SelectAlertsDialogue> createState() => _SelectAlertsDialogueState();
}

class _SelectAlertsDialogueState extends State<SelectAlertsDialogue> {
  late Future _future;

  List<UserAlertCompanion> _alerts = [];
  final List<UserAlertCompanion> _selectedAlerts = [];
  bool _firstRun = true;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  /// Method that does the initial setup of the page loading the alerts
  Future<void> _setup() async {
    isSnackbarActive = false;
    await _loadAlerts();
  }

  /// Method that loads the user alerts into the [_alerts] list
  ///
  /// If is in select mode ( [widget.isSelect]=`true`) then only the unselected alerts will be shown
  ///
  /// If it isnt in select mode then all user alerts will be shown
  ///
  /// Resets the list to prevent duplicates
  Future<void> _loadAlerts() async {
    await _getLocalUnselectedUserAlerts(widget.idAnimal!).then(
      (_) => AlertRequests.getUserAlertsFromApi(
        context: context,
        onDataGotten: (data) {
          _getLocalUnselectedUserAlerts(widget.idAnimal!);
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

  /// Method that allows to get all local user alerts
  Future<void> _getLocalUnselectedUserAlerts(String idAnimal) async {
    await getAnimalUnselectedAlerts(widget.idAnimal!).then(
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

  /// Method that allows to delete all user alerts deleting first locally and then from the api
  Future<void> _deleteAll() async {
    _deleteAllFromApi().then((failedAlerts) {
      if (failedAlerts.isNotEmpty) {
        setState(() {
          _alerts.addAll(failedAlerts);
        });
      }
    });
  }

  /// Method that allows to delete all alerts from api
  ///
  /// In case of fail the alert is added again
  ///
  /// In case everything goes wright the animals of alert are removed
  Future<List<UserAlertCompanion>> _deleteAllFromApi() async {
    List<UserAlertCompanion> failedAlerts = [];
    for (UserAlertCompanion alert in _alerts) {
      await AlertRequests.deleteUserAlertFromApi(
        context: context,
        alertId: alert.idAlert.value,
        onDataGotten: (data) {
          setState(() {
            _alerts.removeWhere((element) => element.idAlert.value == alert.idAlert.value);
          });
          deleteAlert(alert.idAlert.value).then(
            (value) => removeAllAlertAnimals(alert.idAlert.value),
          );
        },
        onFailed: (statusCode) {
          failedAlerts.add(alert);
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
    return failedAlerts;
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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.alerts.capitalizeFirst!,
          style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CustomCircularProgressIndicator();
              } else {
                return Column(
                  children: [
                    if (hasConnection && _alerts.isNotEmpty)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              style: const ButtonStyle(
                                  minimumSize: MaterialStatePropertyAll(Size(200, 100))),
                              onPressed: () {
                                if (_selectedAlerts.length == _alerts.length) {
                                  setState(() {
                                    _selectedAlerts.removeRange(0, _selectedAlerts.length);
                                  });
                                } else {
                                  setState(() {
                                    _selectedAlerts.addAll(_alerts);
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.delete_forever,
                                color: theme.colorScheme.secondary,
                              ),
                              label: Text(
                                localizations.select_all.capitalizeFirst!,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      flex: 12,
                      child: _alerts.isEmpty
                          ? Center(
                              child: Text(localizations.no_alerts.capitalizeFirst!),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 40.0),
                              child: ListView.builder(
                                  itemCount: _alerts.length,
                                  itemBuilder: (context, index) => SelectableAlertManagementItem(
                                      alert: _alerts[index],
                                      isSelected: _selectedAlerts.contains(_alerts[index]),
                                      onSelected: () {
                                        if (_selectedAlerts.contains(_alerts[index])) {
                                          setState(() {
                                            _selectedAlerts.remove(_alerts[index]);
                                          });
                                        } else {
                                          setState(() {
                                            _selectedAlerts.add(_alerts[index]);
                                          });
                                        }
                                      })),
                            ),
                    ),
                  ],
                );
              }
            }),
      ),
      floatingActionButton: hasConnection
          ? FloatingActionButton.extended(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              backgroundColor: theme.colorScheme.secondary,
              onPressed: () {
                Navigator.of(context).pop(_selectedAlerts);
              },
              label: Text(
                localizations.confirm.capitalizeFirst!,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Icon(
                Icons.done,
                color: theme.colorScheme.onSecondary,
              ),
            )
          : null,
    );
  }
}
