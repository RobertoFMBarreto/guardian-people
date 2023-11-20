import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/providers/api/requests/alerts_requests.dart';
import 'package:guardian/models/providers/api/requests/animals_requests.dart';
import 'package:guardian/models/providers/api/requests/fencing_requests.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_animal_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';

import 'package:guardian/widgets/ui/fence/fence_item.dart';
import 'package:guardian/widgets/ui/alert/alert_management_item.dart';

/// Class that represents the device settings page
class AnimalSettingsPage extends StatefulWidget {
  final Animal animal;
  const AnimalSettingsPage({super.key, required this.animal});

  @override
  State<AnimalSettingsPage> createState() => _AnimalSettingsPageState();
}

class _AnimalSettingsPageState extends State<AnimalSettingsPage> {
  late Future _future;

  String _animalName = '';
  List<UserAlertCompanion> _alerts = [];
  List<FenceData> _fences = [];
  TextEditingController controller = TextEditingController();

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
        onFailed: () {
          AppLocalizations localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(localizations.server_error)));
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

  /// Method that pushes to the alerts management page in select mode and loads the selected alerts into the [_alerts] list
  ///
  /// It also inserts in the database the connection between the animal and the alert
  Future<void> _onSelectAlerts() async {
    Navigator.push(
      context,
      CustomPageRouter(
          page: '/producer/alerts/management',
          settings: RouteSettings(
            arguments: {'isSelect': true, 'idAnimal': widget.animal.animal.idAnimal.value},
          )),
    ).then((gottenAlerts) async {
      if (gottenAlerts.runtimeType == List<UserAlertCompanion>) {
        final selectedAlerts = gottenAlerts as List<UserAlertCompanion>;

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
                  onFailed: () {
                    setState(() {
                      _alerts.removeWhere(
                        (a) => a.idAlert == selectedAlert.idAlert,
                      );
                    });
                    AppLocalizations localizations = AppLocalizations.of(context)!;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(localizations.server_error)));
                  },
                );
              },
              onFailed: () {},
            ),
          );
        }
      }
    });
  }

  /// Method that pushes the fences page in select mode and loads the fence into the [_fences] list
  ///
  /// It also inserts in the database the connection between the fence and the device
  Future<void> _onSelectFence() async {
    Navigator.of(context).pushNamed('/producer/fences', arguments: true).then((newFenceData) {
      if (newFenceData != null && newFenceData.runtimeType == FenceData) {
        final newFence = newFenceData as FenceData;

        setState(() {
          _fences.add(newFence);
        });
        FencingRequests.addAnimalFence(
          animalIds: [widget.animal.animal.idAnimal.value],
          context: context,
          fenceId: newFence.idFence,
          onFailed: () {
            AppLocalizations localizations = AppLocalizations.of(context)!;
            setState(() {
              _fences.removeWhere(
                (element) => element.idFence == newFence.idFence,
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localizations.server_error.capitalize!,
                ),
              ),
            );
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

  /// Method that updates animal name locally and on api
  Future<void> _updateAnimal() async {
    final newAnimal = Animal(
      animal: widget.animal.animal.copyWith(
        animalName: drift.Value(_animalName),
      ),
      data: widget.animal.data,
    );

    updateAnimal(newAnimal.animal).then((value) => Navigator.of(context).pop(newAnimal));
    AnimalRequests.updateAnimal(
      animal: newAnimal,
      context: context,
      onFailed: () {
        AppLocalizations localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(localizations.server_error)));
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
      onFailed: () {
        AppLocalizations localizations = AppLocalizations.of(context)!;
        setState(() {
          _fences.add(fence);
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(localizations.server_error.capitalize!)));
      },
    ).then((value) => removeAnimalFence(fence.idFence, widget.animal.animal.idAnimal.value));
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
            onFailed: () {
              addAlertAnimal(
                AlertAnimalsCompanion(
                  idAlert: alert.idAlert,
                  idAnimal: widget.animal.animal.idAnimal,
                ),
              );
              setState(() {
                _alerts.add(removedAlert);
              });
              AppLocalizations localizations = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(localizations.server_error)));
            },
          );
        },
        onFailed: () {},
      ),
    );
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
            localizations.device_settings.capitalizeFirst!,
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
                          label: Text(localizations.name.capitalizeFirst!),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _animalName = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: GestureDetector(
                          onTap: _onSelectAlerts,
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
                          onTap: _onSelectFence,
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
                              onPressed: _updateAnimal,
                              child: Text(
                                localizations.confirm.capitalizeFirst!,
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
