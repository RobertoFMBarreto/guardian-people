import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/db/alert_devices_operations.dart';
import 'package:guardian/db/device_operations.dart';
import 'package:guardian/db/fence_devices_operations.dart';
import 'package:guardian/models/data_models/Alerts/alert_devices.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/data_models/Fences/fence.dart';
import 'package:guardian/models/data_models/Fences/fence_devices.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/focus_manager.dart';
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
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    deviceName = widget.device.name;
    _getDeviceAlerts().then(
      (_) => _getDeviceFences(),
    );
    controller.text = widget.device.name;
    super.initState();
  }

  Future<void> _getDeviceAlerts() async {
    getDeviceAlerts(widget.device.deviceId).then((allAlerts) {
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
    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Scaffold(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    label: Text(localizations.name.capitalize()),
                  ),
                  onChanged: (value) {
                    setState(() {
                      deviceName = value;
                    });
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
                            for (var selectedAlert in selectedAlerts) {
                              await addAlertDevice(
                                AlertDevices(
                                    deviceId: widget.device.deviceId,
                                    alertId: selectedAlert.alertId),
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
                      Navigator.of(context)
                          .pushNamed('/producer/fences', arguments: true)
                          .then((newFenceData) {
                        if (newFenceData != null && newFenceData.runtimeType == Fence) {
                          final newFence = newFenceData as Fence;
                          setState(() {
                            fences.add(newFence);
                          });
                          createFenceDevice(
                            FenceDevices(
                              fenceId: newFence.fenceId,
                              deviceId: widget.device.deviceId,
                            ),
                          );
                        }
                      });
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
                          removeDeviceFence(fences[index].fenceId, widget.device.deviceId);
                          setState(() {
                            fences.removeWhere(
                              (element) => element.fenceId == fences[index].fenceId,
                            );
                          });
                          //!TODO remove item service call
                        },
                      ),
                    ),
                  ),
                ),
                if (widget.device.name != deviceName)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              deviceName = widget.device.name;
                              controller.text = deviceName;
                            });
                          },
                          style: theme.elevatedButtonTheme.style!.copyWith(
                            backgroundColor: const MaterialStatePropertyAll(gdCancelBtnColor),
                          ),
                          child: Text(
                            localizations.cancel.capitalize(),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final newDevice = widget.device.copy(name: deviceName);
                          updateDevice(newDevice)
                              .then((value) => Navigator.of(context).pop(newDevice));
                        },
                        child: Text(
                          localizations.confirm.capitalize(),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
