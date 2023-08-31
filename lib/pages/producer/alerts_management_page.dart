import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian/db/alert_devices_operations.dart';
import 'package:guardian/db/user_alert_operations.dart';
import 'package:guardian/models/custom_alert_dialogs.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:guardian/widgets/pages/producer/alerts_management_page/alert_management_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/selectable_alert_management_item.dart';

class AlertsManagementPage extends StatefulWidget {
  final bool isSelect;
  const AlertsManagementPage({super.key, this.isSelect = false});

  @override
  State<AlertsManagementPage> createState() => _AlertsManagementPageState();
}

class _AlertsManagementPageState extends State<AlertsManagementPage> {
  List<UserAlert> alerts = [];
  bool isLoading = true;
  List<UserAlert> selectedAlerts = [];

  late StreamSubscription subscription;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    subscription = wifiConnectionChecker(
      context: context,
      onHasConnection: () async {
        print("Has Connection");
        await setShownNoWifiDialog(false);
      },
      onNotHasConnection: () async {
        print("No Connection");
        await hasShownNoWifiDialog().then((hasShown) async {
          if (!hasShown) {
            showNoWifiDialog(context);
            await setShownNoWifiDialog(true);
          }
        });
      },
    );
    _loadAlerts().then((value) => setState(() => isLoading = false));
    super.initState();
  }

  Future<void> _loadAlerts() async {
    if (widget.isSelect) {
      await getDeviceUnselectedAlerts().then(
        (allAlerts) {
          setState(() {
            alerts = [];
            alerts.addAll(allAlerts);
            isLoading = false;
          });
        },
      );
    } else {
      await getUserAlerts().then(
        (allAlerts) {
          setState(() {
            alerts = [];
            alerts.addAll(allAlerts);
            isLoading = false;
          });
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
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              if (widget.isSelect) {
                                if (selectedAlerts.length == alerts.length) {
                                  setState(() {
                                    selectedAlerts.removeRange(0, selectedAlerts.length);
                                  });
                                } else {
                                  setState(() {
                                    selectedAlerts.addAll(alerts);
                                  });
                                }
                              } else {
                                deleteAllAlerts();
                                setState(() {
                                  alerts = [];
                                });
                              }
                            },
                            icon: Icon(
                              !widget.isSelect
                                  ? Icons.delete_forever
                                  : selectedAlerts.length == alerts.length
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
                        itemCount: alerts.length,
                        padding: const EdgeInsets.only(bottom: 20.0),
                        itemBuilder: (context, index) => widget.isSelect
                            ? SelectableAlertManagementItem(
                                alert: alerts[index],
                                isSelected: selectedAlerts.contains(alerts[index]),
                                onSelected: () {
                                  //!TODO: select code
                                  if (selectedAlerts.contains(alerts[index])) {
                                    setState(() {
                                      selectedAlerts.remove(alerts[index]);
                                    });
                                  } else {
                                    setState(() {
                                      selectedAlerts.add(alerts[index]);
                                    });
                                  }
                                })
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      '/producer/alerts/add',
                                      arguments: {
                                        'isEdit': true,
                                        'alert': alerts[index],
                                      },
                                    ).then((_) {
                                      print('BAck');
                                      _loadAlerts();
                                    });
                                  },
                                  child: AlertManagementItem(
                                    alert: alerts[index],
                                    onDelete: (alert) {
                                      //!TODO: Remove code
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: (widget.isSelect && selectedAlerts.isNotEmpty) || !widget.isSelect
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
                  Navigator.of(context).pop(selectedAlerts);
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
