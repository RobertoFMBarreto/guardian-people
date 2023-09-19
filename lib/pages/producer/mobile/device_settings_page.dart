import 'dart:math';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/focus_manager.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';

import 'package:guardian/widgets/ui/fence/fence_item.dart';
import 'package:guardian/widgets/ui/alert/alert_management_item.dart';

class DeviceSettingsPage extends StatefulWidget {
  final Animal animal;
  const DeviceSettingsPage({super.key, required this.animal});

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
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

  Future<void> _setup() async {
    _animalName = widget.animal.animal.animalName.value;
    await _getDeviceAlerts();
    await _getDeviceFences();
    controller.text = widget.animal.animal.animalName.value;
  }

  Future<void> _getDeviceAlerts() async {
    await getDeviceAlerts(widget.animal.animal.idAnimal.value).then((allAlerts) {
      if (mounted) {
        _alerts = [];
        setState(() => _alerts.addAll(allAlerts));
      }
    });
  }

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
                            _animalName = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomPageRouter(
                                  page: '/producer/alerts/management',
                                  settings: RouteSettings(
                                    arguments: {
                                      'isSelect': true,
                                      'idAnimal': widget.animal.animal.idAnimal.value
                                    },
                                  )),
                            ).then((gottenAlerts) async {
                              if (gottenAlerts.runtimeType == List<UserAlertCompanion>) {
                                final selectedAlerts = gottenAlerts as List<UserAlertCompanion>;
                                setState(() {
                                  _alerts.addAll(selectedAlerts);
                                });
                                for (var selectedAlert in selectedAlerts) {
                                  await addAlertDevice(
                                    AlertDevicesCompanion(
                                      alertDeviceId:
                                          drift.Value(BigInt.from(Random().nextInt(999999))),
                                      idDevice: widget.animal.animal.idAnimal,
                                      idAlert: selectedAlert.idAlert,
                                    ),
                                  );
                                }
                                // TODO: add service call
                              }
                            });
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
                        child: _alerts.isEmpty
                            ? Center(
                                child: Text(localizations.no_selected_alerts.capitalize()),
                              )
                            : ListView.builder(
                                itemCount: _alerts.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: AlertManagementItem(
                                    alert: _alerts[index],
                                    onTap: () {},
                                    onDelete: (alert) {
                                      // TODO: Delete code for alert
                                      removeAlertDevice(
                                          alert.idAlert.value, widget.animal.animal.idAnimal.value);
                                      setState(() {
                                        _alerts.removeWhere(
                                            (element) => element.idAlert == alert.idAlert);
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
                              // TODO: Check if its wright
                              if (newFenceData != null && newFenceData.runtimeType == FenceData) {
                                final newFence = newFenceData as FenceData;
                                setState(() {
                                  _fences.add(newFence);
                                });
                                createFenceDevice(
                                  FenceAnimalsCompanion(
                                    idFence: drift.Value(newFence.idFence),
                                    idAnimal: widget.animal.animal.idAnimal,
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
                        child: _fences.isEmpty
                            ? Center(
                                child: Text(localizations.no_selected_fences.capitalize()),
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
                                      removeAnimalFence(_fences[index].idFence,
                                          widget.animal.animal.idAnimal.value);
                                      setState(() {
                                        _fences.removeWhere(
                                          (element) => element.idFence == _fences[index].idFence,
                                        );
                                      });
                                      // TODO remove item service call
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
                                  localizations.cancel.capitalize(),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final newAnimal = widget.animal.animal.copyWith(
                                  animalName: drift.Value(_animalName),
                                );
                                updateAnimal(newAnimal)
                                    .then((value) => Navigator.of(context).pop(newAnimal));
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
