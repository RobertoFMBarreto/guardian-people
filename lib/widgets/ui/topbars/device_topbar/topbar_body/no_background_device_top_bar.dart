import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guardian/models/db/drift/operations/animal_operations.dart';
import 'package:guardian/models/helpers/device_status.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/query_models/animal.dart';
import 'package:get/get.dart';
import 'package:guardian/models/helpers/device_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/widgets/ui/common/color_circle.dart';
import 'package:guardian/widgets/ui/common/icon_text.dart';
import 'package:guardian/widgets/inputs/color_picker_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:drift/drift.dart' as drift;

/// Class that represents the no background device top bar
class NoBackgroundDeviceTopBar extends StatefulWidget {
  final Animal animal;
  final Widget? tailWidget;
  final Function(String) onColorChanged;
  final double maxHeight;
  final DeviceStatus deviceStatus;
  const NoBackgroundDeviceTopBar({
    super.key,
    required this.animal,
    required this.maxHeight,
    required this.tailWidget,
    required this.onColorChanged,
    required this.deviceStatus,
  });

  @override
  State<NoBackgroundDeviceTopBar> createState() => _NoBackgroundDeviceTopBarState();
}

class _NoBackgroundDeviceTopBarState extends State<NoBackgroundDeviceTopBar> {
  late Color animalColor;

  List<String> states = ['Comer', 'Pastar', 'Andar', 'Parada', 'Descansar', 'Estático'];

  @override
  void initState() {
    animalColor = HexColor(widget.animal.animal.animalColor.value);
    super.initState();
  }

  /// Method that allows to show the color picker and change the animal color
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => CustomColorPickerInput(
        pickerColor: animalColor,
        onSave: (color) {
          _onColorUpdate(color);
        },
        hexColor: HexColor.toHex(color: animalColor),
      ),
    );
  }

  /// Method that executes when the animal color changes
  Future<void> _onColorUpdate(Color color) async {
    setState(() {
      animalColor = color;
      widget.onColorChanged(HexColor.toHex(color: animalColor));
    });

    await updateAnimal(
      widget.animal.animal.copyWith(
        animalColor: drift.Value(HexColor.toHex(color: animalColor)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceWidth = MediaQuery.of(context).size.width;

    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Container(
      width: deviceWidth,
      height: widget.maxHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            theme.brightness == Brightness.dark ? gdDarkGradientStart : gdGradientStart,
            theme.brightness == Brightness.dark ? gdDarkGradientEnd : gdGradientEnd,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: deviceWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSecondary,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                widget.tailWidget ?? const SizedBox()
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              widget.animal.animal.animalName.value,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium!.copyWith(
                                color: theme.colorScheme.onSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.animal.data.isEmpty)
                    Expanded(
                      child: Text(
                        localizations.no_device_data.capitalizeFirst!,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: theme.colorScheme.onSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (widget.animal.data.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: IconText(
                                  icon: Icons.device_thermostat,
                                  iconColor: theme.colorScheme.onSecondary,
                                  text: '${widget.animal.data.first.temperature.value ?? 'N/A'}ºC',
                                  textColor: theme.colorScheme.onSecondary,
                                  iconSize: 25,
                                  fontSize: 25,
                                ),
                              ),
                              IconText(
                                icon: Icons.landscape,
                                iconColor: theme.colorScheme.onSecondary,
                                text: '${widget.animal.data.first.elevation.value!.ceil()}m',
                                // text: '${widget.device.data.first.elevation.value.round()}m',
                                textColor: theme.colorScheme.onSecondary,
                                iconSize: 25,
                                fontSize: 25,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: IconText(
                                  icon: DeviceWidgetProvider.getBatteryIcon(
                                    deviceBattery: widget.animal.data.first.battery.value!.ceil(),
                                    color: theme.colorScheme.onSecondary,
                                  ),
                                  iconSize: 25,
                                  fontSize: 25,
                                  isInverted: true,
                                  iconColor: theme.colorScheme.onSecondary,
                                  text: '${widget.animal.data.first.battery.value ?? 'N/A'}%',
                                  textColor: theme.colorScheme.onSecondary,
                                ),
                              ),
                              IconText(
                                icon: Icons.info_outline,
                                isInverted: true,
                                iconColor: theme.colorScheme.onSecondary,
                                text: states[Random().nextInt(states.length)],
                                textColor: theme.colorScheme.onSecondary,
                                iconSize: 25,
                                fontSize: 25,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  // if (widget.animal.data.isNotEmpty)
                  //   Expanded(
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         const Expanded(child: SizedBox()),
                  //         IconText(
                  //           icon: Icons.device_thermostat,
                  //           iconColor: theme.colorScheme.onSecondary,
                  //           text: '${widget.animal.data.first.temperature.value}ºC',
                  //           textColor: theme.colorScheme.onSecondary,
                  //           iconSize: 25,
                  //           fontSize: 25,
                  //         ),
                  //         const Expanded(child: SizedBox()),
                  //         IconText(
                  //           icon: DeviceWidgetProvider.getBatteryIcon(
                  //             deviceBattery: widget.animal.data.first.battery.value!.ceil(),
                  //             color: theme.colorScheme.onSecondary,
                  //           ),
                  //           iconSize: 25,
                  //           fontSize: 25,
                  //           isInverted: true,
                  //           iconColor: theme.colorScheme.onSecondary,
                  //           text: '${widget.animal.data.first.battery.value}%',
                  //           textColor: theme.colorScheme.onSecondary,
                  //         ),
                  //         const Expanded(child: SizedBox()),
                  //       ],
                  //     ),
                  //   ),
                  // if (widget.animal.data.isNotEmpty)
                  //   Expanded(
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         const Expanded(child: SizedBox()),
                  //         IconText(
                  //           icon: Icons.landscape,
                  //           iconColor: theme.colorScheme.onSecondary,
                  //           text: '${widget.animal.data.first.elevation.value!.ceil()}m',
                  //           // text: '${widget.device.data.first.elevation.value.round()}m',
                  //           textColor: theme.colorScheme.onSecondary,
                  //           iconSize: 25,
                  //           fontSize: 25,
                  //         ),
                  //         const Expanded(child: SizedBox()),
                  //         IconText(
                  //           icon: Icons.info_outline,
                  //           isInverted: true,
                  //           iconColor: theme.colorScheme.onSecondary,
                  //           text: states[Random().nextInt(states.length)],
                  //           textColor: theme.colorScheme.onSecondary,
                  //           iconSize: 25,
                  //           fontSize: 25,
                  //         ),
                  //         const Expanded(child: SizedBox()),
                  //       ],
                  //     ),
                  //   ),
                  Expanded(
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(child: SizedBox()),
                          Expanded(
                            flex: 2,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Center(
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showColorPicker();
                                      },
                                      child: ColorCircle(
                                        color: animalColor,
                                        radius: 10,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        localizations.animal_color.capitalizeFirst!,
                                        style: theme.textTheme.bodyLarge!.copyWith(
                                          color: theme.colorScheme.onSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.06)),
        ],
      ),
    );
  }
}
