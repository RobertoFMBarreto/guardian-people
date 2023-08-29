import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/db/device_operations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/widgets/pages/producer/device_page/device_map_widget.dart';
import 'package:guardian/widgets/topbars/device_topbar/sliver_device_app_bar.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DevicePage extends StatefulWidget {
  final Device device;
  const DevicePage({super.key, required this.device});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  bool isInterval = false;
  late Device device;
  int reloadNum = 0;
  @override
  void initState() {
    device = widget.device;

    super.initState();
  }

  Future<void> _reloadDevice() async {
    await getDevice(widget.device.deviceId).then((newDevice) {
      if (newDevice != null) {
        setState(() {
          device = newDevice;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(147, 215, 166, 1),
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              key: Key(device.name),
              pinned: true,
              delegate: SliverDeviceAppBar(
                onColorChanged: () {
                  setState(() {});
                },
                title: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.localization.capitalize(),
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ToggleSwitch(
                        initialLabelIndex: isInterval ? 1 : 0,
                        cornerRadius: 50,
                        radiusStyle: true,
                        activeBgColor: [theme.colorScheme.secondary],
                        activeFgColor: theme.colorScheme.onSecondary,
                        inactiveBgColor: gdToggleGreyArea,
                        inactiveFgColor: Colors.black,
                        customTextStyles: const [
                          TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                          TextStyle(fontSize: 12.0, fontWeight: FontWeight.w900),
                        ],
                        totalSwitches: 2,
                        labels: [
                          localizations.current.capitalize(),
                          localizations.range.capitalize(),
                        ],
                        onToggle: (index) {
                          setState(() {
                            isInterval = index == 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                device: device,
                leadingWidget: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSecondary,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                tailWidget: IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: theme.colorScheme.onSecondary,
                    size: 30,
                  ),
                  onPressed: () {
                    //TODO: Code for settings of device
                    Navigator.of(context)
                        .pushNamed(
                      '/producer/device/settings',
                      arguments: device,
                    )
                        .then((newDevice) {
                      if (newDevice != null && newDevice.runtimeType == Device) {
                        setState(() => device = (newDevice as Device));
                      } else {
                        setState(() {
                          reloadNum = Random().nextInt(999999);
                        });
                      }
                    });
                  },
                ),
              ),
            ),
            SliverFillRemaining(
              child: DeviceMapWidget(
                key: Key(reloadNum.toString()),
                device: device,
                isInterval: isInterval,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
