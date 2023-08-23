import 'package:flutter/material.dart';
import 'package:guardian/db/user_alert_operations.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/read_json.dart';
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
    getUid(context).then((userId) {
      if (userId != null) {
        getUserAlerts(userId).then(
          (allAlerts) {
            alerts.addAll(allAlerts);
            isLoading = false;
          },
        );
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
                      : GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => AddAlertBottomSheet(
                                comparisson: alerts[index].comparisson,
                                hasNotification: alerts[index].hasNotification,
                                parameter: alerts[index].parameter,
                                value: alerts[index].value,
                                isEdit: true,
                                onConfirm: (parameter, comparisson, value, hasNotification) {
                                  //TODO: edit alert code
                                },
                              ),
                            );
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
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        backgroundColor: theme.colorScheme.secondary,
        onPressed: () {
          if (!widget.isSelect) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => AddAlertBottomSheet(
                onConfirm: (parameter, comparisson, value, hasNotification) {
                  //TODO: Add alert code
                },
              ),
            );
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
      ),
    );
  }
}
