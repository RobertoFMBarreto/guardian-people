import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/operations/alert_notifications_operations.dart';
import 'package:guardian/models/db/drift/query_models/alert_notification.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/providers/api/requests/notifications_requests.dart';

import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/alert/alert_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class that represents the alerts page
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future _future;

  List<AlertNotification> _alerts = [];
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

  /// Method that loads all alert notifications first locally and then on api
  ///
  /// Resets the list to prevent duplicates
  Future<void> _loadAlerts() async {
    _loadLocalAlerts().then(
      (_) {
        NotificationsRequests.getUserNotificationsFromApi(
          context: context,
          onDataGotten: (data) {
            _loadLocalAlerts();
          },
          onFailed: (statusCode) {
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
          },
        );
      },
    );
  }

  /// Method that loads all local alert notifications in to the [_alerts] list
  ///
  /// Resets the list to prevent duplicates
  Future<void> _loadLocalAlerts() async {
    await getAllNotifications().then(
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

  /// Method that deletes all notifications from api
  Future<void> _deleteAllNotifications() async {
    await NotificationsRequests.deleteAllNotificationsFromApi(
      context: context,
      onDataGotten: (data) {
        removeAllNotifications().then((_) => _loadLocalAlerts());
      },
      onFailed: (statusCode) {
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
      },
    );
  }

  /// Method that deletes all notifications from api
  Future<void> _deleteNotification(int index) async {
    final deletedAlert = _alerts[index];
    _alerts.removeAt(index);
    await NotificationsRequests.deleteNotificationFromApi(
      context: context,
      idNotification: deletedAlert.alertNotificationId,
      onDataGotten: (data) {
        removeNotification(
          deletedAlert.alertNotificationId,
        ).then(
          (_) async => await _loadAlerts(),
        );
      },
      onFailed: (statusCode) {
        setState(() {
          _alerts.add(deletedAlert);
        });
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
            '${localizations.manage.capitalizeFirst!} ${localizations.warnings.capitalizeFirst!}',
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
                      if (hasConnection && _alerts.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _deleteAllNotifications,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_forever,
                                    color: theme.colorScheme.error,
                                  ),
                                  Text(
                                    '${localizations.remove.capitalizeFirst!} ${localizations.all.capitalizeFirst!}',
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
                                child: Text(localizations.no_notifications.capitalizeFirst!),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: ListView.builder(
                                  itemCount: _alerts.length,
                                  itemBuilder: (context, index) => AlertItem(
                                    alertNotification: _alerts[index],
                                    onRemove: () {
                                      _deleteNotification(index);
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
