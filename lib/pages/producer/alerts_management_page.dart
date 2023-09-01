import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/models/db/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/db/operations/alert_devices_operations.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/operations/user_alert_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';

import 'package:guardian/widgets/ui/dropdown/alert/alert_management_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/alert/selectable_alert_management_item.dart';

class AlertsManagementPage extends StatefulWidget {
  final bool isSelect;

  const AlertsManagementPage({
    super.key,
    this.isSelect = false,
  });

  @override
  State<AlertsManagementPage> createState() => _AlertsManagementPageState();
}

class _AlertsManagementPageState extends State<AlertsManagementPage> {
  late Future _future;

  List<UserAlert> _alerts = [];
  List<UserAlert> _selectedAlerts = [];

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  Future<void> _setup() async {
    await _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    if (widget.isSelect) {
      await getDeviceUnselectedAlerts().then(
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
          localizations.warnings_managment.capitalize(),
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
                                      ? localizations.select_all.capitalize()
                                      : localizations.remove_all.capitalize(),
                                  style: theme.textTheme.bodyLarge!.copyWith(
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
                        flex: 15,
                        child: ListView.builder(
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
                                  child: GestureDetector(
                                    onTap: () {
                                      if (hasConnection) {
                                        Navigator.of(context).pushNamed(
                                          '/producer/alerts/add',
                                          arguments: {
                                            'isEdit': true,
                                            'alert': _alerts[index],
                                          },
                                        ).then((_) {
                                          _loadAlerts();
                                        });
                                      }
                                    },
                                    child: AlertManagementItem(
                                      alert: _alerts[index],
                                      onDelete: (alert) {
                                        // TODO: Remove code
                                        deleteAlert(_alerts[index].alertId);
                                        setState(() {
                                          _alerts.removeAt(index);
                                        });
                                      },
                                    ),
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
      floatingActionButton: (widget.isSelect && _selectedAlerts.isNotEmpty) || !widget.isSelect
          ? FloatingActionButton.extended(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              backgroundColor: theme.colorScheme.secondary,
              onPressed: () {
                if (!widget.isSelect) {
                  Navigator.of(context).pushNamed('/producer/alerts/add').then((_) {
                    _loadAlerts();
                  });
                } else {
                  Navigator.of(context).pop(_selectedAlerts);
                }
              },
              label: Text(
                widget.isSelect
                    ? localizations.confirm.capitalize()
                    : '${localizations.add.capitalize()} ${localizations.warning.capitalize()}',
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
