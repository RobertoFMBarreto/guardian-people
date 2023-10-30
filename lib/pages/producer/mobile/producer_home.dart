import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/helpers/db_helpers.dart';
import 'package:guardian/models/providers/api/animals_provider.dart';
import 'package:guardian/models/providers/api/auth_provider.dart';
import 'package:guardian/models/providers/api/notifications_provider.dart';
import 'package:guardian/models/providers/api/parsers/animals_parsers.dart';
import 'package:guardian/models/providers/api/parsers/notifications_parsers.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/query_models/alert_notification.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/db/drift/operations/alert_notifications_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/producer_helper.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/settings/settings.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/dialogues/server_error_dialogue.dart';
import 'package:guardian/widgets/ui/dropdown/home_dropdown.dart';
import 'package:guardian/widgets/ui/animal/square_animals_info.dart';
import 'package:guardian/widgets/ui/topbars/main_topbar/sliver_main_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';

/// Class that represents the producer home
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

  /// Method that doest the initial setup
  ///
  /// 1. load user data
  /// 2. load user animals
  /// 3. load fences
  /// 4. load alert notifications
  Future<void> _setup() async {
    await _loadUserData();
    await _loadAnimals();
    await _loadFences();
    await _loadAlertNotifications();
  }

  /// Method that loads the user data into [_user]
  Future<void> _loadUserData() async {
    await getSessionUserData().then((data) {
      if (data != null) {
        _user = data;
      }
    });
  }

  /// Method that loads the animals into the [_animals] list
  ///
  /// 1. load local animals
  /// 2. add to list
  /// 3. load api animals
  Future<void> _loadAnimals() async {
    await getUserAnimalsWithLastLocation().then((allAnimals) {
      _animals = [];
      setState(() {
        _animals.addAll(allAnimals);
      });
      AnimalRequests.getAnimalsFromApiWithLastLocation(
          context: context,
          onDataGotten: () {
            getUserAnimalsWithLastLocation().then((allDevices) {
              if (mounted) {
                setState(() {
                  _animals = [];
                  _animals.addAll(allDevices);
                });
              }
            });
          });
    });
  }

  /// Method that loads all fences into the [_fences] list
  ///
  /// In the process updates the [_reloadMap] variable so that the map reloads
  ///
  /// Resets the list to avoid duplicates
  Future<void> _loadFences() async {
    await getUserFences().then((allFences) {
      _fences = [];
      setState(() {
        _fences.addAll(allFences);
        _reloadMap = Random().nextInt(999999);
      });
    });
  }

  /// Method that loads all alert notifications into the [_alertNotifications] list
  ///
  /// Resets the list to avoid duplicates
  Future<void> _loadAlertNotifications() async {
    await getAllNotifications().then((allAlerts) {
      _alertNotifications = [];
      setState(() => _alertNotifications.addAll(allAlerts));
      _getNotificationsFromApi();
    });
  }

  Future<void> _getNotificationsFromApi() async {
    NotificationsProvider.getNotifications().then((response) async {
      if (response.statusCode == 200) {
        setShownNoServerConnection(false);
        parseNotifications(response.body);
        await getAllNotifications().then((allAlerts) {
          _alertNotifications = [];
          setState(() => _alertNotifications.addAll(allAlerts));
        });
      } else if (response.statusCode == 401) {
        AuthProvider.refreshToken().then((resp) async {
          if (resp.statusCode == 200) {
            setShownNoServerConnection(false);
            final newToken = jsonDecode(resp.body)['token'];
            await setSessionToken(newToken);
            _getNotificationsFromApi();
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
                                child: Text(localizations.fences.capitalize!)),
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
                              child: SquareAnimalsInfo(
                                title: localizations.devices.capitalize!,
                                description: '${_animals.length}',
                                onTap: () {
                                  Future.delayed(const Duration(milliseconds: 300)).then(
                                    (value) => Navigator.push(
                                      context,
                                      CustomPageRouter(page: '/producer/devices'),
                                    ).then(
                                      (_) => _loadAnimals(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20, left: 8),
                              child: SquareAnimalsInfo(
                                title: localizations.alerts.capitalize!,
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
                      child: AnimalsLocationsMap(
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
