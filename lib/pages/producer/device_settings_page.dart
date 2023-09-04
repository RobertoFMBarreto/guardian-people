import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/db/data_models/Alerts/alert_devices.dart';
import 'package:guardian/models/db/data_models/Alerts/user_alert.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/data_models/Fences/fence.dart';
import 'package:guardian/models/db/data_models/Fences/fence_devices.dart';
import 'package:guardian/models/db/operations/device_operations.dart';
import 'package:guardian/models/db/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/operations/alert_devices_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/models/hex_color.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';

import 'package:guardian/widgets/ui/fence/fence_item.dart';
import 'package:guardian/widgets/ui/dropdown/alert/alert_management_item.dart';

class DeviceSettingsPage extends StatefulWidget {
  final Device device;
  const DeviceSettingsPage({super.key, required this.device});

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  late Future _future;

  String _deviceName = '';
  final List<UserAlert> _alerts = [];
  final List<Fence> _fences = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  Future<void> _setup() async {
    _deviceName = widget.device.name;
    await _getDeviceAlerts();
    await _getDeviceFences();
    controller.text = widget.device.name;
  }

  Future<void> _getDeviceAlerts() async {
    await getDeviceAlerts(widget.device.deviceId).then((allAlerts) {
      if (mounted) {
        setState(() => _alerts.addAll(allAlerts));
      }
    });
  }

  Future<void> _getDeviceFences() async {
    getDeviceFence(widget.device.deviceId).then((deviceFence) {
      if (deviceFence != null) {
        if (mounted) {
          setState(() => _fences.add(deviceFence));
        }
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
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomCircularProgressIndicator();
            } else {
              return SafeArea(
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
                            _deviceName = value;
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
                                    _alerts.addAll(selectedAlerts);
                                  });
                                  for (var selectedAlert in selectedAlerts) {
                                    await addAlertDevice(
                                      AlertDevice(
                                          deviceId: widget.device.deviceId,
                                          alertId: selectedAlert.alertId),
                                    );
                                  }
                                  // TODO: add service call
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
                          itemCount: _alerts.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: AlertManagementItem(
                              alert: _alerts[index],
                              onDelete: (alert) {
                                // TODO: Delete code for alert
                                removeAlertDevice(alert.alertId, widget.device.deviceId);
                                setState(() {
                                  _alerts
                                      .removeWhere((element) => element.alertId == alert.alertId);
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
                                  _fences.add(newFence);
                                });
                                createFenceDevice(
                                  FenceDevice(
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
                              // TODO: se poder ter várias cercas trocar
                              _fences.isEmpty ? const Icon(Icons.add) : const SizedBox()
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _fences.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: FenceItem(
                              name: _fences[index].name,
                              color: HexColor(_fences[index].color),
                              onRemove: () {
                                removeDeviceFence(_fences[index].fenceId, widget.device.deviceId);
                                setState(() {
                                  _fences.removeWhere(
                                    (element) => element.fenceId == _fences[index].fenceId,
                                  );
                                });
                                // TODO remove item service call
                              },
                            ),
                          ),
                        ),
                      ),
                      if (widget.device.name != _deviceName)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _deviceName = widget.device.name;
                                    controller.text = _deviceName;
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
                                final newDevice = widget.device.copy(name: _deviceName);
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
              );
            }
          },
        ),
      ),
    );
  }
}
