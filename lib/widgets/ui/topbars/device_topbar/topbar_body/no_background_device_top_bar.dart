import 'package:flutter/material.dart';
import 'package:guardian/colors.dart';
import 'package:guardian/models/db/data_models/Device/device.dart';
import 'package:guardian/models/db/operations/device_operations.dart';
import 'package:guardian/models/extensions/string_extension.dart';
import 'package:guardian/models/helpers/device_helper.dart';
import 'package:guardian/models/hex_color.dart';
import 'package:guardian/widgets/ui/common/color_circle.dart';
import 'package:guardian/widgets/ui/common/icon_text.dart';
import 'package:guardian/widgets/inputs/color_picker_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoBackgroundDeviceTopBar extends StatefulWidget {
  final Device device;
  final Widget? tailWidget;
  final Function() onColorChanged;
  const NoBackgroundDeviceTopBar({
    super.key,
    required this.device,
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
    deviceColor = HexColor(widget.device.color);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceWidth = MediaQuery.of(context).size.width;

    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Container(
      width: deviceWidth,
      height: 350,
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
      child: FittedBox(
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
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 20.0,
              ),
              child: SizedBox(
                width: deviceWidth,
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        widget.device.name,
                        style: theme.textTheme.headlineMedium!.copyWith(
                          color: theme.colorScheme.onSecondary,
                          fontSize: 40,
                        ),
                      ),
                      if (widget.device.data == null)
                        Text(
                          localizations.no_device_data.capitalize(),
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                            color: theme.colorScheme.onSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (widget.device.data != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconText(
                              icon: Icons.sim_card,
                              iconColor: theme.colorScheme.onSecondary,
                              text: '${widget.device.data!.first.dataUsage}/10MB',
                              fontSize: 23,
                              iconSize: 25,
                              textColor: theme.colorScheme.onSecondary,
                            ),
                            IconText(
                              isInverted: true,
                              icon: Icons.landscape,
                              iconColor: theme.colorScheme.onSecondary,
                              text: '${widget.device.data!.first.elevation.round()}m',
                              fontSize: 23,
                              iconSize: 30,
                              textColor: theme.colorScheme.onSecondary,
                            ),
                          ],
                        ),
                      if (widget.device.data != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconText(
                              icon: Icons.device_thermostat,
                              iconColor: theme.colorScheme.onSecondary,
                              text: '${widget.device.data!.first.temperature}ºC',
                              fontSize: 23,
                              iconSize: 30,
                              textColor: theme.colorScheme.onSecondary,
                            ),
                            IconText(
                              icon: DeviceWidgetProvider.getBatteryIcon(
                                deviceBattery: 80,
                                color: theme.colorScheme.onSecondary,
                              ),
                              isInverted: true,
                              iconColor: theme.colorScheme.onSecondary,
                              text: '${widget.device.data!.first.battery}%',
                              fontSize: 23,
                              iconSize: 30,
                              textColor: theme.colorScheme.onSecondary,
                            ),
                          ],
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => CustomColorPickerInput(
                                  pickerColor: deviceColor,
                                  onSave: (color) {
                                    // TODO: Logic to update device color
                                    setState(() {
                                      deviceColor = color;
                                      widget.device.color = HexColor.toHex(color: deviceColor);
                                      widget.onColorChanged();
                                    });

                                    updateDevice(
                                      widget.device.copy(
                                        color: HexColor.toHex(color: deviceColor),
                                      ),
                                    );
                                  },
                                  hexColor: HexColor.toHex(color: deviceColor),
                                ),
                              );
                            },
                            child: ColorCircle(
                              color: deviceColor,
                              radius: 15,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              localizations.device_color.capitalize(),
                              style: theme.textTheme.bodyLarge!.copyWith(
                                color: theme.colorScheme.onSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
