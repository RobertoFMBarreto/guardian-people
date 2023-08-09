import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/fence.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/location_provider.dart';
import 'package:guardian/models/providers/read_json.dart';
import 'package:guardian/widgets/color_circle.dart';
import 'package:guardian/widgets/device/device_item_removable.dart';
import 'package:guardian/widgets/inputs/color_picker_input.dart';
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
  // color picker values
  Color fenceColor = gdMapGeofenceFillColor;
  String fenceHexColor = '';
  @override
  void initState() {
    super.initState();
    fenceColor = HexColor(widget.fence.color);
    fenceHexColor = widget.fence.color;
    _loadDevices().then((value) => _getCurrentPosition());
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await handleLocationPermission(context);

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition().then((Position position) {
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
                          key: Key(widget.fence.color),
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            'Cor da cerca:',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => CustomColorPickerInput(
                                pickerColor: fenceColor,
                                onSave: (color) {
                                  setState(() {
                                    fenceColor = color;
                                    widget.fence.color = HexColor.toHex(color: fenceColor);
                                  });
                                },
                                hexColor: HexColor.toHex(color: fenceColor),
                              ),
                            );
                          },
                          child: ColorCircle(color: fenceColor),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dispositivos Associados:',
                          style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            //!TODO: search and select devices
                            Navigator.of(context).pushNamed('/producer/devices', arguments: true);
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
                          child: DeviceItemRemovable(
                            deviceImei: devices[index].imei,
                            deviceData: devices[index].data.first.dataUsage,
                            deviceBattery: devices[index].data.first.battery,
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
