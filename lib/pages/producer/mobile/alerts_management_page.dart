import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';
import 'package:guardian/main.dart';
import 'package:get/get.dart';
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
                return Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                  child: Column(
                    children: [
                      if (hasConnection)
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
                                    deleteAllAlerts();
                                    setState(() {
                                      _alerts = [];
                                    });
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
                                      : localizations.remove_all.capitalizeFirst!,
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
                            : ListView.builder(
                                itemCount: _alerts.length,
                                padding: const EdgeInsets.only(bottom: 20.0),
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
                                          onDelete: (alert) {
                                            // TODO: Remove code
                                            deleteAlert(_alerts[index].idAlert.value);
                                            setState(() {
                                              _alerts.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                              ),
                      ),
                    ],
                  ),
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
