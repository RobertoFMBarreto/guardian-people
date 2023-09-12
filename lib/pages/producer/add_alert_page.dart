import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/helpers/key_value_pair.dart';
import 'package:guardian/models/helpers/user_alert.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/widgets/inputs/custom_dropdown.dart';
import 'package:guardian/widgets/ui/device/device_item_removable.dart';

class AddAlertPage extends StatefulWidget {
  final UserAlertCompanion? alert;
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
  final _formKey = GlobalKey<FormState>();

  late Future _future;

  final List<Device> _alertDevices = [];
  AlertComparissons _alertComparisson = AlertComparissons.equal;
  AlertParameter _alertParameter = AlertParameter.temperature;
  double _comparissonValue = 0;
  bool _sendNotification = true;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  Future<void> _setup() async {
    if (widget.alert != null) {
      _alertComparisson = parseComparissonFromString(widget.alert!.comparisson.value);
      _alertParameter = parseAlertParameterFromString(widget.alert!.parameter.value);
      _comparissonValue = widget.alert!.value.value;
      _sendNotification = widget.alert!.hasNotification.value;
      await _getAlertDevices(widget.alert!.alertId.value);
    }
  }

  Future<void> _getAlertDevices(String alertId) async {
    await getAlertDevices(alertId).then((allDevices) {
      if (mounted) {
        setState(() => _alertDevices.addAll(allDevices));
      }
    });
  }

  Future<void> _addAlertDevices(String alertId) async {
    for (var device in _alertDevices) {
      await addAlertDevice(
        AlertDevicesCompanion(
          alertDeviceId: drift.Value(Random().nextInt(9999).toString()),
          deviceId: device.device.deviceId,
          alertId: drift.Value(alertId),
        ),
      );
    }
  }

  Future<void> _updateAlert() async {
    await updateUserAlert(
      widget.alert!.copyWith(
        parameter: drift.Value(_alertParameter.toString()),
        comparisson: drift.Value(_alertComparisson.toString()),
        value: drift.Value(_comparissonValue),
        hasNotification: drift.Value(_sendNotification),
      ),
    ).then(
      (_) async => await removeAllAlertDevices(widget.alert!.alertId.value).then(
        (_) async {
          await _addAlertDevices(widget.alert!.alertId.value).then(
            (_) => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }

  Future<void> _createAlert() async {
    final alertId = Random().nextInt(9999).toString();
    final newAlert = UserAlertCompanion(
      alertId: drift.Value(alertId),
      hasNotification: drift.Value(_sendNotification),
      parameter: drift.Value(_alertParameter.toString()),
      comparisson: drift.Value(_alertComparisson.toString()),
      value: drift.Value(_comparissonValue),
    );
    await createAlert(
      newAlert,
    ).then((createdAlert) async {
      await _addAlertDevices(alertId).then(
        (_) => Navigator.of(context).pop(),
      );
    });
  }

  Future<void> _removeAlert(int index) async {
    await removeAlertDevice(
      widget.alert!.alertId.value,
      _alertDevices[index].device.deviceId.value,
    ).then(
      (_) {
        setState(() {
          _alertDevices.removeWhere(
            (element) => element.device.deviceId == _alertDevices[index].device.deviceId,
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceWidth = MediaQuery.of(context).size.width;
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            '${widget.isEdit! ? localizations.edit.capitalize() : localizations.add.capitalize()} ${localizations.warnings.capitalize()}',
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
                child: Form(
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
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CustomDropdown(
                            value: _alertParameter,
                            values: AlertParameter.values
                                .map((e) => KeyValuePair(
                                    key: e.toShortString(context).capitalize(), value: e))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                if (value != null) {
                                  _alertParameter = value as AlertParameter;
                                }
                              });
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CustomDropdown(
                              value: _alertComparisson,
                              values: AlertComparissons.values
                                  .map((e) => KeyValuePair(
                                      key: e.toShortString(context).capitalize(), value: e))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  if (value != null) {
                                    _alertComparisson = value as AlertComparissons;
                                  }
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _alertComparisson == AlertComparissons.equal
                                    ? localizations.to
                                    : localizations.than,
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w500,
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
                                    _comparissonValue != 0 ? _comparissonValue.toString() : null,
                                validator: (value) {
                                  if (value == null) {
                                    return localizations.insert_value.capitalize();
                                  } else {
                                    double? inputValue = double.tryParse(value);
                                    if (inputValue != null) {
                                      switch (_alertParameter) {
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
                                    _comparissonValue = inputValue;
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
                                    inactiveTrackColor:
                                        Theme.of(context).brightness == Brightness.light
                                            ? gdToggleGreyArea
                                            : gdDarkToggleGreyArea,
                                    value: _sendNotification,
                                    onChanged: (value) {
                                      setState(() {
                                        _sendNotification = value;
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
                                Navigator.of(context)
                                    .pushNamed(
                                  '/producer/devices',
                                  arguments: widget.alert != null
                                      ? {
                                          'isSelect': true,
                                          'alertId': widget.alert!.alertId.value,
                                          'notToShowDevices': _alertDevices
                                              .map((e) => e.device.deviceId.value)
                                              .toList(),
                                        }
                                      : {
                                          'isSelect': true,
                                          'notToShowDevices': _alertDevices
                                              .map((e) => e.device.deviceId.value)
                                              .toList(),
                                        },
                                )
                                    .then((selectedDevices) async {
                                  if (selectedDevices != null &&
                                      selectedDevices.runtimeType == List<Device>) {
                                    final selected = selectedDevices as List<Device>;
                                    setState(() {
                                      _alertDevices.addAll(selected);
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
                            itemCount: _alertDevices.length,
                            itemBuilder: (context, index) => DeviceItemRemovable(
                              key: Key(_alertDevices[index].device.deviceId.value),
                              device: _alertDevices[index],
                              onRemoveDevice: () {
                                // TODO: On remove device
                                if (widget.alert != null) {
                                  _removeAlert(index);
                                } else {
                                  setState(() {
                                    _alertDevices.removeWhere(
                                      (element) =>
                                          element.device.deviceId ==
                                          _alertDevices[index].device.deviceId,
                                    );
                                  });
                                }
                              },
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
                                  backgroundColor: MaterialStatePropertyAll(gdDarkCancelBtnColor),
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
                                      _updateAlert();
                                    } else {
                                      _createAlert();
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
              );
            }
          },
        ),
      ),
    );
  }
}
