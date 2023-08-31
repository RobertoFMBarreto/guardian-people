import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/db/fence_devices_operations.dart';
import 'package:guardian/db/fence_operations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/data_models/Fences/fence_devices.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/session_provider.dart';

import 'package:guardian/widgets/device/device_item_removable.dart';
import 'package:guardian/widgets/maps/devices_locations_map.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';

class ManageFencePage extends StatefulWidget {
  final Fence fence;

  final bool hasConnection;
  const ManageFencePage({super.key, required this.fence, required this.hasConnection});

  @override
  State<ManageFencePage> createState() => _ManageFencePageState();
}

class _ManageFencePageState extends State<ManageFencePage> {
  List<Device> devices = [];
  // color picker values
  Color fenceColor = gdMapGeofenceFillColor;
  String fenceHexColor = '';
  List<LatLng> points = [];

  late Fence fence;

  late String uid;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fence = widget.fence;
    fenceColor = HexColor(fence.color);
    fenceHexColor = fence.color;
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    getUid(context).then((userId) {
      if (userId != null) {
        uid = userId;
        getFenceDevices(fence.fenceId).then(
          (allDevices) => setState(() {
            devices.addAll(allDevices);
            isLoading = false;
          }),
        );
      }
    });
  }

  Future<void> _reloadFence() async {
    getFence(widget.fence.fenceId).then((newFence) {
      if (newFence != null) {
        setState(() => fence = newFence);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: !isLoading
          ? AppBar(
              title: Text(
                '${localizations.fence.capitalize()} ${fence.name}',
                style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
              ),
              centerTitle: true,
              actions: [
                if (widget.hasConnection)
                  TextButton(
                    onPressed: () {
                      //!TODO call service to delete fence
                      removeFence(fence).then((_) => Navigator.of(context).pop());
                    },
                    child: Text(
                      localizations.remove.capitalize(),
                      style: theme.textTheme.bodyLarge!
                          .copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.w500),
                    ),
                  )
              ],
            )
          : null,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            )
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: DevicesLocationsMap(
                              key: Key('${fence.color}$points'),
                              showCurrentPosition: true,
                              devices: devices,
                              centerOnPoly: true,
                              fences: [fence],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.hasConnection)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed('/producer/geofencing', arguments: fence)
                              .then(
                            (newPoints) {
                              if (newPoints != null && newPoints.runtimeType == List<LatLng>) {
                                setState(() {
                                  points = newPoints as List<LatLng>;
                                });
                                _reloadFence();
                              }
                            },
                          );
                        },
                        child: Text('${localizations.edit.capitalize()} ${localizations.fence}'),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${localizations.associated_devices.capitalize()}:',
                          style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (widget.hasConnection)
                          IconButton(
                            onPressed: () async {
                              Navigator.of(context).pushNamed(
                                '/producer/devices',
                                arguments: {
                                  'isSelect': true,
                                  'fenceId': fence.fenceId,
                                },
                              ).then((selectedDevices) async {
                                if (selectedDevices != null &&
                                    selectedDevices.runtimeType == List<Device>) {
                                  final selected = selectedDevices as List<Device>;
                                  setState(() {
                                    devices.addAll(selected);
                                  });
                                  for (var device in selected) {
                                    await createFenceDevice(
                                      FenceDevices(
                                        fenceId: fence.fenceId,
                                        deviceId: device.deviceId,
                                      ),
                                    );
                                  }
                                }
                              });
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
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) => DeviceItemRemovable(
                          key: Key(devices[index].deviceId),
                          device: devices[index],
                          hasConnection: widget.hasConnection,
                          onRemoveDevice: () {
                            //!TODO: On remove device
                            removeDeviceFence(fence.fenceId, devices[index].deviceId).then(
                              (_) {
                                setState(() {
                                  devices.removeWhere(
                                    (element) => element.deviceId == devices[index].deviceId,
                                  );
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
