import 'package:flutter/material.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/operations/sensors_operations.dart';
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/providers/api/requests/alerts_requests.dart';
import 'package:guardian/pages/producer/web/widget/select_device_dialogue.dart';
import 'package:guardian/settings/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/helpers/key_value_pair.dart';
import 'package:guardian/models/helpers/user_alert.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/widgets/inputs/custom_dropdown.dart';
import 'package:guardian/widgets/ui/animal/animal_item_removable.dart';
import 'package:uuid/uuid.dart';

/// Class that represents the add alert page
class AddAlert extends StatefulWidget {
  final UserAlertCompanion? alert;
  final bool? isEdit;
  final Function onCreate;
  final Function onCancel;
  const AddAlert({
    super.key,
    this.alert,
    this.isEdit = false,
    required this.onCreate,
    required this.onCancel,
  });

  @override
  State<AddAlert> createState() => _AddAlertState();
}

class _AddAlertState extends State<AddAlert> {
  final _formKey = GlobalKey<FormState>();
  List<Sensor> _availableSensors = [];

  late Future _future;
  late Sensor _alertParameter;

  final List<Animal> _alertAnimals = [];
  AlertComparissons _alertComparisson = AlertComparissons.equal;
  String _comparissonValue = "0";
  bool _sendNotification = true;
  bool _firstRun = true;

  @override
  void initState() {
    isSnackbarActive = false;
    _future = _setup();
    super.initState();
  }

  /// Method that does the initial setup for the page
  ///
  /// 1. Parse received alert data if there is one
  /// 2. Get alert devices
  Future<void> _setup() async {
    await _getAlertableSensors().then((_) async {
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
    final updatedAlert = widget.alert!.copyWith(
      parameter: drift.Value(_alertParameter.idSensor),
      comparisson: drift.Value(_alertComparisson.toOperator()),
      conditionCompTo: drift.Value(_comparissonValue),
      hasNotification: drift.Value(_sendNotification),
      durationSeconds: const drift.Value(0),
      isStateParam: const drift.Value(false),
      isTimed: const drift.Value(false),
    );

    await AlertRequests.updateAlertToApi(
      context: context,
      alert: updatedAlert,
      animals: _alertAnimals,
      onDataGotten: (data) {},
      onFailed: (statusCode) {
        if (!hasConnection && !isSnackbarActive) {
          showNoConnectionSnackBar();
        } else {
          if (statusCode == 507 || statusCode == 404) {
            if (_firstRun == true) {
              showNoConnectionSnackBar();
            }
            _firstRun = false;
          } else if (!isSnackbarActive) {
            AppLocalizations localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(localizations.server_error)));
          }
        }
      },
    );
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
      onDataGotten: (data) {},
      onFailed: (statusCode) {
        if (!hasConnection && !isSnackbarActive) {
          showNoConnectionSnackBar();
        } else {
          if (statusCode == 507 || statusCode == 404) {
            if (_firstRun == true) {
              showNoConnectionSnackBar();
            }
            _firstRun = false;
          } else if (!isSnackbarActive) {
            AppLocalizations localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(localizations.server_error)));
          }
        }
      },
    );
  }

  /// Method that pushes to the devices pages and allows to select the devices for the alert
  ///
  /// When it gets back from the page it inserts all devices in the [_alertAnimals] list
  Future<void> _onAddAnimals() async {
    showDialog(
      context: context,
      builder: (context) {
        ThemeData theme = Theme.of(context);
        return Dialog(
          backgroundColor:
              theme.brightness == Brightness.light ? gdBackgroundColor : gdDarkBackgroundColor,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Scaffold(
                body: SelectDeviceDialogue(
                  idAlert: widget.alert?.idAlert.value,
                  notToShowAnimals: _alertAnimals.map((e) => e.animal.idAnimal.value).toList(),
                ),
              ),
            ),
          ),
        );
      },
    ).then((selectedDevices) async {
      if (selectedDevices != null && selectedDevices.runtimeType == List<Animal>) {
        final selected = selectedDevices as List<Animal>;
        setState(() {
          _alertAnimals.addAll(selected);
        });
      }
    });
  }

  /// Method that allows to get all alertable sensors
  Future<void> _getAlertableSensors() async {
    await _getLocalAlertableSensors().then((_) async {
      await AlertRequests.getAlertableSensorsFromApi(
        context: context,
        onDataGotten: (data) async {
          await _getLocalAlertableSensors();
        },
        onFailed: (statusCode) {
          if (!hasConnection && !isSnackbarActive) {
            showNoConnectionSnackBar();
          } else {
            if (statusCode == 507 || statusCode == 404) {
              if (_firstRun == true) {
                showNoConnectionSnackBar();
              }
              _firstRun = false;
            } else if (!isSnackbarActive) {
              AppLocalizations localizations = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(localizations.server_error)));
            }
          }
        },
      );
    });
  }

  /// Method that allows to get all local alertable sensors
  Future<void> _getLocalAlertableSensors() async {
    await getLocalAlertableSensors().then((allSensors) {
      if (allSensors.isNotEmpty) {
        setState(() {
          _availableSensors = [];
          if (widget.alert == null) {
            _alertParameter = allSensors[0];
          } else {
            _alertParameter = allSensors
                .firstWhere((element) => element.idSensor == widget.alert!.parameter.value);
          }

          _availableSensors.addAll(allSensors);
        });
      }
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
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        CustomFocusManager.unfocus(context);
      },
      child: FutureBuilder(
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
                                  _comparissonValue != '0' ? _comparissonValue.toString() : null,
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
                                inactiveTrackColor: Theme.of(context).brightness == Brightness.light
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
                              setState(() {
                                _alertAnimals.removeWhere(
                                  (element) =>
                                      element.animal.idAnimal ==
                                      _alertAnimals[index].animal.idAnimal,
                                );
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0, bottom: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                CustomFocusManager.unfocus(context);
                                widget.onCancel();
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
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (widget.alert != null && widget.isEdit!) {
                                    await _updateAlert().then((_) => widget.onCreate());
                                  } else {
                                    await _createAlert().then((_) => widget.onCreate());
                                  }
                                }
                              },
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.isEdit!
                                      ? localizations.confirm.capitalizeFirst!
                                      : localizations.add.capitalizeFirst!,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSecondary,
                                  ),
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
    );
  }
}
