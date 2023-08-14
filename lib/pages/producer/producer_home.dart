import 'package:flutter/material.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/maps/devices_locations_map.dart';
import 'package:guardian/widgets/square_devices_info.dart';
import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';

class ProducerHome extends StatefulWidget {
  const ProducerHome({super.key});

  @override
  State<ProducerHome> createState() => _ProducerHomeState();
}

class _ProducerHomeState extends State<ProducerHome> {
  List<Device> devices = [];
  List<Fence> fences = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _loadFences();
  }

  Future<void> _loadDevices() async {
    loadUserDevices(1).then((allDevices) => setState(() => devices.addAll(allDevices)));
  }

  Future<void> _loadFences() async {
    loadUserFences(1).then((allFences) => setState(() => fences.addAll(allFences)));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 8),
                          child: SquareDevicesInfo(
                            title: 'Dispositivos',
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
                            title: 'Alertas',
                            description: '2',
                            isAlert: true,
                            onTap: () {},
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
                          child: const Text('Cercas'),
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
