import 'package:flutter/material.dart';
import 'package:guardian/main.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_animal_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/models/helpers/alert_dialogue_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/models/providers/api/requests/alerts_requests.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/models/providers/api/requests/fencing_requests.dart';
import 'package:guardian/pages/producer/web/widget/select_alerts_dialogue.dart';
import 'package:guardian/pages/producer/web/widget/select_fences_dialogue.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/widgets/inputs/color_picker_input.dart';
import 'package:guardian/widgets/ui/alert/alert_management_item.dart';
import 'package:guardian/widgets/ui/common/color_circle.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/fence/fence_item.dart';

class DeviceSettings extends StatefulWidget {
  final Animal animal;
  final Function(String)? onColorChanged;
  final Function(String) onNameChanged;
  const DeviceSettings(
      {super.key, required this.animal, this.onColorChanged, required this.onNameChanged});

  @override
  State<DeviceSettings> createState() => _DeviceSettingsState();
}

class _DeviceSettingsState extends State<DeviceSettings> {
  late Future _future;

  String _animalColor = '';
  String _animalName = '';
  bool _firstRun = true;
  TextEditingController controller = TextEditingController();

  List<UserAlertCompanion> _alerts = [];
  List<FenceData> _fences = [];

  @override
  void initState() {
    _future = _setup();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Method that does the initial setup of the page
  ///
  /// 1. set the animal name
  /// 2. get the device alerts
  /// 3. get the device fences
  /// 4. setup the text of the controller to the animal name
  Future<void> _setup() async {
    _animalName = widget.animal.animal.animalName.value;
    _animalColor = widget.animal.animal.animalColor.value;
    await _getDeviceAlerts();
    await _getLocalFences();
    controller.text = widget.animal.animal.animalName.value;
  }

  /// Method that loads the device alerts into the [_alerts] list
  Future<void> _getDeviceAlerts() async {
    await getAnimalAlerts(widget.animal.animal.idAnimal.value).then((allAlerts) {
      if (mounted) {
        _alerts = [];
        setState(() => _alerts.addAll(allAlerts));
      }
    });
  }

  /// Method that allows to get all fences from api, searching for the device fences then
  Future<void> _getLocalFences() async {
    _getDeviceFences().then(
      (_) => FencingRequests.getUserFences(
        context: context,
        onGottenData: (_) async {
          await _getDeviceFences();
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
      ),
    );
  }

  /// Method that load the device fences into the [_fences] list
  Future<void> _getDeviceFences() async {
    getAnimalFence(widget.animal.animal.idAnimal.value).then((deviceFence) {
      if (deviceFence != null) {
        if (mounted) {
          _fences = [];
          setState(() => _fences.add(deviceFence));
        }
      }
    });
  }

  /// Method that updates animal name locally and on api
  Future<void> _updateAnimal() async {
    final newAnimal = Animal(
      animal: widget.animal.animal.copyWith(
        animalName: drift.Value(_animalName),
        animalColor: drift.Value(_animalColor),
      ),
      data: widget.animal.data,
    );
    AnimalRequests.updateAnimal(
      animal: newAnimal,
      context: context,
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
      onDataGotten: () async {
        await updateAnimal(newAnimal.animal);
      },
    );
  }

  /// Method that allows to remove a fence
  Future<void> _removeFence(int index) async {
    final fence = _fences[index];
    setState(() {
      _fences.removeWhere(
        (element) => element.idFence == _fences[index].idFence,
      );
    });
    FencingRequests.removeAnimalFence(
      fenceId: fence.idFence,
      animalIds: [
        widget.animal.animal.idAnimal.value.toString(),
      ],
      context: context,
      onFailed: (statusCode) {
        setState(() {
          _fences.add(fence);
        });
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
      onDataGotten: () async {
        await removeAnimalFence(fence.idFence, widget.animal.animal.idAnimal.value);
      },
    );
  }

  /// Method that allows to delete an alert from device
  Future<void> _deleteAlertFromDevice(UserAlertCompanion alert) async {
    final removedAlert = alert;
    await removeAlertAnimal(alert.idAlert.value, widget.animal.animal.idAnimal.value);
    setState(() {
      _alerts.removeWhere((element) => element.idAlert == alert.idAlert);
    });

    getAlertAnimals(alert.idAlert.value).then(
      (animals) => AlertRequests.getUserAlertsFromApi(
        context: context,
        onDataGotten: (data) {
          AlertRequests.updateAlertToApi(
            context: context,
            alert: alert,
            animals: [...animals],
            onDataGotten: (data) {},
            onFailed: (statusCode) {
              addAlertAnimal(
                AlertAnimalsCompanion(
                  idAlert: alert.idAlert,
                  idAnimal: widget.animal.animal.idAnimal,
                ),
              );
              setState(() {
                _alerts.add(removedAlert);
              });
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
      ),
    );
  }

  /// Method that shows a color picker to change the [_animalColor]
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => CustomColorPickerInput(
        pickerColor: HexColor(_animalColor),
        onSave: (color) {
          _onColorUpdate(color);
        },
        hexColor: _animalColor,
      ),
    );
  }

  /// Method that update the [_animalColor] and updates the database
  Future<void> _onColorUpdate(Color color) async {
    _animalColor = HexColor.toHex(color: color);
    await _updateAnimal();
    setState(() {
      widget.onColorChanged!(HexColor.toHex(color: color));
    });
  }

  /// Method that pushes to the alerts management page in select mode and loads the selected alerts into the [_alerts] list
  ///
  /// It also inserts in the database the connection between the animal and the alert
  Future<void> _onAddAlerts() async {
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
                body: SelectAlertsDialogue(
                  idAnimal: widget.animal.animal.idAnimal.value,
                ),
              ),
            ),
          ),
        );
      },
    ).then((selectedDevices) async {
      if (selectedDevices.runtimeType == List<UserAlertCompanion>) {
        final selectedAlerts = selectedDevices as List<UserAlertCompanion>;

        for (var selectedAlert in selectedAlerts) {
          await addAlertAnimal(
            AlertAnimalsCompanion(
              idAnimal: widget.animal.animal.idAnimal,
              idAlert: selectedAlert.idAlert,
            ),
          );
          setState(() {
            _alerts.add(selectedAlert);
          });
        }
        for (var selectedAlert in selectedAlerts) {
          getAlertAnimals(selectedAlert.idAlert.value).then(
            (animals) => AlertRequests.getUserAlertsFromApi(
              context: context,
              onDataGotten: (data) {
                AlertRequests.updateAlertToApi(
                  context: context,
                  alert: selectedAlert,
                  animals: [...animals],
                  onDataGotten: (data) {},
                  onFailed: (statusCode) {
                    setState(() {
                      _alerts.removeWhere(
                        (a) => a.idAlert == selectedAlert.idAlert,
                      );
                    });
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
            ),
          );
        }
      }
    });
  }

  /// Method that pushes to the devices pages and allows to select the devices for the alert
  ///
  /// When it gets back from the page it inserts all devices in the [_alertAnimals] list
  Future<void> _onAddFence() async {
    showDialog(
      context: context,
      builder: (context) {
        ThemeData theme = Theme.of(context);
        return Dialog(
          backgroundColor:
              theme.brightness == Brightness.light ? gdBackgroundColor : gdDarkBackgroundColor,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: Scaffold(
                body: SelectFencesDialogue(),
              ),
            ),
          ),
        );
      },
    ).then((selectedFences) async {
      if (selectedFences != null && selectedFences.runtimeType == FenceData) {
        final newFence = selectedFences as FenceData;

        setState(() {
          _fences.add(newFence);
        });
        FencingRequests.addAnimalFence(
          animalIds: [widget.animal.animal.idAnimal.value],
          context: context,
          fenceId: newFence.idFence,
          onFailed: (statusCode) {
            setState(() {
              _fences.removeWhere(
                (element) => element.idFence == newFence.idFence,
              );
            });
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
        createFenceAnimal(
          FenceAnimalsCompanion(
            idFence: drift.Value(newFence.idFence),
            idAnimal: widget.animal.animal.idAnimal,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomCircularProgressIndicator();
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          label: Text(localizations.name.capitalizeFirst!),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _animalName = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          _showColorPicker();
                        },
                        child: ColorCircle(
                          color: HexColor(_animalColor),
                          radius: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: GestureDetector(
                    onTap: _onAddAlerts,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.device_warnings.capitalizeFirst!,
                          style: theme.textTheme.headlineMedium!.copyWith(fontSize: 22),
                        ),
                        const Icon(Icons.add)
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _alerts.isEmpty
                      ? Center(
                          child: Text(localizations.no_selected_alerts.capitalizeFirst!),
                        )
                      : ListView.builder(
                          itemCount: _alerts.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: AlertManagementItem(
                              alert: _alerts[index],
                              onTap: () {},
                              onDelete: _deleteAlertFromDevice,
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: GestureDetector(
                    onTap: _onAddFence,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.device_fences.capitalizeFirst!,
                          style: theme.textTheme.headlineMedium!.copyWith(fontSize: 22),
                        ),
                        _fences.isEmpty ? const Icon(Icons.add) : const SizedBox()
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _fences.isEmpty
                      ? Center(
                          child: Text(localizations.no_selected_fences.capitalizeFirst!),
                        )
                      : ListView.builder(
                          itemCount: _fences.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: FenceItem(
                              name: _fences[index].name,
                              onTap: () {},
                              color: HexColor(_fences[index].color),
                              onRemove: () {
                                _removeFence(index);
                              },
                            ),
                          ),
                        ),
                ),
                if (widget.animal.animal.animalName.value != _animalName)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _animalName = widget.animal.animal.animalName.value;
                              controller.text = _animalName;
                            });
                          },
                          style: theme.elevatedButtonTheme.style!.copyWith(
                            backgroundColor: const MaterialStatePropertyAll(gdCancelBtnColor),
                          ),
                          child: Text(
                            localizations.cancel.capitalizeFirst!,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _updateAnimal();
                          widget.onNameChanged(_animalName);
                        },
                        child: Text(
                          localizations.confirm.capitalizeFirst!,
                        ),
                      ),
                    ],
                  )
              ],
            );
          }
        });
  }
}
