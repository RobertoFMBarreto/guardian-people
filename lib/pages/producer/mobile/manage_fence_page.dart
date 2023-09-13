import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_operations.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/operations/fence_points_operations.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/hex_color.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/widgets/ui/device/device_item_removable.dart';
import 'package:guardian/widgets/ui/maps/devices_locations_map.dart';
import 'package:latlong2/latlong.dart';

class ManageFencePage extends StatefulWidget {
  final FenceData fence;

  const ManageFencePage({
    super.key,
    required this.fence,
  });

  @override
  State<ManageFencePage> createState() => _ManageFencePageState();
}

class _ManageFencePageState extends State<ManageFencePage> {
  List<Device> devices = [];
  // color picker values
  Color fenceColor = gdMapGeofenceFillColor;
  String fenceHexColor = '';
  List<LatLng> points = [];

  late FenceData fence;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fence = widget.fence;
    fenceColor = HexColor(fence.color);
    fenceHexColor = fence.color;
    _loadDevices();
    _reloadFence();
  }

  Future<void> _loadFencePoints() async {
    await getFencePoints(fence.fenceId).then((fencePoints) {
      setState(() {
        points = [];
        points.addAll(fencePoints);
      });
    });
  }

  Future<void> _loadDevices() async {
    await getFenceDevices(fence.fenceId).then(
      (allDevices) => setState(() {
        devices.addAll(allDevices);
        isLoading = false;
      }),
    );
  }

  Future<void> _reloadFence() async {
    await getFence(widget.fence.fenceId).then((newFence) {
      setState(() => fence = newFence);
    });
    _loadFencePoints();
  }

  Future<void> _selectDevices() async {
    Navigator.push(
      context,
      CustomPageRouter(
          page: '/producer/devices',
          settings: RouteSettings(
            arguments: {
              'isSelect': true,
              'fenceId': fence.fenceId,
            },
          )),
    ).then((selectedDevices) async {
      if (selectedDevices != null && selectedDevices.runtimeType == List<Device>) {
        final selected = selectedDevices as List<Device>;
        setState(() {
          devices.addAll(selected);
        });
        for (var device in selected) {
          await createFenceDevice(
            FenceDevicesCompanion(
              fenceId: drift.Value(fence.fenceId),
              deviceId: device.device.deviceId,
            ),
          );
        }
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
                if (hasConnection)
                  TextButton(
                    onPressed: () {
                      // TODO call service to delete fence
                      removeFence(fence.toCompanion(true)).then((_) => Navigator.of(context).pop());
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
                  if (hasConnection)
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
                        if (hasConnection)
                          IconButton(
                            onPressed: () async {
                              _selectDevices();
                            },
                            icon: const Icon(Icons.add),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: devices.isEmpty
                        ? Center(
                            child: Text(localizations.no_selected_devices.capitalize()),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: ListView.builder(
                              itemCount: devices.length,
                              itemBuilder: (context, index) => DeviceItemRemovable(
                                key: Key(devices[index].device.deviceId.value),
                                device: devices[index],
                                onRemoveDevice: () {
                                  // TODO: On remove device
                                  removeDeviceFence(
                                          fence.fenceId, devices[index].device.deviceId.value)
                                      .then(
                                    (_) {
                                      setState(() {
                                        devices.removeWhere(
                                          (element) =>
                                              element.device.deviceId ==
                                              devices[index].device.deviceId,
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
