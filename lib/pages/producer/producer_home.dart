import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/maps/devices_locations_map.dart';
import 'package:guardian/widgets/square_devices_info.dart';
import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';
import 'package:latlong2/latlong.dart';

class ProducerHome extends StatefulWidget {
  const ProducerHome({super.key});

  @override
  State<ProducerHome> createState() => _ProducerHomeState();
}

class _ProducerHomeState extends State<ProducerHome> {
  Position? _currentPosition;
  List<Device> devices = [];

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    _loadDevices();
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await handleLocationPermission(context);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _loadDevices() async {
    loadUserDevices(1).then((allDevices) => setState(() => devices.addAll(allDevices)));
  }

  List<LatLng> fencePoints = [
    LatLng(41.83441, -8.420382),
    LatLng(41.834345, -8.419684),
    LatLng(41.834146, -8.419552),
    LatLng(41.833845, -8.419567),
    LatLng(41.833193, -8.419692),
    LatLng(41.832051, -8.420436),
    LatLng(41.832422, -8.421278),
    LatLng(41.833453, -8.420611)
  ];

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: _currentPosition == null
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    delegate: SliverMainAppBar(
                      imageUrl: '',
                      name: 'João Gonçalves',
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
                          const PopupMenuItem(
                            value: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Perfil'),
                                Icon(
                                  Icons.person,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Sair'),
                                Icon(
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
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 20, right: 8),
                                child: SquareDevicesInfo(
                                  title: 'Dispositivos',
                                  description: '10',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: 20, left: 8),
                                child: SquareDevicesInfo(
                                  title: 'Alertas',
                                  description: '2',
                                  isAlert: true,
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
                                  Navigator.of(context).pushNamed('/producer/geofencing');
                                },
                                child: const Text('Cerca'),
                              ),
                            ],
                          ),
                        )
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
                          currentPosition: _currentPosition!,
                          devices: devices,
                          fencePoints: fencePoints,
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
