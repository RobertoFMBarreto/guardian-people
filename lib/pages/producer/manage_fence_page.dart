import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/device_item.dart';
import 'package:guardian/widgets/maps/devices_locations_map.dart';

class ManageFencePage extends StatefulWidget {
  final Fence fence;
  const ManageFencePage({super.key, required this.fence});

  @override
  State<ManageFencePage> createState() => _ManageFencePageState();
}

class _ManageFencePageState extends State<ManageFencePage> {
  Position? _currentPosition;
  List<Device> devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices().then((value) => _getCurrentPosition());
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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cerca ${widget.fence.name}',
          style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _currentPosition == null
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: DevicesLocationsMap(
                          currentPosition: _currentPosition!,
                          devices: devices,
                          centerOnPoly: true,
                          fences: [widget.fence],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dispositivos Associados:',
                          style: theme.textTheme.bodyLarge,
                        ),
                        IconButton(
                          onPressed: () {
                            //!TODO: search and select devices
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      //!TODO: get devices from fence data
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          child: DeviceItem(
                            deviceImei: devices[index].imei,
                            deviceData: devices[index].data.first.dataUsage,
                            deviceBattery: devices[index].data.first.battery,
                            isRemoveMode: true,
                            onRemoveDevice: () {
                              //!TODO: On remove device
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'Remover Cerca',
            extendedPadding: const EdgeInsets.symmetric(horizontal: 10),
            icon: const Icon(Icons.delete_forever),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            onPressed: () {
              //!TODO: Remove Fence
            },
            label: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Remover Cerca',
                style: theme.textTheme.bodyMedium!.copyWith(color: Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: FloatingActionButton.extended(
              heroTag: 'Editar Cerca',
              extendedPadding: const EdgeInsets.symmetric(horizontal: 10),
              icon: const Icon(Icons.edit),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/producer/geofencing', arguments: widget.fence);
              },
              label: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  'Editar Cerca',
                  style: theme.textTheme.bodyMedium!.copyWith(color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}