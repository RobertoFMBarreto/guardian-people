import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/helpers/key_value_pair.dart';
import 'package:guardian/models/helpers/user_alert.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
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

  final List<Animal> _alertAnimals = [];
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
      await _getAlertDevices(widget.alert!.idAlert.value);
    }
  }

  Future<void> _getAlertDevices(BigInt idAlert) async {
    await getAlertDevices(idAlert).then((allDevices) {
      if (mounted) {
        setState(() => _alertAnimals.addAll(allDevices));
      }
    });
  }

  Future<void> _addAlertDevices(BigInt idAlert) async {
    for (var device in _alertAnimals) {
      await addAlertDevice(
        AlertAnimalsCompanion(
          alertAnimalId: drift.Value(BigInt.from(Random().nextInt(9999))),
          idAnimal: device.animal.idAnimal,
          idAlert: drift.Value(idAlert),
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
      (_) async => await removeAllAlertDevices(widget.alert!.idAlert.value).then(
        (_) async {
          await _addAlertDevices(widget.alert!.idAlert.value).then(
            (_) => Navigator.of(context).pop(),
          );
        },
      ),
    );
  }

  Future<void> _createAlert() async {
    final idAlert = BigInt.from(Random().nextInt(999999));
    final newAlert = UserAlertCompanion(
      idAlert: drift.Value(idAlert),
      hasNotification: drift.Value(_sendNotification),
      parameter: drift.Value(_alertParameter.toString()),
      comparisson: drift.Value(_alertComparisson.toString()),
      value: drift.Value(_comparissonValue),
    );
    await createAlert(
      newAlert,
    ).then((createdAlert) async {
      await _addAlertDevices(idAlert).then(
        (_) => Navigator.of(context).pop(),
      );
    });
  }

  Future<void> _removeAlert(int index) async {
    await removeAlertDevice(
      widget.alert!.idAlert.value,
      _alertAnimals[index].animal.idAnimal.value,
    ).then(
      (_) {
        setState(() {
          _alertAnimals.removeWhere(
            (element) => element.animal.idAnimal == _alertAnimals[index].animal.idAnimal,
          );
        });
      },
    );
  }

  Future<void> _onAddAnimals() async {
    Navigator.of(context)
        .pushNamed(
      '/producer/devices',
      arguments: widget.alert != null
          ? {
              'isSelect': true,
              'idAlert': widget.alert!.idAlert.value,
              'notToShowAnimals': _alertAnimals.map((e) => e.animal.idAnimal.value).toList(),
            }
          : {
              'isSelect': true,
              'notToShowAnimals': _alertAnimals.map((e) => e.animal.idAnimal.value).toList(),
            },
    )
        .then((selectedDevices) async {
      if (selectedDevices != null && selectedDevices.runtimeType == List<Animal>) {
        final selected = selectedDevices as List<Animal>;
        setState(() {
          _alertAnimals.addAll(selected);
        });
      }
    });
  }

  String? _validateInputValue(String? value, AppLocalizations localizations) {
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
                                  return _validateInputValue(value, localizations);
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
                              onPressed: _onAddAnimals,
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
                            itemCount: _alertAnimals.length,
                            itemBuilder: (context, index) => DeviceItemRemovable(
                              key: Key(_alertAnimals[index].animal.idAnimal.value.toString()),
                              animal: _alertAnimals[index],
                              onRemoveDevice: () {
                                // TODO: On remove device
                                if (widget.alert != null) {
                                  _removeAlert(index);
                                } else {
                                  setState(() {
                                    _alertAnimals.removeWhere(
                                      (element) =>
                                          element.animal.idAnimal ==
                                          _alertAnimals[index].animal.idAnimal,
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
