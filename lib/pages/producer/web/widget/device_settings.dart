import 'package:flutter/material.dart';
import 'package:guardian/custom_page_router.dart';
import 'package:guardian/models/db/drift/database.dart';
import 'package:guardian/models/db/drift/operations/alert_devices_operations.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/db/drift/operations/fence_devices_operations.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:drift/drift.dart' as drift;
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/widgets/inputs/color_picker_input.dart';
import 'package:guardian/widgets/ui/alert/alert_management_item.dart';
import 'package:guardian/widgets/ui/common/color_circle.dart';
import 'package:guardian/widgets/ui/common/custom_circular_progress_indicator.dart';
import 'package:guardian/widgets/ui/fence/fence_item.dart';

class DeviceSettings extends StatefulWidget {
  final Animal animal;
  final Function(String)? onColorChanged;
  const DeviceSettings({super.key, required this.animal, this.onColorChanged});

  @override
  State<DeviceSettings> createState() => _DeviceSettingsState();
}

class _DeviceSettingsState extends State<DeviceSettings> {
  late Future _future;

  String _animalName = '';
  String _animalColor = '';
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
  /// 1. set the animal color
  /// 2. get the device alerts
  /// 3. get the device fences
  /// 4. setup the text of the controller to the animal name
  Future<void> _setup() async {
    _animalName = widget.animal.animal.animalName.value;
    _animalColor = widget.animal.animal.animalColor.value;
    await _getDeviceAlerts();
    await _getDeviceFences();
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
    // TODO: Logic to update device color
    setState(() {
      _animalColor = HexColor.toHex(color: color);
      widget.onColorChanged!(HexColor.toHex(color: color));
    });

    await updateAnimal(
      widget.animal.animal.copyWith(
        animalColor: drift.Value(HexColor.toHex(color: color)),
      ),
    );
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
        setState(() {
          _alerts.addAll(selectedAlerts);
        });
        for (var selectedAlert in selectedAlerts) {
          await addAlertAnimal(
            AlertAnimalsCompanion(
              idAnimal: widget.animal.animal.idAnimal,
              idAlert: selectedAlert.idAlert,
            ),
          );
        }
        // TODO: add service call
      }
    });
  }

  /// Method that pushes the fences page in select mode and loads the fence into the [_fences] list
  ///
  /// It also inserts in the database the connection between the fence and the device
  Future<void> _onSelectFence() async {
    Navigator.of(context).pushNamed('/producer/fences', arguments: true).then((newFenceData) {
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
                          label: Text(localizations.name.capitalize()),
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
                    onTap: _onSelectAlerts,
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
                                removeAlertAnimal(
                                    alert.idAlert.value, widget.animal.animal.idAnimal.value);
                                setState(() {
                                  _alerts
                                      .removeWhere((element) => element.idAlert == alert.idAlert);
                                });
                              },
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
                                removeAnimalFence(
                                    _fences[index].idFence, widget.animal.animal.idAnimal.value);
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
            );
          }
        });
  }
}
