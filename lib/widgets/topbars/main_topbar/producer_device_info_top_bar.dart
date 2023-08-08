import 'package:flutter/material.dart';
import 'package:guardian/models/providers/device/device_widgets_provider.dart';
import 'package:guardian/widgets/icon_text.dart';

class ProducerDeviceInfoTopBar extends StatelessWidget {
  const ProducerDeviceInfoTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      width: deviceWidth,
      height: 300,
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
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 10),
              child: Container(
                width: deviceWidth,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Dados do dispositivo',
                      style: theme.textTheme.headlineMedium,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconText(
                          icon: Icons.sim_card,
                          iconColor: theme.colorScheme.secondary,
                          text: '10/10MB',
                          fontSize: 23,
                          iconSize: 25,
                        ),
                        IconText(
                          isInverted: true,
                          icon: Icons.landscape,
                          iconColor: theme.colorScheme.secondary,
                          text: '400m',
                          fontSize: 23,
                          iconSize: 30,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconText(
                          icon: Icons.device_thermostat,
                          iconColor: theme.colorScheme.secondary,
                          text: '24ºC',
                          fontSize: 23,
                          iconSize: 30,
                        ),
                        IconText(
                          icon: DeviceWidgetProvider.getBatteryIcon(
                            deviceBattery: 80,
                            color: theme.colorScheme.secondary,
                          ),
                          isInverted: true,
                          iconColor: theme.colorScheme.secondary,
                          text: '80%',
                          fontSize: 23,
                          iconSize: 30,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
