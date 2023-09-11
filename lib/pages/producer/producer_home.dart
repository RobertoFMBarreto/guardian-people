import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/alert_notification.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/db/drift/operations/alert_notifications_operations.dart';
import 'package:guardian/models/db/drift/operations/device_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/producer_helper.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/dropdown/home_dropdown.dart';
import 'package:guardian/widgets/ui/device/square_devices_info.dart';
import 'package:guardian/widgets/ui/topbars/main_topbar/sliver_main_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';

class ProducerHome extends StatefulWidget {
  const ProducerHome({
    super.key,
  });

  @override
  State<ProducerHome> createState() => _ProducerHomeState();
}

class _ProducerHomeState extends State<ProducerHome> {
  late UserData _user;
  late Future<void> _loadData;

  List<Device> _devices = [];
  List<FenceData> _fences = [];
  List<AlertNotification> _alertNotifications = [];

  int _reloadMap = 9999;

  @override
  void initState() {
    super.initState();

    _loadData = _setup();
  }

  Future<void> _setup() async {
    await _loadUserData();
    await _loadDevices();
    await _loadFences();
    await _loadAlertNotifications();
  }

  Future<void> _loadUserData() async {
    await getSessionUserData().then((data) {
      if (data != null) {
        _user = data;
      }
    });
  }

  Future<void> _loadDevices() async {
    await getUserDevicesWithData().then((allDevices) {
      _devices = [];
      setState(() => _devices.addAll(allDevices));
    });
  }

  Future<void> _loadFences() async {
    await getUserFences().then((allFences) {
      _fences = [];
      setState(() {
        _fences.addAll(allFences);
        _reloadMap = Random().nextInt(999999);
      });
    });
  }

  Future<void> _loadAlertNotifications() async {
    await getUserNotifications().then((allAlerts) {
      _alertNotifications = [];
      setState(() => _alertNotifications.addAll(allAlerts));
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).brightness == Brightness.light ? gdGradientEnd : gdDarkGradientEnd,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SafeArea(
          child: FutureBuilder(
        future: _loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomCircularProgressIndicator();
          } else {
            return CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  delegate: SliverMainAppBar(
                    imageUrl: '',
                    name: _user.name,
                    isHomeShape: true,
                    title: Padding(
                      padding: const EdgeInsets.only(right: 20.0, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: theme.elevatedButtonTheme.style!.copyWith(
                              overlayColor: MaterialStatePropertyAll(
                                Colors.white.withOpacity(0.2),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                CustomPageRouter(page: '/producer/fences'),
                              ).then(
                                (_) => _loadFences(),
                              );
                            },
                            child: Text(localizations.fences.capitalize()),
                          ),
                        ],
                      ),
                    ),
                    tailWidget: const HomeDropDown(),
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
                                description: '${_devices.length}',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CustomPageRouter(page: '/producer/devices'),
                                  ).then(
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
                                description: '${_alertNotifications.length}',
                                isAlert: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CustomPageRouter(page: '/producer/alerts'),
                                  ).then(
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
                        key: Key(_reloadMap.toString()),
                        showCurrentPosition: true,
                        devices: _devices,
                        fences: _fences,
                        reloadMap: _reloadMap.toString(),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
        },
      )),
    );
  }
}
