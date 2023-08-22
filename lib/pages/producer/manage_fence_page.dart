import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/db/device_operations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/models/providers/session_provider.dart';
import 'package:guardian/widgets/color_circle.dart';
import 'package:guardian/widgets/device/device_item_removable.dart';
import 'package:guardian/widgets/inputs/color_picker_input.dart';
import 'package:guardian/widgets/maps/devices_locations_map.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ManageFencePage extends StatefulWidget {
  final Fence fence;
  const ManageFencePage({super.key, required this.fence});

  @override
  State<ManageFencePage> createState() => _ManageFencePageState();
}

class _ManageFencePageState extends State<ManageFencePage> {
  List<Device> devices = [];
  // color picker values
  Color fenceColor = gdMapGeofenceFillColor;
  String fenceHexColor = '';

  late String uid;

  @override
  void initState() {
    super.initState();
    fenceColor = HexColor(widget.fence.color);
    fenceHexColor = widget.fence.color;
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    getUid(context).then((userId) {
      if (userId != null) {
        uid = userId;
        getUserDevicesWithData(uid).then(
          (allDevices) => setState(() => devices.addAll(allDevices)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${localizations.fence.capitalize()} ${widget.fence.name}',
          style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: DevicesLocationsMap(
                    key: Key(widget.fence.color),
                    showCurrentPosition: true,
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
                      localizations.fence_color.capitalize(),
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
                    '${localizations.associated_devices.capitalize()}:',
                    style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () async {
                      //!TODO: search and select devices
                      final selectedDevices = await Navigator.of(context)
                          .pushNamed('/producer/devices', arguments: true);
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
                      deviceData: devices[index].data!.first.dataUsage,
                      deviceBattery: devices[index].data!.first.battery,
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
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        distance: 80,
        children: [
          FloatingActionButton.extended(
            heroTag: '${localizations.remove.capitalize()} ${localizations.fence}',
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
                '${localizations.remove.capitalize()} ${localizations.fence}',
                style: theme.textTheme.bodyMedium!.copyWith(color: Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: FloatingActionButton.extended(
              heroTag: '${localizations.edit.capitalize()} ${localizations.fence}',
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
                  '${localizations.edit.capitalize()} ${localizations.fence}',
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
