import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/operations/sensors_operations.dart';
import 'package:guardian/models/providers/api/parsers/alerts_parsers.dart';
import 'package:guardian/models/providers/api/requests/alerts_requests.dart';
import 'package:guardian/settings/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/helpers/key_value_pair.dart';
import 'package:guardian/models/helpers/user_alert.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/user_alert_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/widgets/inputs/custom_dropdown.dart';
import 'package:guardian/widgets/ui/animal/animal_item_removable.dart';
import 'package:uuid/uuid.dart';

/// Class that represents the add alert page
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
  List<Sensor> _availableSensors = [];

  late Future _future;
  late Sensor _alertParameter;

  final List<Animal> _alertAnimals = [];
  AlertComparissons _alertComparisson = AlertComparissons.equal;
  String _comparissonValue = "0";
  bool _sendNotification = true;

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  /// Method that does the initial setup for the page
  ///
  /// 1. Parse received alert data if there is one
  /// 2. Get alert devices
  Future<void> _setup() async {
    return await _getAlertableSensors().then((_) async {
      if (widget.alert != null) {
        await _getAlertDevices(widget.alert!.idAlert.value).then(
          (_) {
            _comparissonValue = widget.alert!.conditionCompTo.value;
            _sendNotification = widget.alert!.hasNotification.value;
          },
        );
      }
    });
  }

  /// Method that get all alert devices and fills the [_alertAnimals] list
  Future<void> _getAlertDevices(String idAlert) async {
    await getAlertAnimals(idAlert).then((allDevices) {
      if (mounted) {
        setState(() => _alertAnimals.addAll(allDevices));
      }
    });
  }

  /// Method that updates the [widget.alert] with the new data
  ///
  /// This method replaces all data even if it didn't change
  Future<void> _updateAlert() async {
    // await updateUserAlert(
    //   widget.alert!.copyWith(
    //     parameter: drift.Value(_alertParameter.toString()),
    //     comparisson: drift.Value(_alertComparisson.toString()),
    //     conditionCompTo: drift.Value(_comparissonValue),
    //     hasNotification: drift.Value(_sendNotification),
    //     durationSeconds: const drift.Value(0),
    //     isStateParam: const drift.Value(false),
    //     isTimed: const drift.Value(false),
    //   ),
    // ).then(
    //   (_) async => await removeAllAlertAnimals(widget.alert!.idAlert.value).then(
    //     (_) async {
    //       await _addAlertDevices(widget.alert!.idAlert.value).then(
    //         (_) => Navigator.of(context).pop(),
    //       );
    //     },
    //   ),
    // );
  }

  /// Method that creates a new [UserAlertCompanion] and inserts on the database
  Future<void> _createAlert() async {
    final idAlert = const Uuid().v4();
    final newAlert = UserAlertCompanion(
      idAlert: drift.Value(idAlert),
      hasNotification: drift.Value(_sendNotification),
      parameter: drift.Value(_alertParameter.idSensor),
      comparisson: drift.Value(_alertComparisson.toOperator()),
      conditionCompTo: drift.Value(_comparissonValue),
      durationSeconds: const drift.Value(0),
      isStateParam: const drift.Value(false),
      isTimed: const drift.Value(false),
    );
    await AlertRequests.addAlertToApi(
      context: context,
      alert: newAlert,
      animals: _alertAnimals,
      onDataGotten: (data) {
        Navigator.of(context).pop();
      },
      onFailed: () {},
    );
  }

  /// Method that removes the alert animal on [index] from the [_alertAnimals] list
  Future<void> _removeAlert(int index) async {
    await removeAlertAnimal(
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

  /// Method that pushes to the devices pages and allows to select the devices for the alert
  ///
  /// When it gets back from the page it inserts all devices in the [_alertAnimals] list
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

  Future<void> _getAlertableSensors() async {
    return await _getLocalAlertableSensors().then((_) {
      AlertRequests.getAlertableSensorsFromApi(
        context: context,
        onDataGotten: (data) {
          _getLocalAlertableSensors();
        },
        onFailed: () {},
      );
    });
  }

  Future<void> _getLocalAlertableSensors() async {
    return await getLocalAlertableSensors().then((allSensors) {
      setState(() {
        _availableSensors = [];
        if (widget.alert == null) {
          _alertParameter = allSensors[0];
        } else {
          _alertParameter =
              allSensors.firstWhere((element) => element.idSensor == widget.alert!.parameter.value);
        }

        _availableSensors.addAll(allSensors);
      });
    });
  }

  /// Method that validates the input value
  String? _validateInputValue(String? value, AppLocalizations localizations) {
    if (value == null) {
      return localizations.insert_value.capitalizeFirst!;
    } else {
      double? inputValue = double.tryParse(value);
      if (inputValue != null) {
        switch (_alertParameter.idSensor) {
          case 'fa6917df-ed01-45f2-bb55-a9a25b5a470a':
            if (inputValue < 0 || inputValue > 100) {
              return localizations.invalid_value.capitalizeFirst!;
            }
            break;
        }
      } else {
        return localizations.invalid_value.capitalizeFirst!;
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
            '${widget.isEdit! ? localizations.edit.capitalizeFirst! : localizations.add.capitalizeFirst!} ${localizations.warnings.capitalizeFirst!}',
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
                          localizations.when.capitalizeFirst!,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CustomDropdown(
                            value: _alertParameter,
                            values: _availableSensors
                                .map(
                                  (e) => KeyValuePair(
                                    key: parseAlertParameterFromId(e.idSensor, localizations)
                                        .capitalizeFirst!,
                                    value: e,
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                if (value != null) {
                                  _alertParameter = value as Sensor;
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
                                  .map(
                                    (e) => KeyValuePair(
                                      key: e.toShortString(context).capitalizeFirst!,
                                      value: e,
                                    ),
                                  )
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
                                  label: Text(localizations.value.capitalizeFirst!),
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
                                    _comparissonValue = inputValue.toString();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            localizations.what_to_do.capitalizeFirst!,
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
                                '${localizations.send.capitalizeFirst!} ${localizations.notification.capitalizeFirst!}:',
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
                                  },
                                ),
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
                                '${localizations.add.capitalizeFirst!} ${localizations.devices.capitalizeFirst!}',
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
                            itemBuilder: (context, index) => AnimalItemRemovable(
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
                                  localizations.cancel.capitalizeFirst!,
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
                                      ? localizations.confirm.capitalizeFirst!
                                      : localizations.add.capitalizeFirst!,
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
