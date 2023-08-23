import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/db/alert_devices_operations.dart';
import 'package:guardian/db/fence_devices_operations.dart';
import 'package:guardian/models/data_models/Alerts/alert_devices.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
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
  List<UserAlert> alerts = [];
  List<Fence> fences = [];
  @override
  void initState() {
    deviceName = widget.device.imei;
    _getDeviceAlerts().then(
      (_) => _getDeviceFences(),
    );
    super.initState();
  }

  Future<void> _getDeviceAlerts() async {
    getDeviceAlerts(widget.device.deviceId).then((allAlerts) {
      print(allAlerts);
      setState(() => alerts.addAll(allAlerts));
    });
  }

  Future<void> _getDeviceFences() async {
    getDeviceFence(widget.device.deviceId).then((deviceFence) {
      if (deviceFence != null) {
        setState(() => fences.add(deviceFence));
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
                    Navigator.of(context)
                        .pushNamed(
                      '/producer/alert/management',
                      arguments: true,
                    )
                        .then(
                      (gottenAlerts) async {
                        if (gottenAlerts.runtimeType == List<UserAlert>) {
                          final selectedAlerts = gottenAlerts as List<UserAlert>;
                          setState(() {
                            alerts.addAll(selectedAlerts);
                          });

                          print('Gotten: $gottenAlerts');
                          print('Gotten Type: ${gottenAlerts.runtimeType}');
                          for (var selectedAlert in selectedAlerts) {
                            await addAlertDevice(
                              AlertDevices(
                                  deviceId: widget.device.deviceId, alertId: selectedAlert.alertId),
                            );
                          }
                          //!TODO: add service call
                        }
                      },
                    );
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
                  itemCount: alerts.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: AlertManagementItem(
                      alert: alerts[index],
                      onDelete: (alert) {
                        //!TODO: Delete code for alert
                        removeAlertDevice(alert.alertId, widget.device.deviceId);
                        setState(() {
                          alerts.removeWhere(
                            (element) =>
                                element.alertId == alert.alertId &&
                                element.deviceId == widget.device.deviceId,
                          );
                        });
                      },
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
                      //!TODO: se poder ter várias cercas trocar
                      fences.isEmpty ? const Icon(Icons.add) : const SizedBox()
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: fences.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FenceItem(
                      name: fences[index].name,
                      color: HexColor(fences[index].color),
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
