import 'package:flutter/material.dart';
import 'package:guardian/db/user_operations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/data_models/user.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/maps/devices_locations_map.dart';
import 'package:guardian/widgets/square_devices_info.dart';
import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProducerHome extends StatefulWidget {
  const ProducerHome({super.key});

  @override
  State<ProducerHome> createState() => _ProducerHomeState();
}

class _ProducerHomeState extends State<ProducerHome> {
  List<Device> devices = [];
  List<Fence> fences = [];
  late String uid;
  late User user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUid(context).then((userId) {
      if (userId != null) {
        uid = userId;
        getUser(uid).then((userData) {
          if (userData != null) {
            user = userData;
            return _loadDevices(uid).then(
              (_) => _loadFences(uid).then(
                (_) => isLoading = false,
              ),
            );
          }
        });
      }
    });
  }

  Future<void> _loadDevices(String uid) async {
    loadUserDevices(uid).then((allDevices) => setState(() => devices.addAll(allDevices)));
  }

  Future<void> _loadFences(String uid) async {
    loadUserFences(uid).then((allFences) => setState(() => fences.addAll(allFences)));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              delegate: SliverMainAppBar(
                imageUrl: '',
                name: user.name,
                isHomeShape: true,
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
                            description: '10',
                            onTap: () {
                              Navigator.of(context).pushNamed('/producer/devices');
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, left: 8),
                          child: SquareDevicesInfo(
                            title: localizations.alerts.capitalize(),
                            description: '2',
                            isAlert: true,
                            onTap: () {
                              Navigator.of(context).pushNamed('/producer/alerts');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/producer/fences');
                          },
                          child: Text(localizations.fences.capitalize()),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 20.0),
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
