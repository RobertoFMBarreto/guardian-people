import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_notifications_operations.dart';
import 'package:guardian/models/db/drift/operations/device_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/models/db/drift/query_models/alert_notification.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/ui/alert/alert_item.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/device/device_item.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';

class WebProducerHomePage extends StatefulWidget {
  const WebProducerHomePage({super.key});

  @override
  State<WebProducerHomePage> createState() => _WebProducerHomePageState();
}

class _WebProducerHomePageState extends State<WebProducerHomePage> {
  late Future _future;

  List<Device> _devices = [];
  List<AlertNotification> _notifications = [];
  List<FenceData> _fences = [];

  @override
  void initState() {
    _future = _setup();

    super.initState();
  }

  Future<void> _setup() async {
    await _loadDevices();
  }

  Future<void> _loadDevices() async {
    getUserDevicesWithData().then((allDevices) {
      setState(() {
        _devices.addAll(allDevices);
      });
    });
  }

  Future<void> _loadAlerts() async {
    getUserNotifications().then((allNotifications) {
      setState(() {
        _notifications.addAll(allNotifications);
      });
    });
  }

  Future<void> _loadFences() async {
    getUserFences().then((allFences) {
      setState(() {
        _fences.addAll(allFences);
      });
    });
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
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                localizations.devices.capitalize(),
                                style: theme.textTheme.headlineMedium,
                              ),
                            ),
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ListView.builder(
                                      itemCount: _devices.length,
                                      itemBuilder: (context, index) =>
                                          DeviceItem(device: _devices[index]),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  localizations.warnings.capitalize(),
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _notifications.isEmpty
                                        ? Center(
                                            child: Text(localizations.no_alerts.capitalize()),
                                          )
                                        : ListView.builder(
                                            itemCount: _notifications.length,
                                            itemBuilder: (context, index) => AlertItem(
                                              alertNotification: _notifications[index],
                                              onRemove: () async {
                                                await removeNotification(
                                                  _notifications[index].alertNotificationId,
                                                ).then(
                                                  (_) async => await _loadAlerts(),
                                                );
                                              },
                                            ),
                                          ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: DevicesLocationsMap(
                        showCurrentPosition: true,
                        devices: _devices,
                        fences: _fences,
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
