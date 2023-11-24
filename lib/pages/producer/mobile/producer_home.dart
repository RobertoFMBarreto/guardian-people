import 'dart:async';
import 'dart:math';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/providers/api/requests/alerts_requests.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/models/providers/api/requests/fencing_requests.dart';
import 'package:guardian/models/providers/api/requests/notifications_requests.dart';
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
  List<UserAlertCompanion> _alerts = [];
  bool _firstRun = true;

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
    isSnackbarActive = false;
    await _loadUserData();
    await _loadAnimals();
    await _loadFences();
    await _loadAlertNotifications();
    await _loadAlerts();
    FirebaseMessaging.onMessage.listen((event) {
      _loadAlertNotifications();
    });
  }

  /// Method that loads the user alerts into the [_alerts] list
  ///
  /// If is in select mode ( [widget.isSelect]=`true`) then only the unselected alerts will be shown
  ///
  /// If it isnt in select mode then all user alerts will be shown
  ///
  /// Resets the list to prevent duplicates
  Future<void> _loadAlerts() async {
    await _getLocalUserAlerts().then(
      (value) => AlertRequests.getUserAlertsFromApi(
        context: context,
        onDataGotten: (data) {
          _getLocalUserAlerts();
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
      ),
    );
  }

  /// Method that allows to get all local user alerts
  Future<void> _getLocalUserAlerts() async {
    await getUserAlerts().then(
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
    await getUserAnimalsWithLastLocation().then((allAnimals) async {
      _animals = [];
      setState(() {
        _animals.addAll(allAnimals);
      });

      await AnimalRequests.getAnimalsFromApiWithLastLocation(
          context: context,
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
          onDataGotten: () async {
            await getUserAnimalsWithLastLocation().then((allDevices) {
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
    await _loadLocalFences().then((_) {
      FencingRequests.getUserFences(
        context: context,
        onGottenData: (_) async {
          await _loadLocalFences();
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
    });
  }

  /// Method that allows to get local fences
  Future<void> _loadLocalFences() async {
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
    _loadLocalAlertNotifications().then((_) => _getNotificationsFromApi());
  }

  /// Method that loads all alert notifications into the [_alertNotifications] list
  ///
  /// Resets the list to avoid duplicates
  Future<void> _loadLocalAlertNotifications() async {
    await getAllNotifications().then((allAlerts) {
      _alertNotifications = [];
      setState(() => _alertNotifications.addAll(allAlerts));
    });
  }

  /// Method that loads all notifications from api
  Future<void> _getNotificationsFromApi() async {
    NotificationsRequests.getUserNotificationsFromApi(
      context: context,
      onDataGotten: (data) {
        _loadLocalAlertNotifications();
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
                  key: Key(_alertNotifications.length.toString()),
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
                              backgroundColor: const MaterialStatePropertyAll(gdErrorColor),
                            ),
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
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(localizations.warnings_managment.capitalizeFirst!)),
                          ),
                        ],
                      ),
                    ),
                    tailWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _alertNotifications.isNotEmpty
                            ? badges.Badge(
                                position: badges.BadgePosition.bottomEnd(bottom: -10, end: -12),
                                showBadge: _alertNotifications.isNotEmpty,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CustomPageRouter(page: '/producer/alerts'),
                                  ).then(
                                    (_) => _loadAlertNotifications(),
                                  );
                                },
                                badgeContent: Text(
                                  _alertNotifications.length <= 9
                                      ? _alertNotifications.length.toString()
                                      : '+9',
                                  style: _alertNotifications.length <= 9
                                      ? theme.textTheme.bodyMedium!.copyWith(
                                          color: Colors.white, fontWeight: FontWeight.bold)
                                      : theme.textTheme.bodySmall!.copyWith(
                                          color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                badgeAnimation: const badges.BadgeAnimation.scale(
                                  animationDuration: Duration(seconds: 1),
                                  colorChangeAnimationDuration: Duration(seconds: 1),
                                  loopAnimation: false,
                                  curve: Curves.fastOutSlowIn,
                                  colorChangeAnimationCurve: Curves.easeInCubic,
                                ),
                                badgeStyle: const badges.BadgeStyle(
                                  shape: badges.BadgeShape.circle,
                                  badgeColor: Colors.red,
                                  padding: EdgeInsets.all(5),
                                  elevation: 0,
                                ),
                                child: const Icon(Icons.notifications_outlined),
                              )
                            : IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CustomPageRouter(page: '/producer/alerts'),
                                  ).then(
                                    (_) => _loadAlertNotifications(),
                                  );
                                },
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                              ),
                        const HomeDropDown(),
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
                              child: SquareAnimalsInfo(
                                title: localizations.devices.capitalizeFirst!,
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
                                title: localizations.manage_fences.capitalizeFirst!,
                                description: '${_fences.length}',
                                isFencing: true,
                                onTap: () {
                                  Future.delayed(const Duration(milliseconds: 300)).then((value) {
                                    Navigator.push(
                                      context,
                                      CustomPageRouter(
                                        page: '/producer/fences',
                                      ),
                                    ).then(
                                      (_) => _loadFences(),
                                    );
                                  });
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
