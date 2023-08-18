import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/widgets/fence_item.dart';
import 'package:guardian/widgets/pages/producer/alerts_management_page/alert_management_item.dart';

class DeviceSettingsPage extends StatefulWidget {
  final Device device;
  const DeviceSettingsPage({super.key, required this.device});

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  String deviceName = '';
  @override
  void initState() {
    deviceName = widget.device.imei;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.device_settings.capitalize(),
          style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 8.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  label: Text(localizations.name.capitalize()),
                ),
                onChanged: (value) {
                  deviceName = value;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: GestureDetector(
                  onTap: () {
                    //TODO: select alerts

                    Navigator.of(context).pushNamed('/producer/alert/management', arguments: true);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.device_warnings.capitalize(),
                        style: theme.textTheme.headlineMedium!.copyWith(fontSize: 22),
                      ),
                      const Icon(Icons.add)
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.device.alerts.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: AlertManagementItem(
                      alert: widget.device.alerts[index],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: GestureDetector(
                  onTap: () {
                    //TODO: select fences
                    Navigator.of(context).pushNamed('/producer/fences', arguments: true);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.device_fences.capitalize(),
                        style: theme.textTheme.headlineMedium!.copyWith(fontSize: 22),
                      ),
                      const Icon(Icons.add)
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.device.alerts.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FenceItem(
                      name: widget.device.fences[index].name,
                      color: HexColor(widget.device.fences[index].color),
                      onRemove: () {
                        //!TODO remove item from list
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
