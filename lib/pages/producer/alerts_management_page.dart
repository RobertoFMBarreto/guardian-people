import 'package:flutter/material.dart';
import 'package:guardian/db/alert_devices_operations.dart';
import 'package:guardian/db/user_alert_operations.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/pages/producer/alerts_management_page/alert_management_item.dart';
import 'package:guardian/widgets/pages/producer/alerts_page/add_alert_bottom_sheet.dart';
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

  @override
  void initState() {
    _loadAlerts().then((value) => setState(() => isLoading = false));
    super.initState();
  }

  Future<void> _loadAlerts() async {
    await getUid(context).then((userId) async {
      alerts = [];
      if (userId != null) {
        if (widget.isSelect) {
          await getDeviceUnselectedAlerts(userId).then(
            (allAlerts) {
              setState(() {
                alerts.addAll(allAlerts);
                isLoading = false;
              });
            },
          );
        } else {
          await getUserAlerts(userId).then(
            (allAlerts) {
              setState(() {
                alerts.addAll(allAlerts);
                isLoading = false;
              });
            },
          );
        }
      }
    });
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
                                    // showModalBottomSheet(
                                    //   context: context,
                                    //   isScrollControlled: true,
                                    //   builder: (context) => AddAlertBottomSheet(
                                    //     comparisson: alerts[index].comparisson,
                                    //     hasNotification: alerts[index].hasNotification,
                                    //     parameter: alerts[index].parameter,
                                    //     value: alerts[index].value,
                                    //     isEdit: true,
                                    //     onConfirm:
                                    //         (parameter, comparisson, value, hasNotification) {
                                    //       final newAlert = alerts[index].copy(
                                    //         parameter: parameter,
                                    //         comparisson: comparisson,
                                    //         value: value,
                                    //         hasNotification: hasNotification,
                                    //       );

                                    //       updateUserAlert(newAlert).then(
                                    //         (_) {
                                    //           Navigator.of(context).pop();
                                    //           setState(() => alerts[index] = newAlert);
                                    //         },
                                    //       );
                                    //     },
                                    //   ),
                                    // );
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
                  // showModalBottomSheet(
                  //   context: context,
                  //   isScrollControlled: true,
                  //   builder: (context) => AddAlertBottomSheet(
                  //     onConfirm: (parameter, comparisson, value, hasNotification) {
                  //       createAlert(
                  //         UserAlert(
                  //           alertId: (alerts.length + 1).toString(),
                  //           hasNotification: hasNotification,
                  //           parameter: parameter,
                  //           comparisson: comparisson,
                  //           value: value,
                  //         ),
                  //       ).then((newAlert) => setState(() => alerts.add(newAlert)));
                  //       Navigator.of(context).pop();
                  //     },
                  //   ),
                  // );
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
