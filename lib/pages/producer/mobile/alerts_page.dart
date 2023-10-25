import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/operations/alert_notifications_operations.dart';
import 'package:guardian/models/db/drift/query_models/alert_notification.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/tmp/read_json.dart';

import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/alert/alert_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents the alerts page
class AlertsPage extends StatefulWidget {
  const AlertsPage({
    super.key,
  });

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late Future _future;

  List<AlertNotification> _alerts = [];

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  /// Method that does the initial setup of the page loading the alerts
  Future<void> _setup() async {
    await _loadAlerts();
  }

  /// Method that loads all alert notifications in to the [_alerts] list
  ///
  /// Resets the list to prevent duplicates
  Future<void> _loadAlerts() async {
    getAllNotifications().then(
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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            localizations.alerts.capitalize(),
            style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          backgroundColor: theme.colorScheme.secondary,
          onPressed: () {
            Navigator.push(
              context,
              CustomPageRouter(
                  page: '/producer/alerts/management',
                  settings: const RouteSettings(
                    arguments: {'isSelect': false, 'idAnimal': null},
                  )),
            ).then(
              (_) => _loadAlerts(),
            );
          },
          label: Text(
            '${localizations.manage.capitalize()} ${localizations.warnings.capitalize()}',
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icon(
            Icons.edit,
            color: theme.colorScheme.onSecondary,
          ),
        ),
        body: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CustomCircularProgressIndicator();
              } else {
                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (hasConnection)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                //removeAllNotifications().then((_) => loadAlerts());
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_forever,
                                    color: theme.colorScheme.error,
                                  ),
                                  Text(
                                    '${localizations.remove.capitalize()} ${localizations.all.capitalize()}',
                                    style: theme.textTheme.bodyLarge!.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      Expanded(
                        child: _alerts.isEmpty
                            ? Center(
                                child: Text(localizations.no_notifications.capitalize()),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: ListView.builder(
                                  itemCount: _alerts.length,
                                  itemBuilder: (context, index) => AlertItem(
                                    alertNotification: _alerts[index],
                                    onRemove: () async {
                                      await removeNotification(
                                        _alerts[index].alertNotificationId,
                                      ).then(
                                        (_) async => await _loadAlerts(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              }
            }));
  }
}
