import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian/db/alert_notifications_operations.dart';
import 'package:guardian/db/device_operations.dart';
import 'package:guardian/db/fence_operations.dart';
import 'package:guardian/db/user_operations.dart';
import 'package:guardian/models/custom_alert_dialogs.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/data_models/user.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/models/providers/system_provider.dart';
import 'package:guardian/models/user_alert_notification.dart';
import 'package:guardian/widgets/maps/devices_locations_map.dart';
import 'package:guardian/widgets/square_devices_info.dart';
import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ProducerHome extends StatefulWidget {
  const ProducerHome({super.key});

  @override
  State<ProducerHome> createState() => _ProducerHomeState();
}

class _ProducerHomeState extends State<ProducerHome> {
  List<Device> devices = [];
  List<Fence> fences = [];
  List<UserAlertNotification> alertNotifications = [];
  late User user;
  bool isLoading = true;
  late StreamSubscription subscription;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
    _loadUserData().then(
      (_) => _loadDevices().then(
        (_) => _loadFences().then(
          (_) => _loadAlertNotifications().then(
            (_) {
              isLoading = false;
            },
          ),
        ),
      ),
    );
  }

  Future<void> _loadUserData() async {
    getUid(context).then((uid) {
      if (uid != null) {
        getUser(uid).then((userData) {
          if (userData != null) {
            setState(() {
              user = userData;
            });
          }
        });
      }
    });
  }

  Future<void> _loadDevices() async {
    await getUserDevicesWithData().then((allDevices) {
      devices = [];
      return setState(() => devices.addAll(allDevices));
    });
  }

  Future<void> _loadFences() async {
    await getUserFences().then(
      (allFences) => setState(
        () {
          fences = [];
          fences.addAll(allFences);
        },
      ),
    );
  }

  Future<void> _loadAlertNotifications() async {
    await getUserNotifications().then(
      (allAlerts) => setState(
        () {
          alertNotifications = [];
          alertNotifications.addAll(allAlerts);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(147, 215, 166, 1),
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    delegate: SliverMainAppBar(
                      imageUrl: '',
                      name: user.name,
                      isHomeShape: true,
                      title: Padding(
                        padding: const EdgeInsets.only(right: 20.0, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed('/producer/fences')
                                    .then((_) => _loadFences());
                              },
                              child: Text(localizations.fences.capitalize()),
                            ),
                          ],
                        ),
                      ),
                      tailWidget: PopupMenuButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: theme.colorScheme.onSecondary,
                        icon: const Icon(Icons.menu),
                        onSelected: (item) {
                          switch (item) {
                            case 0:
                              Navigator.of(context).pushNamed('/profile');
                              break;
                            case 1:
                              //! Logout code
                              clearUserSession().then(
                                (value) => Navigator.of(context).popAndPushNamed('/login'),
                              );

                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(localizations.profile.capitalize()),
                                const Icon(
                                  Icons.person,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(localizations.logout.capitalize()),
                                const Icon(
                                  Icons.logout,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20, right: 8),
                                child: SquareDevicesInfo(
                                  title: localizations.devices.capitalize(),
                                  description: '${devices.length}',
                                  onTap: () {
                                    Navigator.of(context).pushNamed('/producer/devices').then(
                                          (_) => _loadDevices(),
                                        );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20, left: 8),
                                child: SquareDevicesInfo(
                                  title: localizations.alerts.capitalize(),
                                  description: '${alertNotifications.length}',
                                  isAlert: true,
                                  onTap: () {
                                    Navigator.of(context).pushNamed('/producer/alerts').then(
                                          (_) => _loadAlertNotifications(),
                                        );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: DevicesLocationsMap(
                          showCurrentPosition: true,
                          devices: devices,
                          fences: fences,
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
