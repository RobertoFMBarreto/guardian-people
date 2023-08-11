import 'package:flutter/material.dart';
import 'package:guardian/models/device.dart';
import 'package:guardian/models/providers/device/device_widgets_provider.dart';
import 'package:guardian/models/providers/hex_color.dart';
import 'package:guardian/widgets/color_circle.dart';
import 'package:guardian/widgets/icon_text.dart';
import 'package:guardian/widgets/inputs/color_picker_input.dart';

class NoBackgroundDeviceTopBar extends StatefulWidget {
  final Device device;
  const NoBackgroundDeviceTopBar({super.key, required this.device});

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
    return Container(
      width: deviceWidth,
      height: 350,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color.fromRGBO(88, 200, 160, 1),
            Color.fromRGBO(147, 215, 166, 1),
          ],
        ),
      ),
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: deviceWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                        'Nome Dispositivo',
                        style: theme.textTheme.headlineMedium!.copyWith(
                          color: theme.colorScheme.onSecondary,
                          fontSize: 40,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconText(
                            icon: Icons.sim_card,
                            iconColor: theme.colorScheme.onSecondary,
                            text: '10/10MB',
                            fontSize: 23,
                            iconSize: 25,
                            textColor: theme.colorScheme.onSecondary,
                          ),
                          IconText(
                            isInverted: true,
                            icon: Icons.landscape,
                            iconColor: theme.colorScheme.onSecondary,
                            text: '400m',
                            fontSize: 23,
                            iconSize: 30,
                            textColor: theme.colorScheme.onSecondary,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconText(
                            icon: Icons.device_thermostat,
                            iconColor: theme.colorScheme.onSecondary,
                            text: '24ºC',
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
                            text: '80%',
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
                                    //!TODO: Logic to update device color
                                    setState(() {
                                      deviceColor = color;
                                      widget.device.color = HexColor.toHex(color: deviceColor);
                                    });
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
                              'Cor do dispositivo',
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