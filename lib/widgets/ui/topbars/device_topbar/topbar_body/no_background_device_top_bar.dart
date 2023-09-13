import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:guardian/settings/colors.dart';
import 'package:guardian/models/db/drift/operations/device_operations.dart';
import 'package:guardian/models/db/drift/query_models/device.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/device_helper.dart';
import 'package:guardian/models/helpers/hex_color.dart';
import 'package:guardian/widgets/ui/common/color_circle.dart';
import 'package:guardian/widgets/ui/common/icon_text.dart';
import 'package:guardian/widgets/inputs/color_picker_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:drift/drift.dart' as drift;

class NoBackgroundDeviceTopBar extends StatefulWidget {
  final Device device;
  final Widget? tailWidget;
  final Function(String) onColorChanged;
  final double maxHeight;
  const NoBackgroundDeviceTopBar({
    super.key,
    required this.device,
    required this.maxHeight,
    required this.tailWidget,
    required this.onColorChanged,
  });

  @override
  State<NoBackgroundDeviceTopBar> createState() => _NoBackgroundDeviceTopBarState();
}

class _NoBackgroundDeviceTopBarState extends State<NoBackgroundDeviceTopBar> {
  late Color deviceColor;

  @override
  void initState() {
    deviceColor = HexColor(widget.device.device.color.value);
    super.initState();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => CustomColorPickerInput(
        pickerColor: deviceColor,
        onSave: (color) {
          _onColorUpdate(color);
        },
        hexColor: HexColor.toHex(color: deviceColor),
      ),
    );
  }

  Future<void> _onColorUpdate(Color color) async {
    // TODO: Logic to update device color
    setState(() {
      deviceColor = color;
      widget.onColorChanged(HexColor.toHex(color: deviceColor));
    });

    await updateDevice(
      widget.device.device.copyWith(
        color: drift.Value(HexColor.toHex(color: deviceColor)),
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
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        widget.device.device.name.value,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium!.copyWith(
                          color: theme.colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ),
                  if (widget.device.data.isEmpty)
                    Expanded(
                      child: Text(
                        localizations.no_device_data.capitalize(),
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: theme.colorScheme.onSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (widget.device.data.isNotEmpty)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Expanded(child: SizedBox()),
                          Expanded(
                            flex: 3,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: IconText(
                                icon: Icons.sim_card,
                                iconColor: theme.colorScheme.onSecondary,
                                text: '${widget.device.data.first.dataUsage.value}/10MB',
                                textColor: theme.colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Expanded(
                            flex: 3,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: IconText(
                                isInverted: true,
                                icon: Icons.landscape,
                                iconColor: theme.colorScheme.onSecondary,
                                text: '10000m',
                                // text: '${widget.device.data.first.elevation.value.round()}m',
                                textColor: theme.colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  if (widget.device.data.isNotEmpty)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Expanded(child: SizedBox()),
                          Expanded(
                            flex: 2,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: IconText(
                                icon: Icons.device_thermostat,
                                iconColor: theme.colorScheme.onSecondary,
                                text: '${widget.device.data.first.temperature.value}ºC',
                                textColor: theme.colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Expanded(
                            flex: 2,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: IconText(
                                icon: DeviceWidgetProvider.getBatteryIcon(
                                  deviceBattery: 80,
                                  color: theme.colorScheme.onSecondary,
                                ),
                                isInverted: true,
                                iconColor: theme.colorScheme.onSecondary,
                                text: '${widget.device.data.first.battery.value}%',
                                textColor: theme.colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
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
                                        color: deviceColor,
                                        radius: 10,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: AutoSizeText(
                                        localizations.device_color.capitalize(),
                                        style: theme.textTheme.bodyLarge!.copyWith(
                                          color: theme.colorScheme.onSecondary,
                                        ),
                                        minFontSize: 15,
                                        maxFontSize: 20,
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
