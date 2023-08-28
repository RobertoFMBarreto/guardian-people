import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/db/alert_devices_operations.dart';
import 'package:guardian/db/user_alert_operations.dart';
import 'package:guardian/models/data_models/Alerts/alert_devices.dart';
import 'package:guardian/models/data_models/Alerts/user_alert.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/data_models/Device/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/focus_manager.dart';
import 'package:guardian/models/key_value_pair.dart';
import 'package:guardian/widgets/device/device_item_removable.dart';
import 'package:guardian/widgets/inputs/custom_dropdown.dart';

class AddAlertPage extends StatefulWidget {
  final UserAlert? alert;
  final bool? isEdit;
  const AddAlertPage({
    super.key,
    this.alert,
    this.isEdit = false,
  });

  @override
  State<AddAlertPage> createState() => _AddAlertPageState();
}

class _AddAlertPageState extends State<AddAlertPage> {
  AlertComparissons alertComparisson = AlertComparissons.equal;

  AlertParameter alertParameter = AlertParameter.temperature;

  double comparissonValue = 0;

  bool sendNotification = true;

  final _formKey = GlobalKey<FormState>();

  List<Device> alertDevices = [];

  bool isLoading = true;

  @override
  void initState() {
    if (widget.alert != null) {
      alertComparisson = widget.alert!.comparisson;
      alertParameter = widget.alert!.parameter;
      comparissonValue = widget.alert!.value;
      sendNotification = widget.alert!.hasNotification;
      _getAlertDevices(widget.alert!.alertId).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
    super.initState();
  }

  Future<void> _getAlertDevices(String alertId) async {
    getAlertDevices(alertId).then((allDevices) {
      print(allDevices);
      setState(() => alertDevices.addAll(allDevices));
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceWidth = MediaQuery.of(context).size.width;
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.isEdit! ? localizations.edit.capitalize() : localizations.add.capitalize()} ${localizations.warnings.capitalize()}',
          style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              )
            : Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.when.capitalize(),
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomDropdown(
                          value: alertParameter,
                          values: AlertParameter.values
                              .map((e) => KeyValuePair(
                                  key: e.toShortString(context).capitalize(), value: e))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              if (value != null) {
                                alertParameter = value as AlertParameter;
                              }
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomDropdown(
                            value: alertComparisson,
                            values: AlertComparissons.values
                                .map((e) => KeyValuePair(
                                    key: e.toShortString(context).capitalize(), value: e))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                if (value != null) {
                                  alertComparisson = value as AlertComparissons;
                                }
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              localizations.to,
                              style: theme.textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                label: Text(localizations.value.capitalize()),
                              ),
                              keyboardType: TextInputType.number,
                              initialValue:
                                  comparissonValue != 0 ? comparissonValue.toString() : null,
                              validator: (value) {
                                if (value == null) {
                                  return localizations.insert_value.capitalize();
                                } else {
                                  double? inputValue = double.tryParse(value);
                                  if (inputValue != null) {
                                    switch (alertParameter) {
                                      case AlertParameter.battery:
                                        if (inputValue < 0 || inputValue > 100) {
                                          return localizations.invalid_value.capitalize();
                                        }
                                        break;
                                      case AlertParameter.dataUsage:
                                        if (inputValue < 0 || inputValue > 10) {
                                          return localizations.invalid_value.capitalize();
                                        }
                                        break;
                                      case AlertParameter.temperature:
                                        break;
                                    }
                                  } else {
                                    return localizations.invalid_value.capitalize();
                                  }
                                  return null;
                                }
                              },
                              onChanged: (value) {
                                double? inputValue = double.tryParse(value);
                                if (inputValue != null) {
                                  comparissonValue = inputValue;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          localizations.what_to_do.capitalize(),
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Text(
                              '${localizations.send.capitalize()} ${localizations.notification.capitalize()}:',
                              style: theme.textTheme.bodyLarge,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Switch(
                                  activeTrackColor: theme.colorScheme.secondary,
                                  value: sendNotification,
                                  onChanged: (value) {
                                    setState(() {
                                      sendNotification = value;
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              print(alertDevices.map((e) => e.deviceId).toList());
                              Navigator.of(context)
                                  .pushNamed(
                                '/producer/devices',
                                arguments: widget.alert != null
                                    ? {
                                        'isSelect': true,
                                        'alertId': widget.alert!.alertId,
                                        'notToShowDevices':
                                            alertDevices.map((e) => e.deviceId).toList(),
                                      }
                                    : {
                                        'isSelect': true,
                                        'notToShowDevices':
                                            alertDevices.map((e) => e.deviceId).toList(),
                                      },
                              )
                                  .then((selectedDevices) async {
                                if (selectedDevices != null &&
                                    selectedDevices.runtimeType == List<Device>) {
                                  final selected = selectedDevices as List<Device>;
                                  setState(() {
                                    alertDevices.addAll(selected);
                                  });
                                }
                              });
                            },
                            icon: Icon(
                              Icons.add,
                              color: theme.colorScheme.secondary,
                            ),
                            label: Text(
                              '${localizations.add.capitalize()} ${localizations.devices.capitalize()}',
                              style: theme.textTheme.bodyLarge!.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          itemCount: alertDevices.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: DeviceItemRemovable(
                              key: Key(alertDevices[index].deviceId),
                              deviceTitle: alertDevices[index].name,
                              deviceData: alertDevices[index].data!.first.dataUsage,
                              deviceBattery: alertDevices[index].data!.first.battery,
                              onRemoveDevice: () {
                                //!TODO: On remove device
                                if (widget.alert != null) {
                                  removeAlertDevice(
                                    widget.alert!.alertId,
                                    alertDevices[index].deviceId,
                                  ).then(
                                    (_) {
                                      setState(() {
                                        alertDevices.removeWhere(
                                          (element) =>
                                              element.deviceId == alertDevices[index].deviceId,
                                        );
                                      });
                                    },
                                  );
                                } else {
                                  setState(() {
                                    alertDevices.removeWhere(
                                      (element) => element.deviceId == alertDevices[index].deviceId,
                                    );
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0, bottom: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                CustomFocusManager.unfocus(context);
                                Navigator.of(context).pop();
                              },
                              style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(gdCancelBtnColor),
                              ),
                              child: Text(
                                localizations.cancel.capitalize(),
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.onSecondary,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: deviceWidth * 0.05,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (widget.alert != null && widget.isEdit!) {
                                    await updateUserAlert(
                                      widget.alert!.copy(
                                        parameter: alertParameter,
                                        comparisson: alertComparisson,
                                        value: comparissonValue,
                                        hasNotification: sendNotification,
                                      ),
                                    ).then(
                                      (_) async =>
                                          await removeAllAlertDevices(widget.alert!.alertId).then(
                                        (_) async {
                                          for (var device in alertDevices) {
                                            await addAlertDevice(
                                              AlertDevices(
                                                deviceId: device.deviceId,
                                                alertId: widget.alert!.alertId,
                                              ),
                                            );
                                          }
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    );
                                  } else {
                                    await createAlert(
                                      UserAlert(
                                        alertId: Random().nextInt(90000).toString(),
                                        hasNotification: sendNotification,
                                        parameter: alertParameter,
                                        comparisson: alertComparisson,
                                        value: comparissonValue,
                                      ),
                                    ).then((createdAlert) async {
                                      print(createdAlert);
                                      for (var device in alertDevices) {
                                        await addAlertDevice(
                                          AlertDevices(
                                            deviceId: device.deviceId,
                                            alertId: createdAlert.alertId,
                                          ),
                                        );
                                      }
                                      Navigator.of(context).pop();
                                    });
                                  }
                                }
                              },
                              child: Text(
                                widget.isEdit!
                                    ? localizations.confirm.capitalize()
                                    : localizations.add.capitalize(),
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
