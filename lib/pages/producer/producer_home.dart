import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/square_devices_info.dart';
import 'package:guardian/widgets/topbars/main_topbar/sliver_main_app_bar.dart';
import 'package:latlong2/latlong.dart';

class ProducerHome extends StatelessWidget {
  const ProducerHome({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FlutterMap(
                    options: MapOptions(center: LatLng(51.5, -0.09), zoom: 10, minZoom: 3),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.linovt.guardian',
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            color: Color.fromRGBO(167, 90, 90, 0.498),
                            borderColor: Color.fromRGBO(255, 0, 0, 1),
                            borderStrokeWidth: 2,
                            point: LatLng(41.694569, -8.830160),
                            radius: 1000,
                            useRadiusInMeter: true,
                          ),
                        ],
                      ),
                    ],
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
