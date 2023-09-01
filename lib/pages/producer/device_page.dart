import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';

import 'package:guardian/widgets/pages/producer/device_page/device_map_widget.dart';
import 'package:guardian/widgets/topbars/device_topbar/sliver_device_app_bar.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DevicePage extends StatefulWidget {
  final Device device;

  const DevicePage({
    super.key,
    required this.device,
  });

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  bool _isInterval = false;
  late Device _device;
  int _reloadNum = 0;

  @override
  void initState() {
    _device = widget.device;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(147, 215, 166, 1),
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/producer/device/history', arguments: widget.device);
        },
        backgroundColor: theme.colorScheme.secondary,
        label: Text(
          localizations.state_history.capitalize(),
          style: theme.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              key: Key("${_device.name}$hasConnection"),
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
                        initialLabelIndex: _isInterval ? 1 : 0,
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
                            _isInterval = index == 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                device: _device,
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
                tailWidget: hasConnection
                    ? IconButton(
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
                            arguments: _device,
                          )
                              .then((newDevice) {
                            if (newDevice != null && newDevice.runtimeType == Device) {
                              setState(() => _device = (newDevice as Device));
                            } else {
                              // Force reload map
                              setState(() {
                                _reloadNum = Random().nextInt(999999);
                              });
                            }
                          });
                        },
                      )
                    : null,
              ),
            ),
            SliverFillRemaining(
              child: DeviceMapWidget(
                key: Key(_reloadNum.toString()),
                device: _device,
                isInterval: _isInterval,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
