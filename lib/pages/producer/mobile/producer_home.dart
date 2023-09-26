import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/parsers/animals_parsers.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/alert_notification.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/db/drift/operations/alert_notifications_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/producer_helper.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/settings/settings.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';
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

  List<Animal> _animals = [];
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
    await getUserAnimalsWithData().then((allAnimals) {
      _animals = [];
      setState(() {
        _animals.addAll(allAnimals);
      });
      _getDevicesFromApi();
    });
  }

  Future<void> _getDevicesFromApi() async {
    AnimalProvider.getAnimals().then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        await animalsFromJson(response.body);
        getUserAnimalsWithData().then((allDevices) {
          if (mounted) {
            setState(() {
              _animals = [];
              _animals.addAll(allDevices);
            });
          }
        });
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken);
            _getDevicesFromApi();
          } else if (response.statusCode == 507) {
            hasShownNoServerConnection().then((hasShown) async {
              if (!hasShown) {
                setShownNoServerConnection(true).then(
                  (_) => showDialog(
                      context: context, builder: (context) => const ServerErrorDialogue()),
                );
              }
            });
          } else {
            clearUserSession().then((_) => deleteEverything().then(
                  (_) => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (Route<dynamic> route) => false),
                ));
          }
        });
      } else if (response.statusCode == 507) {
        hasShownNoServerConnection().then((hasShown) async {
          if (!hasShown) {
            setShownNoServerConnection(true).then(
              (_) =>
                  showDialog(context: context, builder: (context) => const ServerErrorDialogue()),
            );
          }
        });
      }
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
    await getAllNotifications().then((allAlerts) {
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
                    maxHeight: MediaQuery.of(context).size.height * gdTopBarHeightRatio,
                    title: Padding(
                      padding: const EdgeInsets.only(right: 20.0, bottom: 5, top: 5),
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
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(localizations.fences.capitalize())),
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
                                description: '${_animals.length}',
                                onTap: () {
                                  Future.delayed(const Duration(milliseconds: 300)).then(
                                    (value) => Navigator.push(
                                      context,
                                      CustomPageRouter(page: '/producer/devices'),
                                    ).then(
                                      (_) => _loadDevices(),
                                    ),
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
                                  Future.delayed(const Duration(milliseconds: 300)).then(
                                    (value) => Navigator.push(
                                      context,
                                      CustomPageRouter(page: '/producer/alerts'),
                                    ).then(
                                      (_) => _loadAlertNotifications(),
                                    ),
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
                        animals: _animals,
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
