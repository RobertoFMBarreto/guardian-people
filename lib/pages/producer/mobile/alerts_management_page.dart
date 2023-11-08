import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';
import 'package:guardian/main.dart';
import 'package:get/get.dart';
import 'package:guardian/models/providers/api/requests/alerts_requests.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';

import 'package:guardian/widgets/ui/alert/alert_management_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/alert/selectable_alert_management_item.dart';

/// Class that represents the alerts management page
class AlertsManagementPage extends StatefulWidget {
  final bool isSelect;
  final String? idAnimal;

  const AlertsManagementPage({
    super.key,
    this.isSelect = false,
    this.idAnimal,
  });

  @override
  State<AlertsManagementPage> createState() => _AlertsManagementPageState();
}

class _AlertsManagementPageState extends State<AlertsManagementPage> {
  late Future _future;

  List<UserAlertCompanion> _alerts = [];
  final List<UserAlertCompanion> _selectedAlerts = [];

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  /// Method that does the initial setup of the page loading the alerts
  Future<void> _setup() async {
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
    if (widget.isSelect) {
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
    } else {
      await _getLocalUserAlerts().then(
        (value) => AlertRequests.getUserAlertsFromApi(
          context: context,
          onDataGotten: (data) {
            _getLocalUserAlerts();
          },
          onFailed: () {},
        ),
      );
    }
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
    setState(() {
      _alerts = [];
    });
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
          deleteAlert(alert.idAlert.value).then(
            (value) => removeAllAlertAnimals(alert.idAlert.value),
          );
        },
        onFailed: () {
          failedAlerts.add(alert);
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
      onFailed: () {
        setState(() {
          _alerts.add(alert);
        });
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
          localizations.warnings_managment.capitalizeFirst!,
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
                                if (widget.isSelect) {
                                  if (_selectedAlerts.length == _alerts.length) {
                                    setState(() {
                                      _selectedAlerts.removeRange(0, _selectedAlerts.length);
                                    });
                                  } else {
                                    setState(() {
                                      _selectedAlerts.addAll(_alerts);
                                    });
                                  }
                                } else {
                                  _deleteAll();
                                }
                              },
                              icon: Icon(
                                !widget.isSelect
                                    ? Icons.delete_forever
                                    : _selectedAlerts.length == _alerts.length
                                        ? Icons.close
                                        : Icons.done,
                                color: widget.isSelect
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.error,
                              ),
                              label: Text(
                                widget.isSelect
                                    ? localizations.select_all.capitalizeFirst!
                                    : '${localizations.remove.capitalizeFirst!} ${localizations.all.capitalizeFirst!}',
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: widget.isSelect
                                      ? theme.colorScheme.secondary
                                      : theme.colorScheme.error,
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
                                itemBuilder: (context, index) => widget.isSelect
                                    ? SelectableAlertManagementItem(
                                        alert: _alerts[index],
                                        isSelected: _selectedAlerts.contains(_alerts[index]),
                                        onSelected: () {
                                          // TODO: select code
                                          if (_selectedAlerts.contains(_alerts[index])) {
                                            setState(() {
                                              _selectedAlerts.remove(_alerts[index]);
                                            });
                                          } else {
                                            setState(() {
                                              _selectedAlerts.add(_alerts[index]);
                                            });
                                          }
                                        })
                                    : Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: AlertManagementItem(
                                          key: Key(_alerts[index].idAlert.value.toString()),
                                          onTap: () {
                                            if (hasConnection) {
                                              Future.delayed(const Duration(milliseconds: 300))
                                                  .then((value) => Navigator.push(
                                                        context,
                                                        CustomPageRouter(
                                                            page: '/producer/alerts/add',
                                                            settings: RouteSettings(
                                                              arguments: {
                                                                'isEdit': true,
                                                                'alert': _alerts[index],
                                                              },
                                                            )),
                                                      ).then(
                                                        (_) => _loadAlerts(),
                                                      ));
                                            }
                                          },
                                          alert: _alerts[index],
                                          onDelete: (_) {
                                            _deleteAlert(index);
                                          },
                                        ),
                                      ),
                              ),
                            ),
                    ),
                  ],
                );
              }
            }),
      ),
      floatingActionButton:
          (widget.isSelect && _selectedAlerts.isNotEmpty) || !widget.isSelect && hasConnection
              ? FloatingActionButton.extended(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  backgroundColor: theme.colorScheme.secondary,
                  onPressed: () {
                    if (!widget.isSelect) {
                      Navigator.push(
                        context,
                        CustomPageRouter(
                          page: '/producer/alerts/add',
                        ),
                      ).then(
                        (_) => _loadAlerts(),
                      );
                    } else {
                      Navigator.of(context).pop(_selectedAlerts);
                    }
                  },
                  label: Text(
                    widget.isSelect
                        ? localizations.confirm.capitalizeFirst!
                        : '${localizations.add.capitalizeFirst!} ${localizations.warning.capitalizeFirst!}',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: Icon(
                    widget.isSelect ? Icons.done : Icons.add,
                    color: theme.colorScheme.onSecondary,
                  ),
                )
              : null,
    );
  }
}
